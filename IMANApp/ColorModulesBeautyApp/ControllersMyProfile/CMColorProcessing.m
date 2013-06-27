/*--------------------------------------------------------------------------
 CMColorProcessing.m
 
 Test project for building color processing functionalities - to be integrated
 with the main app in future
 
 Developed by Abhijit Sarkar
 
 Created by Abhijit Sarkar on 2012/05/08
 
 Description:
 Code for color processing library functions.
 
 
 Revision history: (CRITICAL TO KEEP A RECORD OF EVERY UPDATE HERE)
 
 2012/02/26 - by AS
 2012/03/20 - by AS, major feature addition (e.g. sRGB/Device color), exposure
 correction
 2012/04/04 - by AS, major update in color correction
 
 
 Existing Problems:
 (date) -
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/

#import "CMColorProcessing.h"
#import <ImageIO/ImageIO.h>
//#import <ImageIO/CGImageSource.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AssertMacros.h>
#import "Math.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "SVProgressHUD.h"
#import "Logging.h"

#define BEST_BYTE_ALIGNMENT 16
#define COMPUTE_BEST_BYTES_PER_ROW(bpr)\
(((bpr) + (BEST_BYTE_ALIGNMENT - 1)) & ~(BEST_BYTE_ALIGNMENT - 1))

// used for KVO observation of the @"mProcessingWasCancelled" property in colorProcessing VC
//static const NSString *ProcessingWasCancelledContext = @"ProcessingWasCancelledContext";


const float const_RefExposureValue = 8.5287; // 10.7604; // at ISO 100 and brightness value = 3.665, EV = AV + TV + log2(S/100)



// use sRGB - device values not producing as good results

// ------------************* Gamma Values ************----------

// for iPhone camera - from ColorSync ICC color profile, same for iPhone 3G and 4
const float const_InputDevice_gamma[3] = {2.2, 2.2, 2.2};

// for generic RGB
//const float const_genericRGB_gamma[3] = {1.801, 1.801, 1.801};

// for color LCD
const float const_OutputDevice_gamma[3] = {2.4, 2.4, 2.4};

// for iPhone display - from "CHROMiX iPhone G1 Aug08" iPhone ICC profile
//const float const_OutputDevice_gamma[3] = {1.57, 1.793, 1.629};

// ------------*************


// ------------************* Primary Tristimulus Matrices ************----------

// for iPhone camera - from ColorSync ICC color profile, same for iPhone 3G and 4
float const_InputDevicePriTristimMat[9] =  {0.454,  0.353,   0.157,
    0.243,    0.674,   0.083,
    0.015,   0.090,   0.720};

/*
 // for iPhone display - from "CHROMiX iPhone G1 Aug08" iPhone ICC profile
 float const_OutputDevicePriTristimMat[9] = {0.408, 0.409, 0.148,
 0.226, 0.652, 0.121,
 0.041, 0.088, 0.696};
 */


// for Color LCD
float const_OutputDevicePriTristimMat[9] = {0.428,  0.385,   0.151,
    0.220,    0.727,   0.052,
    0.005,   0.026,   0.794};



// ------------*************


// ------------************* Inverse Primary Tristimulus Matrices ************----------


// for iPhone camera - from ColorSync ICC color profile, same for iPhone 3G and 4
float const_InputDevicePriTristimMatInverse[9] =  {3.0347,   -1.5245,   -0.4860,
    -1.1033,    2.0611,    0.0030,
    0.0747,   -0.2259,    1.3986};


// for Color LCD
float const_OutputDevicePriTristimMatInverse[9] =  {3.2057,   -1.6798,   -0.4996,
    -0.9709,    1.8875,    0.0610,
    0.0116,   -0.0512,    1.2606};


/*
 // for iPhone display - from "CHROMiX iPhone G1 Aug08" iPhone ICC profile
 float const_OutputDevicePriTristimMatInverse[9] = {3.7719,   -2.3121,   -0.4001,
 -1.2966,    2.3654,   -0.1355,
 -0.0583,   -0.1629,    1.4775};
 */

// ------------*************


// ------------************* White Point ************----------

float const_D65WPXYZ[3] = {0.95,  1,   1.089}; // media WP D65
float const_mediaWPXYZ[3] = {0.964,  1,   0.825}; // iPhone display - from "CHROMiX iPhone G1 Aug08" iPhone ICC profile
float const_eyeDestWPXYZ[3] = {0.5808,    0.5515,    0.6099};

float targetEyeWPY = 0.5515;

@implementation CMColorProcessing


@synthesize mProfileColorsOriginal_RawRGB, mProfileColorsCorrected_DeviceRGB, mProfileColorsCorrected_sRGB, mProfileColorsCorrected_Lab;
@synthesize mArrDictImagePixelData;
@synthesize mCorrectedPhotoURL, mUserCancelledProcessing;
//@synthesize imageRowWasUpdatedObserver, processingIsCompleteObserver;

@synthesize delegate;


// -------- dictionary items for image pixel data ------------
NSString *mKEY_PXLINDEX = @"pxlIdx";
NSString *mKEY_PXLTAG = @"pxlTag"; // tag:: 0: none, 1: eye iris, 2: skin, 3: lip, 4: hair
NSString *mKEY_X = @"x";
NSString *mKEY_Y = @"y";
NSString *mKEY_INPUT_R = @"INPUT_R";
NSString *mKEY_INPUT_G = @"INPUT_G";
NSString *mKEY_INPUT_B = @"INPUT_B";

NSString *mKEY_OUTPUT_SRGB_R = @"OUTPUT_SRGB_R";
NSString *mKEY_OUTPUT_SRGB_G = @"OUTPUT_SRGB_G";
NSString *mKEY_OUTPUT_SRGB_B = @"OUTPUT_SRGB_B";

NSString *mKEY_OUTPUT_DEVICERGB_R = @"OUTPUT_DEVICERGB_R";
NSString *mKEY_OUTPUT_DEVICERGB_G = @"OUTPUT_DEVICERGB_G";
NSString *mKEY_OUTPUT_DEVICERGB_B = @"OUTPUT_DEVICERGB_B";

NSString *mKEY_CIELAB_L = @"CIELAB_L";
NSString *mKEY_CIELAB_a = @"CIELAB_a";
NSString *mKEY_CIELAB_b = @"CIELAB_b";
NSString *mKEY_CIELAB_C = @"CIELAB_C";
NSString *mKEY_CIELAB_h = @"CIELAB_h";



/* --------------------------------------------------------------------------------------
 
 creates an RGB bitmap context
 
 ------------------------------------------------------------------------------------------*/
- (CGContextRef) createRGBBitmapContext: (unsigned char *) rasterData Width: (size_t) width Height:(size_t) height
{
    CGContextRef context;
    
    // 4 bytes/pixel * number of pixels/row
    mBytesPerPixel = 4;
    mBytesPerRow = width * 4;
    mBitsPerComponent = 8;
    
    // round up to nearest multiple of 16
    mBytesPerRow = COMPUTE_BEST_BYTES_PER_ROW(mBytesPerRow);
    
    if (rasterData == NULL)
        return NULL;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    context = CGBitmapContextCreate(rasterData, width, height, mBitsPerComponent, mBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);    //  kCGImageAlphaNoneSkipLast
    
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL)
        return context;
    
    
    CGContextSaveGState(context);
    CGFloat opaqueWhite[4] = {1.0, 1.0, 1.0, 1.0};
    
    CGColorRef fillColorWhite = CGColorCreate(colorSpace, opaqueWhite);
    CGContextSetFillColorWithColor(context, fillColorWhite);
    
    CGColorRelease(fillColorWhite);
    
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    CGContextRestoreGState(context);
    
    
    return context;
}

/* --------------------------------------------------------------------------------------
 
 By calling this function, the caller passes ownership of the raster memory in the context
 to this routine
 ------------------------------------------------------------------------------------------*/

- (CGImageRef) createImageFromBitmapContext: (CGContextRef) context
{
    CGImageRef image;
    
    // obtain raster data from the context
    unsigned char *rasterData = CGBitmapContextGetData(context);
    
    if (rasterData == NULL)
        return NULL;
    
    size_t imageDataSize = CGBitmapContextGetBytesPerRow(context) * CGBitmapContextGetHeight(context);
    
    // create data provider from raster data
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rasterData, imageDataSize, NULL);
    
    
    
    if (dataProvider == NULL)
    {
        free(rasterData);
        return NULL;
    }
    
    size_t width = CGBitmapContextGetWidth(context);
    size_t height = CGBitmapContextGetHeight(context);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    mBytesPerPixel = 4;
    mBytesPerRow = width * 4;
    mBitsPerComponent = 8;
    CGFloat bitsPerPixel = 32;
    
    // now create the image; the parameters are identical to those of the bitmap context
    image = CGImageCreate(width, height,
                          mBitsPerComponent,
                          bitsPerPixel,
                          mBytesPerRow,
                          colorSpace,
                          kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big,
                          dataProvider,
                          NULL, //decode
                          true, //shouldInterpolate
                          kCGRenderingIntentDefault);
    
    CGColorSpaceRelease(colorSpace);
    
    
    // release the data provider - image retains it
    CGDataProviderRelease(dataProvider);
    
    
    return image;
    
}




/* --------------------------------------------------------------------------------------
 
 draws RGB images from raw image files on disk
 ------------------------------------------------------------------------------------------*/

- (CGLayerRef) createCGLayerForDrawing: (CGContextRef) context DrawingArea: (CGRect) rect
{
    CGSize layerSize;
    CGLayerRef layer;
    
    // make the layer the size of the rectangle that this code draws
    // into the layer
    layerSize.width = rect.size.width;
    layerSize.height = rect.size.height;
    
    // create the layer to draw into
    layer = CGLayerCreateWithContext(context, layerSize, NULL);
    
    
    if (layer == NULL) {
        return NULL;
    }
    
    // get the context corresponding to the layer
    CGContextRef layerContext = CGLayerGetContext(layer);
    
    if (layerContext == NULL) {
        CGLayerRelease(layer);
        return NULL;
    }
    
    float opaqueWhite[4] = {1.0, 1.0, 1.0, 1.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef rgbWhite = CGColorCreate(colorSpace, opaqueWhite);
    
    // set the fill color to opaque white
    CGContextSetFillColorWithColor(context, rgbWhite);
    
    // draw the content into the layer
    CGContextFillRect(layerContext, rect);
    
    return layer;
    
}


/* --------------------------------------------------------------------------------------
 
 draws current row of corrected image colors
 ------------------------------------------------------------------------------------------*/
-(void) drawPixelsOnLayer: (CGLayerRef) layer DrawingArea: (CGRect) rect FillWithColor: (unsigned char *) imageColor
{
    // get the context corresponding to the layer
    //CGContextRef layerContext = CGLayerGetContext(layer);
    
    
    
}




/* --------------------------------------------------------------------------------------
 
 returns doc folder path
 example fileName: @"correctedUserPhoto.jpg"
 ------------------------------------------------------------------------------------------*/
- (NSURL *) docFolderURL
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", documentsDirectory, @"/CorrectedUserPhoto.jpg"]];
    
}





/* --------------------------------------------------------------------------------------
 
 
 ------------------------------------------------------------------------------------------*/

- (void) openColorExtractionSession:(CGImageRef)imageRef
{
    
    // -------- profile colors: skin device, skin sRGB, lip device, lip sRGB etc -----------
    
    mProfileColorsOriginal_RawRGB = [NSMutableArray arrayWithCapacity: 4];
    mProfileColorsCorrected_DeviceRGB = [NSMutableArray arrayWithCapacity: 4];
    mProfileColorsCorrected_sRGB = [NSMutableArray arrayWithCapacity: 4];
    mProfileColorsCorrected_Lab = [NSMutableArray arrayWithCapacity: 4];
    
    
}



/* --------------------------------------------------------------------------------------
 
 
 ------------------------------------------------------------------------------------------*/

- (void) closeColorExtractionSession
{
    
    
    [mProfileColorsOriginal_RawRGB removeAllObjects];
    [mProfileColorsCorrected_DeviceRGB removeAllObjects];
    [mProfileColorsCorrected_sRGB removeAllObjects];
    [mProfileColorsCorrected_Lab removeAllObjects];
    
}

-(void) dealloc
{
    mProfileColorsOriginal_RawRGB = nil;
    mProfileColorsCorrected_DeviceRGB = nil;
    mProfileColorsCorrected_sRGB = nil;
    mProfileColorsCorrected_Lab = nil;
    
    mCorrectedPhotoURL = nil;
    
    mArrDictImagePixelData = nil;
    mCorrectedPhotoURL = nil;
    delegate = nil;
    
}


/* --------------------------------------------------------------------------------------
 
 
 ------------------------------------------------------------------------------------------*/
/*
 -(NSString *)hexadecimalValueOfAUIColor: (UIColor *) aColor
 {
 float redFloatValue = 0, greenFloatValue = 0, blueFloatValue = 0, colorA = 0;
 int redIntValue, greenIntValue, blueIntValue;
 NSString *redHexValue, *greenHexValue, *blueHexValue;
 
 
 
 if(aColor)
 {
 // Get the red, green, and blue components of the color
 [aColor  getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:&colorA];
 
 
 // Convert the components to numbers (unsigned decimal integer) between 0 and 255
 redIntValue=redFloatValue*255.99999f;
 greenIntValue=greenFloatValue*255.99999f;
 blueIntValue=blueFloatValue*255.99999f;
 
 
 // Convert the numbers to hex strings
 redHexValue=[NSString stringWithFormat:@"%02X", redIntValue];
 greenHexValue=[NSString stringWithFormat:@"%02X", greenIntValue];
 blueHexValue=[NSString stringWithFormat:@"%02X", blueIntValue];
 
 
 //redHexValue=[NSString stringWithFormat:@"%d,", redIntValue];
 //greenHexValue=[NSString stringWithFormat:@"%d,", greenIntValue];
 //blueHexValue=[NSString stringWithFormat:@"%d", blueIntValue];
 
 
 
 
 // Concatenate the red, green, and blue components' hex strings together with a "#"
 return [NSString stringWithFormat:@"%@%@%@", redHexValue, greenHexValue, blueHexValue];
 
 }
 return nil;
 }
 */





/* --------------------------------------------------------------------------------------
 
 left and right are with respect to the image view (not w.r.t the user)
 
 Avoid forehead - hair often falls on forehead
 
 ------------------------------------------------------------------------------------------*/

- (void) locateSkinAreas:(CGPoint) leftEyePos RightEyePosition:(CGPoint) rightEyePos  MouthPosition:(CGPoint) mouthPos
{
    
    CGFloat xDist_Eyes = rightEyePos.x - leftEyePos.x;
    CGFloat yDist_MouthAndEyes = mouthPos.y - (leftEyePos.y + rightEyePos.y) * 0.5;
    
    
    
    mSkinAreaRect.origin.x = rintf(leftEyePos.x * 0.75); // was 0.6 - changed on 07/15/12
    
    // starts below the left eye, 0.3 times the dist between eye and mouth
    mSkinAreaRect.origin.y = rintf(leftEyePos.y + yDist_MouthAndEyes * 0.25);
    
    // 1.65 times the dist between eyes
    mSkinAreaRect.size.width = rintf(xDist_Eyes * 1.65);
    
    // 0.8 times the dist between eye and mouth
    mSkinAreaRect.size.height = rintf(yDist_MouthAndEyes * 0.55);
    
    
    
}

/* --------------------------------------------------------------------------------------
 
 left and right are with respect to the image view (not w.r.t the user)
 
 ------------------------------------------------------------------------------------------*/

- (void) locateHairAreas: (CGRect) areaOfInterest LeftEyePosition:(CGPoint) leftEyePos RightEyePosition:(CGPoint) rightEyePos  MouthPosition:(CGPoint) mouthPos
{
    
    
    CGFloat xDist_Eyes = rightEyePos.x - leftEyePos.x;
    CGFloat yDist_MouthAndEyes = mouthPos.y - (leftEyePos.y + rightEyePos.y) * 0.5;
    
    
    mHairAreaRect.origin.x = rintf(leftEyePos.x - xDist_Eyes / 1.5); // changed on 07/15/12: was 2.0
    
    if(mHairAreaRect.origin.x < areaOfInterest.origin.x + 3)
        mHairAreaRect.origin.x = areaOfInterest.origin.x + 3;
    
    
    //
    mHairAreaRect.origin.y = rintf(2.2 * leftEyePos.y - 1.3 * mouthPos.y);
    
    if(mHairAreaRect.origin.y < areaOfInterest.origin.y + 3)
        mHairAreaRect.origin.y = areaOfInterest.origin.y + 3;
    
    // ends at the middle of forehead
    mHairAreaRect.size.width = rintf(xDist_Eyes * 2.3);  // changed on 07/15/12: was 2.0
    
    if(mHairAreaRect.size.width > areaOfInterest.size.width - 3)
        mHairAreaRect.size.width = areaOfInterest.size.width - 3;
    
    
    // 0.8 times the dist between eye and mouth
    mHairAreaRect.size.height = rintf(yDist_MouthAndEyes * 1.0);  // changed on 07/15/12: was 0.8
    
    if(mHairAreaRect.size.height > areaOfInterest.size.height) // unlikely, but still
        mHairAreaRect.size.height = areaOfInterest.size.height;
    
}








/* --------------------------------------------------------------------------------------
 
 Observations:
 If hair color is significantly close to background and/or skin colors, there is no
 need to distinguish them
 
 Goal is to get rid of background and/or skin colors when they are significantly different
 from the hair color
 
 Hair bangs can create false edges
 
 Function logic:
 
 - hair color is computed last, so average chroma and hue of the skin tone will be known
 
 
 
 
 ------------------------------------------------------------------------------------------*/


- (BOOL) updateHairArea: (CGRect)areaOfInterest SkinColorLAB: (CGFloat *)skinColorLab
{
    bool success = YES;
    int totalHairRegionPxls = 0, pxlIndex_AreaOfInterest, curPxlID; //, tempTotalpxlCount;
    int startX, endX, startY, endY;
    
    if(mHairAreaRect.size.height == 0 || mHairAreaRect.size.width == 0)
    {
        // problem with hair area specification
        success = NO;
        return success;
    }
    
    startX = (int)mHairAreaRect.origin.x;
    endX = (int) (mHairAreaRect.origin.x + mHairAreaRect.size.width);
    
    startY = (int) mHairAreaRect.origin.y;
    endY = (int) (mHairAreaRect.origin.y + mHairAreaRect.size.height);
    
    int hairAreaWidth = endX - startX;
    int hairAreaHeight = endY - startY;
    
    totalHairRegionPxls = hairAreaWidth * hairAreaHeight;
    
    
    //NSLog(@"updateHairArea >>> Hair area: x=%d,y=%d,w=%d,h=%d", startX, startY, endX, endY);
    //NSLog(@"updateHairArea >>> AOI: x=%3f,y=%3f,w=%3f,h=%3f", areaOfInterest.origin.x, areaOfInterest.origin.y, areaOfInterest.size.width, areaOfInterest.size.height);
    
    // ----------- get all Lab data first ------------
    
    float *pxlDataL = calloc(totalHairRegionPxls, sizeof(float));
    float *pxlDataC = calloc(totalHairRegionPxls, sizeof(float));
    float *pxlDatah = calloc(totalHairRegionPxls, sizeof(float));
    
    float maxL = -5000.0, maxC = -5000.0, maxh = -5000.0;
    
    //tempTotalpxlCount = 0;
    
    
    for (int jj = startY; jj < endY; jj++)
    {
        for (int ii = startX; ii < endX; ii ++)
        {
            // objPxlIndex goes from 0 through size of area of interest
            pxlIndex_AreaOfInterest = areaOfInterest.size.width * (jj - areaOfInterest.origin.y) + ii - areaOfInterest.origin.x;
            
            
            // get dict corresponding to index pxlIndex_AreaOfInterest
            NSMutableDictionary *dictPxl = [NSMutableDictionary dictionaryWithDictionary:[mArrDictImagePixelData objectAtIndex: pxlIndex_AreaOfInterest]];
            
            curPxlID = hairAreaWidth * (jj - startY) + ii - startX;
            
            pxlDataL[curPxlID] = [[dictPxl valueForKey:mKEY_CIELAB_L] floatValue];
            pxlDataC[curPxlID] = [[dictPxl valueForKey:mKEY_CIELAB_C] floatValue];
            pxlDatah[curPxlID] = [[dictPxl valueForKey:mKEY_CIELAB_h] floatValue];
            
            if (pxlDataL[curPxlID] > maxL)    maxL = pxlDataL[curPxlID];
            if (pxlDataC[curPxlID] > maxC)    maxC = pxlDataC[curPxlID];
            if (pxlDatah[curPxlID] > maxh)    maxh = pxlDatah[curPxlID];
            
            //tempTotalpxlCount++;
            
        }
    }
    
    
    
    // ------- normalize w.r.t. the max and define data to operate on --------
    float *myData = calloc(totalHairRegionPxls, sizeof(float));
    
    for (int jj = 0; jj < totalHairRegionPxls; jj++)
    {
        
        pxlDataL[jj] /= maxL;
        pxlDataC[jj] /= maxC;
        pxlDatah[jj] /= maxh;
        
        myData[jj] = pxlDataL[jj] * 2 - pxlDataC[jj];
        
    }
    
    //NSLog(@"\n total pxl: %d, max = %2.1f, %2.1f, %2.1f", tempTotalpxlCount, maxL, maxC, maxh);
    
    free(pxlDataL);
    free(pxlDataC);
    free(pxlDatah);
    
    
    
    
    
    // ------------- define filters --------------
    //float SobelFilter[9] = {-1.0, -2.0, -1.0, 0, 0, 0, 1.0, 2.0, 1.0}; // Edge detector
    float averagingFilter[9] = {1.0/16, 2.0/16, 1.0/16, 2.0/16, 4.0/16, 2.0/16, 1.0/16, 2.0/16, 1.0/16}; // smoothing
    
    
    
    // ------------- smooth data to reduce noise --------------
    
    float *averagedData = calloc(totalHairRegionPxls, sizeof(float));
    
    
    for (int yy = startY + 1; yy < endY - 1; yy++)
    {
        for (int xx = startX + 1; xx < endX - 1; xx ++)
        {
            curPxlID = hairAreaWidth * (yy - startY) + (xx - startX); //pxlID_CurRowPrevCol + 1;
            
            
            averagedData[curPxlID] = 0;
            
            for (int jj = -1; jj <= 1; jj++)
            {
                for (int ii = -1; ii <= 1; ii ++)
                {
                    int pxlID = hairAreaWidth * (yy - startY + jj) + (xx - startX + ii);
                    
                    averagedData[curPxlID] += myData[pxlID] * averagingFilter[3 * (jj+1)+ ii+1];
                }
            }
            
        }
    }
    
    //NSLog(@"\n x =%3.0d, y=%3.0d, pxlID = %3.0d, av data = %4.3f", ii, jj, curPxlID, averagedData[curPxlID]);
    
    free(myData);
    
    
    
    // ------------- now determine threshold --------------
    
    float minVal = 5000.0, maxVal = -5000.0, meanVal = 0;
    
    
    // don't count the last row and column
    for (int yy = startY; yy < endY; yy++)
    {
        for (int xx = startX; xx < endX; xx ++)
        {
            
            curPxlID = hairAreaWidth * (yy - startY) + (xx - startX);
            
            if (averagedData[curPxlID] < minVal)
                minVal = averagedData[curPxlID];
            
            if (averagedData[curPxlID] > maxVal)
                maxVal = averagedData[curPxlID];
            
            meanVal += averagedData[curPxlID];
            
        }
    }
    
    meanVal = meanVal/totalHairRegionPxls;
    
    
    //NSLog(@"\n updateHairArea >>> total hair pxl = %d, min = %4.3f, max = %4.3f, mean = %4.3f", totalHairRegionPxls, minVal, maxVal, meanVal);
    
    
    
    float threshold;
    
    threshold = 0.9447 * meanVal - 0.0309 * maxVal + 0.3287 * minVal;
    //threshold = minVal + 0.3 * (maxVal - minVal);
    
    int tempTotalpxlCount = 0;
    
    // ------------- clip data at threshold --------------
    
    
    
    BOOL isHairPixel;
    
    
    for (int jj = startY; jj < endY; jj++)
    {
        for (int ii = startX; ii < endX; ii ++)
        {
            // objPxlIndex goes from 0 through size of area of interest
            pxlIndex_AreaOfInterest = areaOfInterest.size.width * (jj - areaOfInterest.origin.y) + ii - areaOfInterest.origin.x;
            
            curPxlID = hairAreaWidth * (jj - startY) + ii - startX;
            
            
            // The following if statements are added on 07.15.2012 since light-colored hair
            // is causing the selection to reverse - e.g. for blonde hair - thresholding
            // should be reversed
            
            if (threshold < 0.5 && averagedData[curPxlID] < threshold)
            {
                isHairPixel = YES;
            }
            
            else if (threshold >= 0.5 && averagedData[curPxlID] > threshold)
            {
                isHairPixel = YES;
            }
            else
                isHairPixel = NO;
            
            
            
            if (isHairPixel)
            {
                // hair pixel
                averagedData[jj] = 1;
                
                tempTotalpxlCount++;
                
            }
            else
            {
                // not a hair pixel - reset tag
                averagedData[jj] = 0;
                
                
                // get dict corresponding to index pxlIndex_AreaOfInterest
                NSMutableDictionary *dictPxl = [NSMutableDictionary dictionaryWithDictionary:[mArrDictImagePixelData objectAtIndex: pxlIndex_AreaOfInterest]];
                
                NSNumber *objTag = [NSNumber numberWithInt:0];
                
                [dictPxl setObject:objTag forKey:mKEY_PXLTAG];
                
                [mArrDictImagePixelData replaceObjectAtIndex:pxlIndex_AreaOfInterest withObject:dictPxl];
                
                
                
            }
            
            
        }
    }
    
    LogInfo(@"Final no of hair pxls: %d ", tempTotalpxlCount);
    
    if (tempTotalpxlCount == 0) {
        success = NO;
    }
    
    free(averagedData);
    
    
    return success;
}





/* --------------------------------------------------------------------------------------
 
 returnCode::
 -2: destination image could not be written
 -1: error
 0: default value (not returned)
 2: image was too bright/dark - luminance correction factor restricted to extremum
 3: dominant hair/eye/skin/lip area colors could not be computed
 1: everything fine
 
 
 ------------------------------------------------------------------------------------------*/

- (void) correctAndExtractColorProfileDataFromFacialImage:(CGImageRef) imageRef atRect:(CGRect)areaOfInterest LeftEyePosition:(CGPoint) leftEyePos RightEyePosition:(CGPoint) rightEyePos MouthPosition:(CGPoint) mouthPos withImageURL: (NSURL *) imgURL
{
    
    mProcessingStatusCode = 1;
    float luminanceCorrectionFactor = 0;
    
    
    NSUInteger aoiWidth = areaOfInterest.size.width;
    NSUInteger aoiHeight = areaOfInterest.size.height;
    NSUInteger imgWidth = CGImageGetWidth(imageRef);
    NSUInteger imgHeight = CGImageGetHeight(imageRef);
    
    
    // update status message - initialization
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] updateProcessingStatus:self StatusCode:0];
    });
    
    
    // --------------- get raw RGB data ------------------
    mRawImagePixelData = calloc(imgHeight * imgWidth * 4, sizeof(unsigned char));
    
    //  create bitmap context
    CGContextRef context = [self createRGBBitmapContext: mRawImagePixelData  Width: imgWidth Height: imgHeight];
    
    // draw image - mRawImagePixelData gets populated
    CGContextDrawImage(context, CGRectMake(0, 0, imgWidth, imgHeight), imageRef);
    
    CGContextRelease(context);
    
    // --------************* Generate a dictionary of dictionary items ****************------------
    
    
    // ----- reset and reinitialize dictionary -
    //                          to be used in color correction/extraction -----
    
    mArrDictImagePixelData = [NSMutableArray arrayWithCapacity:(aoiWidth * aoiHeight)];
    
    // --------*************** Correction for scene luminance using metadata ********************--------------
    
    //                          currently using eye WP Y ratio - working well
    
    /*
     // read metadata
     float exposureTime = 0, apertureValue = 0, sensitivity = 0, brightnessValue = 0, shutterSpeedValue = 0;
     [self getExifMetadata:imgURL ExposureTime: &exposureTime ApertureValue: &apertureValue Sensitivity: &sensitivity BrightnessValue: &brightnessValue ShutterSpeedValue: &shutterSpeedValue];
     
     
     
     
     // ----- method 1 ---------
     
     // Ref.:  http://www.giangrandi.ch/optics/lenses/expcalc.html (DO NOT USE - TOO MUCH VARIATION)
     //float avSceneLuminanceTerm = powf(2.0, apertureValue)/(sensitivity * exposureTime) * 0.9121;
     
     
     // correction factor based on brightness value
     // reference brightness arbitrary - DECENT RESULTS??
     luminanceCorrectionFactor = 3.0/brightnessValue;
     
     
     // ----- method 2 ---------
     // DO NOT USE - HIGH VARIATION - RECHECK AFTER EXPOSURE CONTROL DURING CAPTURE IS IN PLACE
     // CI filter does this: s.rgb * pow(2.0, ev)
     
     //float EV = apertureValue + log2(1/exposureTime) + log2(sensitivity/100);  // people seem to use EV100
     float EV100 = apertureValue + log2(1/exposureTime);
     
     float avSceneLuminanceTerm = powf(2.0, EV100);
     
     // correction factor based on exposure value
     luminanceCorrectionFactor = 690/avSceneLuminanceTerm;
     */
    
    // --------***************
    
    
    
    
    // --------************* Identify hair, eye, skin and lip areas,
    //                          and fill up (pxlID, x, y, tag) items ****************------------
    
    // ---------- hair -----------
    [self locateHairAreas: areaOfInterest LeftEyePosition:leftEyePos RightEyePosition:rightEyePos MouthPosition:mouthPos];
    
    // ---------- eye ------------
    
    CGFloat irisAreaWidth = ceilf((rightEyePos.x - leftEyePos.x) * 0.17); // typical ~ 30
    CGFloat irisAreaHeight = ceilf((mouthPos.y - leftEyePos.y) * 0.12); // typical ~ 25
    
    mEyeIrisAreaRect_Left = CGRectMake(leftEyePos.x - irisAreaWidth/2, leftEyePos.y - irisAreaHeight/2, irisAreaWidth, irisAreaHeight);
    mEyeIrisAreaRect_Right = CGRectMake(rightEyePos.x - irisAreaWidth/2, rightEyePos.y - irisAreaHeight/2, irisAreaWidth, irisAreaHeight);
    
    
    // ---------- skin -----------
    [self locateSkinAreas:leftEyePos RightEyePosition:rightEyePos MouthPosition:mouthPos];
    
    // ---------- lip ------------
    // only lower lip should be considered - upper lip is generally darker
    
    // changed on 07/15/12
    CGFloat lipAreaWidth = ceilf((rightEyePos.x - leftEyePos.x) * 0.44); // typical ~ 35
    CGFloat lipAreaHeight = ceilf((mouthPos.y - leftEyePos.y) * 0.1); // typical ~ 12
    
    mLipAreaRect = CGRectMake(rintf(mouthPos.x - lipAreaWidth/2), rintf(mouthPos.y * 1.01), lipAreaWidth, lipAreaHeight);
    
    
    
    
    // --------************* Analyze eye area - get eye WP XYZ ****************------------
    
    // changed on 07/15/12
    CGFloat eyeAreaWidth = rintf((rightEyePos.x - leftEyePos.x) * 0.35); // typical ~ 28
    CGFloat eyeAreaHeight = rintf((mouthPos.y - leftEyePos.y) * 0.13); // typical ~ 12
    
    
    // changed on 07/15/12
    mWholeEyeAreaRect_Left = CGRectMake(rintf(leftEyePos.x - eyeAreaWidth * 0.61), rintf(leftEyePos.y - eyeAreaHeight/2), eyeAreaWidth, eyeAreaHeight);
    mWholeEyeAreaRect_Right = CGRectMake(rintf(rightEyePos.x - eyeAreaWidth * 0.25), rintf(rightEyePos.y - eyeAreaHeight/2), eyeAreaWidth, eyeAreaHeight);
    
    int whatLighting = 0;
    
    CGFloat *srcWhitePointXYZ = calloc(3, sizeof(float));
    
    
    // update status message - estimating scene lighting
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] updateProcessingStatus:self StatusCode:1];
    });
    
    
    // following function returns scene WP XYZ as well as the luminance correction factor based on eye WP Y ratio
    
    BOOL ret = [self estimateSceneWhitePoint:srcWhitePointXYZ LuminanceCorrectionFactor: &luminanceCorrectionFactor FromWholeLeftEyeArea:mWholeEyeAreaRect_Left FromWholeRightEyeArea: mWholeEyeAreaRect_Right ImageAreaOfInterest: areaOfInterest LightingType:&whatLighting];
    
    if (ret == NO)
    {
        // something is wrong - return
        mProcessingStatusCode = -1;
        
        // get rid of monstrous array
        [mArrDictImagePixelData removeAllObjects];
        mArrDictImagePixelData = nil;
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *errMsg = @"Sorry, scene lighting cannot be accurately estimated from this photo. Kindly retake.";
            [[self delegate] showError:self ErrorMessage: errMsg];
            [[self delegate] processingDidCancel:self];
        });
        
        
        return;
        
    }
    
    // Note: DO NOT put upper and lower limit to correction factor
    
    LogInfo(@"WP: %f %f %f; LumCF = %f", srcWhitePointXYZ[0], srcWhitePointXYZ[1], srcWhitePointXYZ[2], luminanceCorrectionFactor);
    
    // update status message - preparing processing
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] updateProcessingStatus:self StatusCode:2];
    });
    
    
    // --------************* For the whole image, compute: RGBin -> XYZin -> Lab(src WP) ->
    //                                  Lab(dest WP) -> XYZout -> RGBout  ****************------------
    //                          save Lab(dest WP) agrainst appropriate pxlIDs
    
    [self getColorimetricDataFromImage: areaOfInterest LuminanceMF: luminanceCorrectionFactor WhitePointXYZ: srcWhitePointXYZ];
    
    
    if ([mUserCancelledProcessing boolValue]) {
        // cancel immediately
        free(srcWhitePointXYZ);
        
        // get rid of monstrous array
        [mArrDictImagePixelData removeAllObjects];
        mArrDictImagePixelData = nil;
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [[self delegate] processingDidCancel:self];
            
        });
        
        return;
        
    }
    
    
    
    // --------************* For each of the 4 areas denoted by the tag, find dominant CIELAB LCh and
    //                         compute: LCh(dom) -> Lab(dom) -> XYZdom -> RGBout-dom  ****************------------
    
    
    int retGeDomColor = 0;
    UIColor *rawRGBColor, *sRGBColor, *deviceColor;
    
    
    CGFloat *inPxlColor_RGB = calloc(3, sizeof(float));
    CGFloat *outPxlColor_sRGB = calloc(3, sizeof(float));
    CGFloat *outPxlColor_DeviceRGB = calloc(3, sizeof(float));
    CGFloat *outPxlColor_Lab = calloc(5, sizeof(float));
    CGFloat *skinColor_Lab = calloc(5, sizeof(float));
    
    LogInfo(@"In extract: starting dominant color computation...");
    
    // tag:: 0: none, 1: eye iris, 2: skin, 3: lip, 4: hair
    for (int tagID = 1; tagID <= 4; tagID++)
    {
        LogInfo(@"Tag: %d", tagID);
        
        
        // update status message
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] updateProcessingStatus:self StatusCode:(2 + tagID)];
        });
        
        // just to be sure - if there are several colors
        inPxlColor_RGB[0] = 0;  inPxlColor_RGB[1] = 0; inPxlColor_RGB[2] = 0;
        outPxlColor_sRGB[0] = 0;  outPxlColor_sRGB[1] = 0; outPxlColor_sRGB[2] = 0;
        outPxlColor_DeviceRGB[0] = 0;  outPxlColor_DeviceRGB[1] = 0; outPxlColor_DeviceRGB[2] = 0;
        outPxlColor_Lab[0] = 0;  outPxlColor_Lab[1] = 0; outPxlColor_Lab[2] = 0; outPxlColor_Lab[3] = 0; outPxlColor_Lab[4] = 0;
        
        
        if (tagID == 4)
        {
            // hair area must be updated first to discount the skin and background area from the forehead region
            BOOL hairFound = [self updateHairArea: areaOfInterest SkinColorLAB: skinColor_Lab];
            
            if (hairFound) {
                retGeDomColor = [self getDominantColorOfTaggedPixels: tagID RGBInput: inPxlColor_RGB WhitePointXYZ: srcWhitePointXYZ LuminanceMF:(CGFloat) luminanceCorrectionFactor sRGBOutput: outPxlColor_sRGB DeviceRGBOutput:outPxlColor_DeviceRGB LabOutput: outPxlColor_Lab];
            }
            else {
                retGeDomColor = 0;
            }
            
        }
        else
        {
            retGeDomColor = [self getDominantColorOfTaggedPixels: tagID RGBInput: inPxlColor_RGB WhitePointXYZ: srcWhitePointXYZ LuminanceMF:(CGFloat) luminanceCorrectionFactor sRGBOutput: outPxlColor_sRGB DeviceRGBOutput:outPxlColor_DeviceRGB LabOutput: outPxlColor_Lab];
        }
        
        
        
        if (retGeDomColor == -1)
        {
            // there was an error
            mProcessingStatusCode = 3;
            
        }
        
        
        // ------------------- input raw RGB values --------------
        rawRGBColor = [UIColor colorWithRed:inPxlColor_RGB[0] green:inPxlColor_RGB[1] blue:inPxlColor_RGB[2] alpha:1.0];
        
        // ------------------- output sRGB values --------------
        sRGBColor = [UIColor colorWithRed:outPxlColor_sRGB[0] green:outPxlColor_sRGB[1] blue:outPxlColor_sRGB[2] alpha:1.0];
        
        // ------------------- output device RGBs --------------
        deviceColor = [UIColor colorWithRed:outPxlColor_DeviceRGB[0] green:outPxlColor_DeviceRGB[1] blue:outPxlColor_DeviceRGB[2] alpha:1.0];
        
        
        // ------------------- output CIELab values --------------
        NSNumber *objOutL = [NSNumber numberWithFloat:outPxlColor_Lab[0]];
        NSNumber *objOuta = [NSNumber numberWithFloat:outPxlColor_Lab[1]];
        NSNumber *objOutb = [NSNumber numberWithFloat:outPxlColor_Lab[2]];
        NSNumber *objOutC = [NSNumber numberWithFloat:outPxlColor_Lab[3]];
        NSNumber *objOuth = [NSNumber numberWithFloat:outPxlColor_Lab[4]];
        
        NSArray *objLab = [NSArray arrayWithObjects:objOutL, objOuta, objOutb, objOutC, objOuth, nil];
        
        
        [mProfileColorsOriginal_RawRGB addObject: rawRGBColor];
        [mProfileColorsCorrected_sRGB addObject: sRGBColor];
        [mProfileColorsCorrected_DeviceRGB addObject: deviceColor];
        [mProfileColorsCorrected_Lab addObject: objLab];
        
        if (tagID == 2) {
            // save skin color CIELAB - will be needed next for hair area updation
            for (int kk = 0; kk < 5; kk++)
                skinColor_Lab[kk] = outPxlColor_Lab[kk];
        }
        
        //NSLog(@"Corrected Lab: %f %f %f", correctedLab[0], correctedLab[1], correctedLab[2]);
        
        if ([mUserCancelledProcessing boolValue]) {
            // cancel immediately
            free(srcWhitePointXYZ);
            free(inPxlColor_RGB);
            free(outPxlColor_sRGB);
            free(outPxlColor_DeviceRGB);
            free(outPxlColor_Lab);
            free(skinColor_Lab);
            
            // get rid of monstrous array
            [mArrDictImagePixelData removeAllObjects];
            mArrDictImagePixelData = nil;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[self delegate] processingDidCancel:self];
                
            });
            
            return;
            
        }
        
        
    }
    
    // update status message - updating colors, saving corrected image: dispatch sync
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] updateProcessingStatus:self StatusCode:7];
        
    });
    
    
    free(srcWhitePointXYZ);
    free(inPxlColor_RGB);
    free(outPxlColor_sRGB);
    free(outPxlColor_DeviceRGB);
    free(outPxlColor_Lab);
    free(skinColor_Lab);
    
    // all done - get rid of monstrous array
    [mArrDictImagePixelData removeAllObjects];
    mArrDictImagePixelData = nil;
    
    
    if ([mUserCancelledProcessing boolValue]) {
        // cancel immediately
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[self delegate] processingDidCancel:self];
            
        });
        
        return;
        
    }
    
    
    // update interface with profile colors
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] profileColorsComputed:self];
        
    });
    
    
    
    
    
    // --------************* get output image ****************------------
    
    // -------------- create bitmap context --------------
    
    LogInfo(@"In extract: Saving output image...");
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    context = CGBitmapContextCreate(mRawImagePixelData,
                                    imgWidth,
                                    imgHeight,
                                    8, // bitsPerComponent
                                    4*imgWidth, // bytesPerRow
                                    colorSpace,
                                    kCGImageAlphaNoneSkipLast);
    CGColorSpaceRelease(colorSpace);
    
    
    // -------------- create CGImage object from bitmap context --------------
    
    CGImageRef correctedImageRef = CGBitmapContextCreateImage(context);
    
    if(correctedImageRef == NULL)
    {
        // image was not created - return
        mProcessingStatusCode = -1;
        NSString *errMsg = @"Image could not be created. Processing will abort.";
        [[self delegate] showError:self ErrorMessage: errMsg];
        return;
    }
    
    CGContextRelease(context);
    
    
    // ---------------------------- save image in doc folder -------------------------------
    
    BOOL successWritingToDocFolder = NO;
    
    
    CFMutableDictionaryRef imgCFMetaData = nil;
    
    [self saveMetaAndOpts: &imgCFMetaData];
    
    
    CGImageDestinationRef destRefDocFolder = nil;
    
    mCorrectedPhotoURL = [self docFolderURL];
    
    //NSLog(@"url: %@", outputFileURL);
    
    
    
    // Create an image destination writing to `url'
    destRefDocFolder = CGImageDestinationCreateWithURL((__bridge CFURLRef)mCorrectedPhotoURL, CFSTR("public.jpeg"), 1, nil);
    
    if (destRefDocFolder==nil) {
        mProcessingStatusCode = -2;;
    }
    else
    {
        // Set the image in the image destination to be `image' with
        // optional properties specified in saved properties dict.
        //CGImageDestinationAddImage(destRefDocFolder, cgImage, (__bridge CFDictionaryRef)[self saveMetaAndOpts]);
        CGImageDestinationAddImage(destRefDocFolder, correctedImageRef, imgCFMetaData);
        
        successWritingToDocFolder = CGImageDestinationFinalize(destRefDocFolder);
        
        if (successWritingToDocFolder==NO) {
            mProcessingStatusCode = -2;;
        }
        
        CFRelease(destRefDocFolder);
        
        
    }
    
    
    
    // ---------------------------- save image in album folder -------------------------------
    /*
     // create empty object
     CFMutableDataRef destinationData = CFDataCreateMutable(kCFAllocatorDefault, 0);
     CGImageDestinationRef destRefAlbumsFolder = CGImageDestinationCreateWithData(destinationData,
     CFSTR("public.jpeg"),
     1,
     NULL);
     if(destRefAlbumsFolder != NULL)
     {
     NSMutableDictionary *imgMetaData = [self saveMetaAndOpts];
     
     CGImageDestinationAddImage(destRefAlbumsFolder, correctedImageRef, (__bridge CFDictionaryRef) imgMetaData);
     
     CGImageDestinationFinalize( destRefAlbumsFolder );
     
     if (destRefAlbumsFolder)
     CFRelease(destRefAlbumsFolder);
     
     
     CFRetain(destinationData);
     
     
     ALAssetsLibrary *library = [ALAssetsLibrary new];
     [library writeImageDataToSavedPhotosAlbum:(__bridge id)destinationData metadata: imgMetaData completionBlock:^(NSURL *assetURL, NSError *error) {
     if (destinationData)
     CFRelease(destinationData);
     }];
     
     library = nil;
     
     }
     */
    
    
    
    CFRelease(imgCFMetaData);
    CGImageRelease(correctedImageRef);
    
    free(mRawImagePixelData);
    
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    [[self delegate] processingComplete:self];
    //});
    
    
    
    
    return;
    
}




/* --------------------------------------------------------------------------------------
 
 Generate an array (mArrDictImagePixelData) of dictionaries (dictPxl) by going through the whole image
 pixel-by-pixel
 
 mArrDictImagePixelData holds dictPxl values at the index given by objPxlIndex - objects MUST not be added at
 random,
 
 tag:: 0: none, 1: eye iris, 2: skin, 3: lip, 4: hair
 ------------------------------------------------------------------------------------------*/

- (void) getColorimetricDataFromImage: (CGRect)areaOfInterest LuminanceMF:(CGFloat) lumMF WhitePointXYZ: (CGFloat *) srcWhitePtXYZ
{
    
    int xx = (int)areaOfInterest.origin.x;
    int yy = (int)areaOfInterest.origin.y;
    
    int height = areaOfInterest.size.height;
    int width = areaOfInterest.size.width;
    
    CGFloat *curPixelRGB = calloc(3, sizeof(float));
    CGFloat *outPxlColor_sRGB = calloc(3, sizeof(float));
    CGFloat *outPxlColor_DeviceRGB = calloc(3, sizeof(float));
    CGFloat *correctedXYZ = calloc(3, sizeof(float));
    CGFloat *correctedLab = calloc(5, sizeof(float));
    
    int byteIndex;
    int pxlIndex = 0;
    
    NSDate *startTime, *endTime;
    float processingTimeForOneRow = 0;
    float processingTimeLeft = 0;
    
    
    // --------------- get raw RGB data ------------------
    // this is for animation
    unsigned char *correctedPixelRowBuffer = calloc(width * 4, sizeof(unsigned char));
    
    startTime = [NSDate date];
    
    for (int jj = yy ; jj < (yy + height); jj++)
    {
        byteIndex = (mBytesPerRow * jj) + xx * mBytesPerPixel; // increased at the end of the loop
        
        
        // objPxlIndex goes from 0 through size of area of interest
        pxlIndex = areaOfInterest.size.width * (jj - yy);
        
        
        for (int ii = xx ; ii < (xx + width); ii++)
        {
            // reset values
            correctedPixelRowBuffer[ii - xx] = 0;
            correctedPixelRowBuffer[ii - xx + 1] = 0;
            correctedPixelRowBuffer[ii - xx + 2] = 0;
            correctedPixelRowBuffer[ii - xx + 3] = 0;
            
            CGPoint curPixelLocation = CGPointMake(ii, jj);
            
            
            curPixelRGB[0] = (mRawImagePixelData[byteIndex]     * 1.0) / 255.0;
            curPixelRGB[1] = (mRawImagePixelData[byteIndex + 1] * 1.0) / 255.0;
            curPixelRGB[2] = (mRawImagePixelData[byteIndex + 2] * 1.0) / 255.0;
            
            
            
            // just to be sure - if there are several colors
            outPxlColor_sRGB[0] = 0;  outPxlColor_sRGB[1] = 0; outPxlColor_sRGB[2] = 0;
            outPxlColor_DeviceRGB[0] = 0;  outPxlColor_DeviceRGB[1] = 0; outPxlColor_DeviceRGB[2] = 0;
            
            
            
            
            correctedLab[0] = 0; correctedLab[1] = 0; correctedLab[2] = 0; correctedLab[3] = 0; correctedLab[4] = 0;
            
            
            // even though the function returns device RGB and sRGB, only correctedLab will be saved
            [self colorCorrectInputPixel:curPixelRGB WhitePointXYZ: srcWhitePtXYZ LuminanceMF: lumMF sRGBOutput:outPxlColor_sRGB DeviceRGBOutput:outPxlColor_DeviceRGB XYZOutput: correctedXYZ LabOutput: correctedLab];
            
            
            // objPxlIndex goes from 0 through size of area of interest
            NSNumber *objPxlIndex = [NSNumber numberWithInt:pxlIndex];
            NSNumber *objXCoord = [NSNumber numberWithInt:ii];
            NSNumber *objYCoord = [NSNumber numberWithInt:jj];
            
            NSNumber *objINRGB_R = [NSNumber numberWithFloat: curPixelRGB[0]];
            NSNumber *objINRGB_G = [NSNumber numberWithFloat: curPixelRGB[1]];
            NSNumber *objINRGB_B = [NSNumber numberWithFloat: curPixelRGB[2]];
            
            NSNumber *objOUTSRGB_R = [NSNumber numberWithFloat: outPxlColor_sRGB[0]];
            NSNumber *objOUTSRGB_G = [NSNumber numberWithFloat: outPxlColor_sRGB[1]];
            NSNumber *objOUTSRGB_B = [NSNumber numberWithFloat: outPxlColor_sRGB[2]];
            
            
            NSNumber *objOUTDEVICERGB_R = [NSNumber numberWithFloat: outPxlColor_DeviceRGB[0]];
            NSNumber *objOUTDEVICERGB_G = [NSNumber numberWithFloat: outPxlColor_DeviceRGB[1]];
            NSNumber *objOUTDEVICERGB_B = [NSNumber numberWithFloat: outPxlColor_DeviceRGB[2]];
            
            
            NSNumber *objCIELAB_L = [NSNumber numberWithFloat: correctedLab[0]];
            NSNumber *objCIELAB_a = [NSNumber numberWithFloat: correctedLab[1]];
            NSNumber *objCIELAB_b = [NSNumber numberWithFloat: correctedLab[2]];
            NSNumber *objCIELAB_C = [NSNumber numberWithFloat: correctedLab[3]];
            NSNumber *objCIELAB_h = [NSNumber numberWithFloat: correctedLab[4]];
            
            NSNumber *objPxlTag = [NSNumber numberWithInt: 0];
            
            // --------------- determine which tag to apply - tag:: 0: none, 1: eye iris, 2: skin, 3: lip, 4: hair ---------------
            
            
            // eye
            if (CGRectContainsPoint(mEyeIrisAreaRect_Left, curPixelLocation) ||
                CGRectContainsPoint(mEyeIrisAreaRect_Right,  curPixelLocation))
            {
                objPxlTag = [NSNumber numberWithInt: 1];
            }
            
            
            // skin
            if (CGRectContainsPoint(mSkinAreaRect, curPixelLocation))
            {
                objPxlTag = [NSNumber numberWithInt: 2];
                
            }
            
            
            
            //lip
            if (CGRectContainsPoint(mLipAreaRect, curPixelLocation))
                objPxlTag = [NSNumber numberWithInt: 3];
            
            // hair
            if (CGRectContainsPoint(mHairAreaRect, curPixelLocation))
            {
                objPxlTag = [NSNumber numberWithInt: 4];
                
            }
            
            
            
            
            NSMutableDictionary *dictPxl = [NSDictionary dictionaryWithObjectsAndKeys:
                                            objPxlIndex, mKEY_PXLINDEX, objXCoord, mKEY_X, objYCoord, mKEY_Y,
                                            objINRGB_R, mKEY_INPUT_R, objINRGB_G, mKEY_INPUT_G, objINRGB_B, mKEY_INPUT_B,
                                            objOUTDEVICERGB_R, mKEY_OUTPUT_DEVICERGB_R, objOUTDEVICERGB_G, mKEY_OUTPUT_DEVICERGB_G, objOUTDEVICERGB_B, mKEY_OUTPUT_DEVICERGB_B,
                                            objOUTSRGB_R, mKEY_OUTPUT_SRGB_R, objOUTSRGB_G, mKEY_OUTPUT_SRGB_G, objOUTSRGB_B, mKEY_OUTPUT_SRGB_B,
                                            objCIELAB_L, mKEY_CIELAB_L, objCIELAB_a, mKEY_CIELAB_a, objCIELAB_b, mKEY_CIELAB_b,
                                            objCIELAB_C, mKEY_CIELAB_C, objCIELAB_h, mKEY_CIELAB_h,
                                            objPxlTag, mKEY_PXLTAG, nil];
            
            
            
            [mArrDictImagePixelData addObject:dictPxl];
            
            
            // --------------- save corrected RGB ---------------
            if (jj < yy + 1 || jj > (yy + height - 2) || ii < xx + 1 || ii > (xx + width - 2)) {
                // apply 2-pixel wide white border around the corrected area
                mRawImagePixelData[byteIndex] = rintf(1.0 * 255.0);
                mRawImagePixelData[byteIndex + 1] = rintf(1.0 * 255.0);
                mRawImagePixelData[byteIndex + 2] = rintf(1.0 * 255.0);
                mRawImagePixelData[byteIndex + 3] = rintf(1.0 * 255.0); // alpha
                
            }
            else {
                mRawImagePixelData[byteIndex] = rintf(outPxlColor_sRGB[0] * 255.0);
                mRawImagePixelData[byteIndex + 1] = rintf(outPxlColor_sRGB[1] * 255.0);
                mRawImagePixelData[byteIndex + 2] = rintf(outPxlColor_sRGB[2] * 255.0);
                mRawImagePixelData[byteIndex + 3] = rintf(1.0 * 255.0); // alpha
                
            }
            
            correctedPixelRowBuffer[(ii - xx) * 4] = mRawImagePixelData[byteIndex];
            correctedPixelRowBuffer[(ii - xx) * 4 + 1] = mRawImagePixelData[byteIndex + 1];
            correctedPixelRowBuffer[(ii - xx) * 4 + 2] = mRawImagePixelData[byteIndex + 2];
            correctedPixelRowBuffer[(ii - xx) * 4 + 3] = mRawImagePixelData[byteIndex + 3];
            
            byteIndex += 4;
            pxlIndex++;
            
            
            /*
             
             NSLog(@"\nLab: %f %f %f", correctedLab[0], correctedLab[1], correctedLab[2]);
             NSLog(@"\n sRGB: %f %f %f", outPxlColor_sRGB[0], outPxlColor_sRGB[1], outPxlColor_sRGB[2]);
             
             */
            
            if (jj == yy) {
                endTime = [NSDate date];
                processingTimeForOneRow = [endTime timeIntervalSinceDate:startTime];
            }
            
            if ([mUserCancelledProcessing boolValue]) {
                break;
            }
            
        }
        
        
        if ([mUserCancelledProcessing boolValue]) {
            break;
        }
        
        processingTimeLeft = processingTimeForOneRow * ceilf(yy + height - jj);
        
        
        // do animation - update
        
        // Update the processing asychronously on the main queue
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[self delegate] newImageRowComputed: self
                                    RawPixelData: correctedPixelRowBuffer
                                      ImageWidth: width
                                     ImageHeight: 1
                                        RowIndex: (jj - yy)
                              ProcessingTimeLeft: processingTimeLeft];
        });
        
        // recompute
        if (jj == yy) {
            endTime = [NSDate date];
            processingTimeForOneRow = [endTime timeIntervalSinceDate:startTime];
            processingTimeLeft = processingTimeForOneRow * ceilf(yy + height - jj);
        }
        
        
    }
    
    free(correctedPixelRowBuffer);
    free(curPixelRGB);
    free(outPxlColor_sRGB);
    free(outPxlColor_DeviceRGB);
    free(correctedXYZ);
    free(correctedLab);
    
}






/* --------------------------------------------------------------------------------------
 
 This function takes device RGB values of a pixel (float values) and computes
 device-independent RGB values by: 1) linearizing RGBs, 2) computing XYZ, and 3) converting
 to sRGB.
 
 IMPORTANT NOTE (02/26/12): insead of sRGB gamma of 2.4, iPhone gamma is being applied
 currently in convertXYZ2sRGB(). Function to be updated after further research.
 
 gamma will be adjusted by a correction factor, which should be a function of log10(EV)
 
 Check convertXYZ2sRGB() as well
 
 ------------------------------------------------------------------------------------------*/
- (void) colorCorrectInputPixel:(CGFloat *) inputColor WhitePointXYZ: (CGFloat *) srcWhitePtXYZ LuminanceMF:(CGFloat) lumMF sRGBOutput:(CGFloat *) outputsRGB DeviceRGBOutput:(CGFloat *) outputDeviceRGB XYZOutput: (CGFloat *) outXYZ LabOutput: (CGFloat *) outLab
{
    
    
    // ---------  linearize RGB ------------
    
    CGFloat linarizedRGB[3] = {0, 0, 0};
    
    for(int ii = 0; ii <=2; ii++) {
        linarizedRGB[ii] = powf(inputColor[ii], const_InputDevice_gamma[ii]);
        
    }
    
    
    
    
    // ----------------- compute XYZ ---------------------
    CGFloat curColorXYZ[3] = {0, 0, 0};
    
    
    for(int ii = 0; ii <=2; ii++)
    {
        // ----------------- get XYZ of current color-------------
        curColorXYZ[ii] = const_InputDevicePriTristimMat[ii * 3] * linarizedRGB[0] + const_InputDevicePriTristimMat[ii * 3 + 1] * linarizedRGB[1] + const_InputDevicePriTristimMat[ii * 3 + 2] * linarizedRGB[2];
        
        // ---------  correct luminance to compensate for exposure ------------
        curColorXYZ[ii] = curColorXYZ[ii] * lumMF;
        
    }
    
    
    // ------- convert XYZ to Lab --------
    CGFloat curColorLabCh[5] = {0, 0, 0, 0, 0};
    
    [self convertXYZ2Lab:curColorXYZ WhitePtXYZ: srcWhitePtXYZ ToL:&curColorLabCh[0] Toa:&curColorLabCh[1] Tob:&curColorLabCh[2] ToChroma:&curColorLabCh[3] ToHue:&curColorLabCh[4]];
    
    
    // --------- compute destination white point ---------
    CGFloat destWPXYZ[3] = {0, 0, 0};
    
    for(int ii = 0; ii <=2; ii++)
        destWPXYZ[ii] = const_D65WPXYZ[ii] * targetEyeWPY;
    
    
    
    // --------- convert CIELab back to XYZ using destination white point ---------
    CGFloat correctedXYZ[3] = {0, 0, 0};
    
    [self convertLab2XYZ:curColorLabCh WhitePtXYZ:destWPXYZ ToX:&correctedXYZ[0] ToY:&correctedXYZ[1] ToZ:&correctedXYZ[2]];
    
    
    
    for(int ii = 0; ii < 5; ii++)
        outLab[ii] = curColorLabCh[ii];
    
    
    // --------- convert XYZ to linearized RGB for the output device ---------
    CGFloat correctedLinRGB[3] = {0, 0, 0};
    
    for(int ii = 0; ii <=2; ii++)
    {
        // ----------------- get lin RGB of corrected color-------------
        correctedLinRGB[ii] = const_OutputDevicePriTristimMatInverse[ii * 3] * correctedXYZ[0] + const_OutputDevicePriTristimMatInverse[ii * 3 + 1] * correctedXYZ[1] + const_OutputDevicePriTristimMatInverse[ii * 3 + 2] * correctedXYZ[2];
        
        // IMPORTANT: clip out-of-gamut colors
        if (correctedLinRGB[ii] < 0) {
            correctedLinRGB[ii] = 0;
        }
        else if (correctedLinRGB[ii] > 1.0) {
            correctedLinRGB[ii] = 1.0;
        }
        
        // ----------- get device RGB -------------
        // TO DO: check gamma
        outputDeviceRGB[ii] = powf(correctedLinRGB[ii], 1.0/const_OutputDevice_gamma[ii]);
        
        // copy to output
        outXYZ[ii] = correctedXYZ[ii];
        
        
    }
    
    
    // ----------------- get sRGB -------------
    [self convertXYZ2sRGB:correctedXYZ TosRGB: outputsRGB];
    
    
    return;
    
    
}






/* --------------------------------------------------------------------------------------
 
 Only first three parameters are input to the function, the rest are outputs
 return value::
 -1: error
 0: out-of-gamut colors
 1: everything OK
 
 tag:: 0: none, 1: eye iris, 2: skin, 3: lip, 4: hair
 
 ------------------------------------------------------------------------------------------*/
- (int) getDominantColorOfTaggedPixels: (int)whatTag RGBInput:(CGFloat *) inputRGB WhitePointXYZ: (CGFloat *) srcWhitePtXYZ LuminanceMF:(CGFloat) lumMF sRGBOutput:(CGFloat *) outputsRGB DeviceRGBOutput:(CGFloat *) outputDeviceRGB LabOutput: (CGFloat *) outLab
{
    
    int success = -1;
    
    //
    const float PERCENT_EXTREME_LIGHTNESS_VALUES_TO_DISCARD = 10.0;
    const float PERCENT_EXTREME_HUE_VALUES_TO_DISCARD = 10.0;
    
    const float PERCENT_DEVIATION_FROM_MEAN_LIGHTNESS = 40.0;
    const float PERCENT_DEVIATION_FROM_MEAN_HUE = 40.0;
    
    
    
    // -------- first find pixels with the given tag -----------
    NSIndexSet *taggedPxlIndices = [mArrDictImagePixelData indexesOfObjectsPassingTest:^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
        
        return ([[obj objectForKey:mKEY_PXLTAG] intValue] == whatTag);
        
    }];
    
    
    LogInfo(@"Tagged pixels: %d", [taggedPxlIndices count]);
    
    if ([taggedPxlIndices count] == 0) {
        // no pixel with current tag
        LogError(@"Dominant color computation failure. No pixel with tag = %d", whatTag);
        return success;
    }
    
    NSArray *pxlsWithCurrentTag = [mArrDictImagePixelData objectsAtIndexes:taggedPxlIndices];
    
    float maxLightness = 0, minLightness = 0;
    
    float meanLightness = 0;
    
    for (NSDictionary *dict in pxlsWithCurrentTag)
        meanLightness += [[dict objectForKey:mKEY_CIELAB_L] floatValue];
    
    
    meanLightness = meanLightness/[pxlsWithCurrentTag count];
    
    [self sortDictArrayAndFindMaxAndMin: pxlsWithCurrentTag ForKey: mKEY_CIELAB_L MaxValue: &maxLightness  MinValue: &minLightness];
    
    CGFloat minAllowedLightness = minLightness + (maxLightness - minLightness) * PERCENT_EXTREME_LIGHTNESS_VALUES_TO_DISCARD / 100.0;
    CGFloat maxAllowedLightness = maxLightness - (maxLightness - minLightness) * PERCENT_EXTREME_LIGHTNESS_VALUES_TO_DISCARD / 100.0;
    
    
    // -------- find pixels with lightness 15% above and below min and max lightness respectively -----------
    NSIndexSet *filteredLightnessPxlIndices = [mArrDictImagePixelData indexesOfObjectsPassingTest:^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
        
        if ([[obj objectForKey:mKEY_PXLTAG] intValue] != whatTag)
            return NO;
        
        float Lval = [[obj objectForKey:mKEY_CIELAB_L] floatValue];
        
        BOOL ifLightnessInRange1 = (fabs(Lval - meanLightness)/meanLightness * 100 <= PERCENT_DEVIATION_FROM_MEAN_LIGHTNESS);
        
        // get rid of top 25% and bottom 25% lightness values
        BOOL ifLightnessInRange2 = (Lval >= minAllowedLightness) && (Lval <= maxAllowedLightness);
        
        return (ifLightnessInRange1 && ifLightnessInRange2);
        
    }];
    
    if ([filteredLightnessPxlIndices count] == 0) {
        // no pixel satisfies the lightness condition - though unlikely
        LogError(@"Dominant color computation failure. No pixel with lightness. Tag = %d", whatTag);
        return success;
    }
    
    //NSLog(@"\n%d", [filteredLightnessPxlIndices count]);
    
    
    
    // ---------- find min and max hue of pixels with top 15% lightness -----
    NSArray *filteredLightnessPxlData = [mArrDictImagePixelData objectsAtIndexes:filteredLightnessPxlIndices];
    CGFloat minHue = 0, maxHue = 0;
    
    [self sortDictArrayAndFindMaxAndMin: filteredLightnessPxlData ForKey: mKEY_CIELAB_h MaxValue: &maxHue  MinValue: &minHue];
    
    CGFloat minAllowedHue = minHue + (maxHue - minHue) * PERCENT_EXTREME_HUE_VALUES_TO_DISCARD / 100.0;
    CGFloat maxAllowedHue = maxHue - (maxHue - minHue) * PERCENT_EXTREME_HUE_VALUES_TO_DISCARD / 100.0;
    
    
    
    // ---------- find mean hue of pixels with in-range lightness values -----
    //NSArray *filteredLightnessPxlData = [mArrDictImagePixelData objectsAtIndexes:filteredLightnessPxlIndices];
    CGFloat meanHue = 0;
    
    for (NSDictionary *dict in filteredLightnessPxlData)
        meanHue += [[dict objectForKey:mKEY_CIELAB_h] floatValue];
    
    
    meanHue = meanHue/[filteredLightnessPxlData count];
    
    
    
    
    // ------ find pixels with hue within +/-y% of mean hue and satisfying lightness condition -------
    NSIndexSet *filteredLightnessAndHuePxlIndices = [mArrDictImagePixelData indexesOfObjectsPassingTest:^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
        
        if ([[obj objectForKey:mKEY_PXLTAG] intValue] != whatTag)
            return NO;
        
        float Lval = [[obj objectForKey:mKEY_CIELAB_L] floatValue];
        float hVal = [[obj objectForKey:mKEY_CIELAB_h] floatValue];
        
        BOOL ifLightnessInRange1 = (fabs(Lval - meanLightness)/meanLightness * 100 <= PERCENT_DEVIATION_FROM_MEAN_LIGHTNESS);
        
        // get rid of top 25% and bottom 25% lightness values
        BOOL ifLightnessInRange2 = (Lval >= minAllowedLightness) && (Lval <= maxAllowedLightness);
        
        
        
        BOOL ifHueInRange1, ifHueInRange2;
        
        ifHueInRange1= (hVal >= minAllowedHue) && (hVal <= maxAllowedHue);
        
        // ------ for dark eye/hair, the following is needed -------
        if (fabs(meanHue) < 0.2 && fabs(hVal) < 0.2) {
            ifHueInRange2 = true;
        }
        else {
            ifHueInRange2 = fabs((hVal - meanHue)/meanHue) * 100 <= PERCENT_DEVIATION_FROM_MEAN_HUE;
            
        }
        
        
        return (ifLightnessInRange1 && ifLightnessInRange2 && ifHueInRange1 && ifHueInRange2);
        
    }];
    
    if ([filteredLightnessAndHuePxlIndices count] == 0) {
        // no pixel satisfies the lightness + hue conditions
        LogError(@"Dominant color computation failure. No pixel satisfies lightness + hue criteria. Tag = %d", whatTag);
        return success;
    }
    
    
    LogInfo(@"Final number chosen pixels: %d", [filteredLightnessAndHuePxlIndices count]);
    
    NSArray *filteredLightnessAndHuePxlData = [mArrDictImagePixelData objectsAtIndexes:filteredLightnessAndHuePxlIndices];
    
    
    // ------------ first reset tag for invalid pixels ------------
    // find mArrDictImagePixelData dictionary objects with indices included in taggedPxlIndices, but not filteredLightnessAndHuePxlIndices
    // set pxlTag of these objects to 0
    
    NSIndexSet *wronglyTaggedPxlIdxSet = [taggedPxlIndices indexesPassingTest:^ BOOL (NSUInteger idx, BOOL *stop) {
        
        if (![filteredLightnessAndHuePxlIndices containsIndex: idx]) {
            NSMutableDictionary *dictPxl = [NSMutableDictionary dictionaryWithDictionary:[mArrDictImagePixelData objectAtIndex: idx]];
            
            NSNumber *objTag = [NSNumber numberWithInt:0];
            
            [dictPxl setObject:objTag forKey:mKEY_PXLTAG];
            
            //NSLog(@"\nidx = %d, x=%f, y=%f, L=%f, tag = %d", [[dictPxl objectForKey:mKEY_PXLINDEX] intValue], [[dictPxl objectForKey:mKEY_X] floatValue], [[dictPxl objectForKey:mKEY_Y] floatValue], [[dictPxl objectForKey:mKEY_CIELAB_b] floatValue], [[dictPxl objectForKey:mKEY_PXLTAG] intValue]);
            
            
            [mArrDictImagePixelData replaceObjectAtIndex:idx withObject:dictPxl];
            
            
        }
        
        return (![filteredLightnessAndHuePxlIndices containsIndex: idx]);
    }];
    
    wronglyTaggedPxlIdxSet = nil;
    
    
    
    // --------************* Find dominant CIELAB LCh and
    //                         compute: Lab(dom) -> XYZdom -> RGBout-dom  ****************------------
    
    
    // ------------ get mean CIELAB -----------------
    CGFloat *meanInputColor_RGB = calloc(3, sizeof(float));
    CGFloat *meanOutputColor_SRGB = calloc(3, sizeof(float));
    CGFloat *meanOutputColor_DEVICERGB = calloc(3, sizeof(float));
    CGFloat *dominantColor_CIELAB = calloc(5, sizeof(float));
    
    for (NSDictionary *dict in filteredLightnessAndHuePxlData)
    {
        meanInputColor_RGB[0] += [[dict objectForKey:mKEY_INPUT_R] floatValue];
        meanInputColor_RGB[1] += [[dict objectForKey:mKEY_INPUT_G] floatValue];
        meanInputColor_RGB[2] += [[dict objectForKey:mKEY_INPUT_B] floatValue];
        
        meanOutputColor_SRGB[0] += [[dict objectForKey:mKEY_OUTPUT_SRGB_R] floatValue];
        meanOutputColor_SRGB[1] += [[dict objectForKey:mKEY_OUTPUT_SRGB_G] floatValue];
        meanOutputColor_SRGB[2] += [[dict objectForKey:mKEY_OUTPUT_SRGB_B] floatValue];
        
        meanOutputColor_DEVICERGB[0] += [[dict objectForKey:mKEY_OUTPUT_DEVICERGB_R] floatValue];
        meanOutputColor_DEVICERGB[1] += [[dict objectForKey:mKEY_OUTPUT_DEVICERGB_G] floatValue];
        meanOutputColor_DEVICERGB[2] += [[dict objectForKey:mKEY_OUTPUT_DEVICERGB_B] floatValue];
        
        dominantColor_CIELAB[0] += [[dict objectForKey:mKEY_CIELAB_L] floatValue];
        dominantColor_CIELAB[1] += [[dict objectForKey:mKEY_CIELAB_a] floatValue];
        dominantColor_CIELAB[2] += [[dict objectForKey:mKEY_CIELAB_b] floatValue];
        dominantColor_CIELAB[3] += [[dict objectForKey:mKEY_CIELAB_C] floatValue];
        dominantColor_CIELAB[4] += [[dict objectForKey:mKEY_CIELAB_h] floatValue];
        
    }
    
    
    for (int ii = 0; ii < 5; ii++) {
        outLab[ii] = dominantColor_CIELAB[ii] / [filteredLightnessAndHuePxlData count];
    }
    
    
    for (int ii = 0; ii < 3; ii++) {
        inputRGB[ii] = meanInputColor_RGB[ii] / [filteredLightnessAndHuePxlData count];
        outputsRGB[ii] = meanOutputColor_SRGB[ii] / [filteredLightnessAndHuePxlData count];
        outputDeviceRGB[ii] = meanOutputColor_DEVICERGB[ii] / [filteredLightnessAndHuePxlData count];
    }
    
    
    
    free(meanInputColor_RGB);
    free(meanOutputColor_SRGB);
    free(meanOutputColor_DEVICERGB);
    free(dominantColor_CIELAB);
    
    
    success = YES;
    
    
    
    return success;
    
}

/* --------------------------------------------------------------------------------------
 
 computes min and max from an array of dictionaries, returns sorted array
 
 ------------------------------------------------------------------------------------------*/

- (NSArray *) sortDictArrayAndFindMaxAndMin: (NSArray *) data ForKey: (NSString *) forKey MaxValue: (CGFloat *) maxVal  MinValue: (CGFloat *) minVal
{
    
    NSSortDescriptor *firstDescriptor = [NSSortDescriptor sortDescriptorWithKey: forKey ascending:NO];
    
    //NSSortDescriptor *lastDescriptor;
    //lastDescriptor = [[NSSortDescriptor alloc] initWithKey:CIELAB_h ascending:YES];
    
    NSArray *descriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    
    NSArray* sortedData = [data sortedArrayUsingDescriptors:descriptors];
    
    
    // first object has max L
    *maxVal = [[[sortedData objectAtIndex:0] objectForKey:forKey] floatValue];
    
    // last object has min L
    *minVal = [[[sortedData lastObject] objectForKey:forKey] floatValue];
    
    
    return sortedData;
    
}




/* --------------------------------------------------------------------------------------
 
 This function looks at the eye area and predicts the white point under which the photo
 was captured (e.g. natural daylight, fluorescent, incandescent or mixed lighting)
 
 This function will be called real-time: must minimize loops
 
 
 Note: origin top left( 0,0), x along hor, y along vert
 
 ------------------------------------------------------------------------------------------*/

- (BOOL)estimateSceneWhitePoint:(CGFloat *) meanEyeWhitePointXYZ LuminanceCorrectionFactor:(CGFloat *) lumCF FromWholeLeftEyeArea:(CGRect) wholeEyeArea_Left FromWholeRightEyeArea:(CGRect) wholeEyeArea_Right ImageAreaOfInterest:(CGRect)areaOfInterest LightingType:(int *) lightingType
{
    BOOL success = YES;
    *lightingType = 0;
    int height, width; //, totalPixels;
    
    
    
    // mRawImagePixelData is populated in openColorExtractionSession
    
    int totalEyeAreaSize = wholeEyeArea_Left.size.height * wholeEyeArea_Left.size.width + wholeEyeArea_Right.size.height * wholeEyeArea_Right.size.width;
    
    if(totalEyeAreaSize == 0)
    {
        success = NO;
        // problem with wholeEyeArea parameter
        return success;
    }
    
    
    CGFloat *curPxlRGB = calloc(3, sizeof(float));
    CGFloat *linarizedRGB = calloc(3, sizeof(float));
    CGFloat *curColorXYZ = calloc(3, sizeof(float));
    CGFloat *curColorLabCh = calloc(5, sizeof(float));
    
    
    NSMutableArray *arrDictEyePixelData = [NSMutableArray arrayWithCapacity: totalEyeAreaSize];
    
    
    int origX, origY;  // xx, yy starts from 0
    
    
    CGFloat *lumCorrectedInputColor = calloc(3, sizeof(float));
    CGRect *wholeEyeArea = calloc(2, sizeof(CGRect));
    
    wholeEyeArea[0] = CGRectMake(wholeEyeArea_Left.origin.x, wholeEyeArea_Left.origin.y, wholeEyeArea_Left.size.width, wholeEyeArea_Left.size.height);
    
    wholeEyeArea[1] = CGRectMake(wholeEyeArea_Right.origin.x, wholeEyeArea_Right.origin.y, wholeEyeArea_Right.size.width, wholeEyeArea_Right.size.height);
    
    
    for (int loc = 0 ; loc < 2; ++loc)
    {
        
        origX = (int)wholeEyeArea[loc].origin.x;
        origY = (int)wholeEyeArea[loc].origin.y;
        
        height = wholeEyeArea[loc].size.height;
        width = wholeEyeArea[loc].size.width;
        
        int byteIndex = 0;
        int pxlIndex = 0;
        
        
        for (int jj = origY ; jj < (origY + height); jj++)
        {
            byteIndex = (mBytesPerRow * jj) + origX * mBytesPerPixel;
            
            // objPxlIndex goes from 0 through size of area of interest
            pxlIndex = areaOfInterest.size.width * (jj - areaOfInterest.origin.y) + origX - areaOfInterest.origin.x;
            
            for (int ii = origX ; ii < (origX + width); ii++)
            {
                
                curPxlRGB[0] = (mRawImagePixelData[byteIndex]     * 1.0) / 255.0;
                curPxlRGB[1] = (mRawImagePixelData[byteIndex + 1] * 1.0) / 255.0;
                curPxlRGB[2] = (mRawImagePixelData[byteIndex + 2] * 1.0) / 255.0;
                
                // ---------  linearize RGB ------------
                linarizedRGB[0] = 0; linarizedRGB[1] = 0; linarizedRGB[2] = 0;
                
                for(int kk = 0; kk <=2; kk++) {
                    linarizedRGB[kk] = powf(curPxlRGB[kk], const_InputDevice_gamma[kk]);
                    
                }
                
                
                // ----------------- compute XYZ ---------------------
                
                for(int kk = 0; kk <=2; kk++)
                {
                    // ----------------- get XYZ of current color-------------
                    curColorXYZ[kk] = const_InputDevicePriTristimMat[kk * 3] * linarizedRGB[0] +
                    const_InputDevicePriTristimMat[kk * 3 + 1] * linarizedRGB[1] +
                    const_InputDevicePriTristimMat[kk * 3 + 2] * linarizedRGB[2];
                    
                }
                
                //NSLog(@"\n\nIn colorcorrect: RGB: %f %f %f", inputColor[0], inputColor[1], inputColor[2]);
                //NSLog(@"\nXYZ: %f %f %f", curColorXYZ[0], curColorXYZ[1], curColorXYZ[2]);
                
                
                // ------- convert XYZ to Lab --------
                curColorLabCh[0] = 0; curColorLabCh[1] = 0; curColorLabCh[2] = 0; curColorLabCh[3] = 0; curColorLabCh[4] = 0;
                
                
                [self convertXYZ2Lab:curColorXYZ WhitePtXYZ:const_D65WPXYZ ToL:&curColorLabCh[0] Toa:&curColorLabCh[1] Tob:&curColorLabCh[2] ToChroma:&curColorLabCh[3] ToHue:&curColorLabCh[4]];
                
                //NSLog(@"\t Lab: %f %f %f", curColorLabCh[0], curColorLabCh[1], curColorLabCh[2]);
                
                
                NSNumber *objPxlIndex = [NSNumber numberWithInt:pxlIndex];
                
                NSNumber *objXCoord = [NSNumber numberWithInt:ii];
                NSNumber *objYCoord = [NSNumber numberWithInt:jj];
                
                NSNumber *objINRGB_R = [NSNumber numberWithFloat: curPxlRGB[0]];
                NSNumber *objINRGB_G = [NSNumber numberWithFloat: curPxlRGB[1]];
                NSNumber *objINRGB_B = [NSNumber numberWithFloat: curPxlRGB[2]];
                
                NSNumber *objCIELAB_L = [NSNumber numberWithFloat:curColorLabCh[0]];
                NSNumber *objCIELAB_a = [NSNumber numberWithFloat:curColorLabCh[1]];
                NSNumber *objCIELAB_b = [NSNumber numberWithFloat:curColorLabCh[2]];
                NSNumber *objCIELAB_C = [NSNumber numberWithFloat:curColorLabCh[3]];
                NSNumber *objCIELAB_h = [NSNumber numberWithFloat:curColorLabCh[4]];
                
                
                // get dict corresponding to pxlID
                NSMutableDictionary *dictPxl = [NSDictionary dictionaryWithObjectsAndKeys:
                                                objPxlIndex, mKEY_PXLINDEX, objXCoord, mKEY_X, objYCoord, mKEY_Y,
                                                objINRGB_R, mKEY_INPUT_R, objINRGB_G, mKEY_INPUT_G, objINRGB_B, mKEY_INPUT_B,
                                                objCIELAB_L, mKEY_CIELAB_L, objCIELAB_a, mKEY_CIELAB_a, objCIELAB_b, mKEY_CIELAB_b,
                                                objCIELAB_C, mKEY_CIELAB_C, objCIELAB_h, mKEY_CIELAB_h, nil];
                
                // add to color data dictionary
                [arrDictEyePixelData addObject:dictPxl];
                
                byteIndex += 4;
                pxlIndex++;
                
                
                
            }
        }
    }
    
    free(wholeEyeArea);
    
    free(curPxlRGB);
    free(linarizedRGB);
    free(curColorXYZ);
    free(curColorLabCh);
    free(lumCorrectedInputColor);
    
    
    
    // ----------------- sort in the descending order of lightness ----------------
    
    float maxLightness = 0, minLightness = 0;
    
    NSArray* sortedPxlData = [self sortDictArrayAndFindMaxAndMin: arrDictEyePixelData ForKey: mKEY_CIELAB_L MaxValue: &maxLightness  MinValue: &minLightness];
    
    
    
    [arrDictEyePixelData removeAllObjects];
    arrDictEyePixelData = nil;
    
    
    
    
    // -------- find pixels with top 15% lightness -----------
    NSIndexSet *lightnessFilteredPxlIndices = [sortedPxlData indexesOfObjectsPassingTest:^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
        float val = [[obj objectForKey:mKEY_CIELAB_L] floatValue];
        
        return (val >= 0.85 * maxLightness);
    }];
    
    if ([lightnessFilteredPxlIndices count] == 0) {
        // no pixel satisfies the lightness + hue conditions
        LogError(@"WB estimation Failed. No pixel with top 15%% lightness");
        
        return NO;
    }
    
    
    // ---------- find min and max hue of pixels with top 15% lightness -----
    
    // extreme threshold changed from 10 to 5 on 07/15/2012
    const float PERCENT_EXTREME_HUE_VALUES_TO_DISCARD = 10.0;
    const float PERCENT_DEVIATION_FROM_MEAN_HUE = 40.0;
    
    
    NSArray *filteredPxlData = [sortedPxlData objectsAtIndexes:lightnessFilteredPxlIndices];
    CGFloat minHue = 0, maxHue = 0;
    
    [self sortDictArrayAndFindMaxAndMin: filteredPxlData ForKey: mKEY_CIELAB_h MaxValue: &maxHue  MinValue: &minHue];
    
    CGFloat meanHue = 0;
    
    for (NSDictionary *dict in filteredPxlData)
        meanHue += [[dict objectForKey:mKEY_CIELAB_h] floatValue];
    
    meanHue = meanHue/[filteredPxlData count];
    
    CGFloat minAllowedHue = minHue + (maxHue - minHue) * PERCENT_EXTREME_HUE_VALUES_TO_DISCARD / 100.0;
    CGFloat maxAllowedHue = maxHue - (maxHue - minHue) * PERCENT_EXTREME_HUE_VALUES_TO_DISCARD / 100.0;
    
    
    // -------- find pixels with hue within the min and max allowed hue  -----------
    NSIndexSet *hueFilteredPxlIndices = [filteredPxlData indexesOfObjectsPassingTest:^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
        
        float hVal = [[obj objectForKey:mKEY_CIELAB_h] floatValue];
        
        BOOL ifHueInRange1, ifHueInRange2;
        
        // ifHueInRange1 = (hVal > 1.4 * minHue) && (hVal < 0.6 * maxHue);
        ifHueInRange1 = (hVal >= minAllowedHue) && (hVal <= maxAllowedHue);
        
        ifHueInRange2 = fabs((hVal - meanHue)/meanHue) * 100.0 <= PERCENT_DEVIATION_FROM_MEAN_HUE;
        
        //return (ifHueInRange1 && ifHueInRange2);
        
        return (ifHueInRange1); // changed on 07/15/12 -
        
        
    }];
    
    
    if ([hueFilteredPxlIndices count] == 0) {
        // no pixel satisfies the lightness + hue conditions
        //LogError(@"\nWB estimation Failed. No pixel within 30%% of mean hue");
        LogError(@"\nWB estimation Failed. No pixel outside 10%% of extreme hue");
        
        return NO;
    }
    
    
    filteredPxlData = [sortedPxlData objectsAtIndexes:hueFilteredPxlIndices];
    
    
    CGFloat *meanEyeWPInputRGB = calloc(3, sizeof(float));
    CGFloat *meanEyeWPLab = calloc(3, sizeof(float));
    
    for (NSDictionary *dict in filteredPxlData)
    {
        CGFloat chroma = [[dict objectForKey:mKEY_CIELAB_C] floatValue];
        CGFloat hue = [[dict objectForKey:mKEY_CIELAB_h] floatValue];
        
        meanEyeWPLab[0] += [[dict objectForKey:mKEY_CIELAB_L] floatValue];
        meanEyeWPLab[1] += chroma * cos(hue);
        meanEyeWPLab[2] += chroma * sin(hue);
        
        meanEyeWPInputRGB[0] += [[dict objectForKey:mKEY_INPUT_R] floatValue];
        meanEyeWPInputRGB[1] += [[dict objectForKey:mKEY_INPUT_G] floatValue];
        meanEyeWPInputRGB[2] += [[dict objectForKey:mKEY_INPUT_B] floatValue];
        
    }
    
    for (int ii = 0; ii < 3; ii++) {
        meanEyeWPLab[ii] /= [filteredPxlData count];
        meanEyeWPInputRGB[ii] /= [filteredPxlData count];
        
    }
    
    free(meanEyeWPInputRGB);
    
    
    // re-initialize meanEyeWhitePointXYZ
    for (int ii = 0; ii < 3; ii++)
        meanEyeWhitePointXYZ[ii] = 0;
    
    
    
    // ----------------- get mean eye WP XYZ -----------------
    [self convertLab2XYZ:meanEyeWPLab WhitePtXYZ:const_D65WPXYZ ToX:&meanEyeWhitePointXYZ[0] ToY:&meanEyeWhitePointXYZ[1] ToZ:&meanEyeWhitePointXYZ[2]];
    
    //NSLog(@"\nWP XYZ: %f %f %f", meanEyeWhitePointXYZ[0], meanEyeWhitePointXYZ[1], meanEyeWhitePointXYZ[2]);
    //NSLog(@"\nWP Lab: %f %f %f", meanEyeWPLab[0], meanEyeWPLab[1], meanEyeWPLab[2]);
    
    
    free(meanEyeWPLab);
    
    *lumCF = meanEyeWhitePointXYZ[1]/0.5;
    
    
    
    // verified
    //NSLog(@"\nWP RGB: %f %f %f", brightestPxlRGB[0], brightestPxlRGB[1], brightestPxlRGB[2]);
    //NSLog(@"\nWP XYZ: %f %f %f", whitePointXYZ[0], whitePointXYZ[1], whitePointXYZ[2]);
    
    // ------------ TO DO: analyze C and h to determine lighting type -------------
    *lightingType = 1;
    
    return success;
    
    
    
}



/* --------------------------------------------------------------------------------------
 
 
 
 ------------------------------------------------------------------------------------------*/

- (UIColor *) convertDeviceRGB2sRGB:(UIColor *) deviceRGBColor
{
    //BOOL success = YES;
    UIColor * sRGBColor;
    
    CGFloat colorA = 1.0;
    
    CGFloat *inputColor = calloc(3, sizeof(float));
    
    
    
    [deviceRGBColor  getRed:&inputColor[0] green:&inputColor[1] blue:&inputColor[2] alpha:&colorA];
    
    // --------- first linearize output device RGB ------------
    CGFloat *linarizedRGB = calloc(3, sizeof(float));
    
    for(int ii = 0; ii <=2; ii++)
    {
        if (inputColor[ii] < 0)
        {
            // problem with input color
            inputColor[ii] = 0;
            //success = NO;
        }
        else if(inputColor[ii] > 1)
        {
            // problem with input color
            inputColor[ii] = 1;
            //success = NO;
            
        }
        linarizedRGB[ii] = powf(inputColor[ii], const_OutputDevice_gamma[ii]);
    }
    
    free(inputColor);
    
    
    
    // ----------------- get XYZ -------------
    CGFloat estimatedXYZ[3] = {0,0,0};
    
    for(int ii = 0; ii <=2; ii++) {
        
        estimatedXYZ[ii] = const_OutputDevicePriTristimMat[ii * 3] * linarizedRGB[0] + const_OutputDevicePriTristimMat[ii * 3 + 1] * linarizedRGB[1] + const_OutputDevicePriTristimMat[ii * 3 + 2] * linarizedRGB[2];
        
        
        
    }
    
    
    
    CGFloat *outputColor = calloc(3, sizeof(float));
    
    [self convertXYZ2sRGB:estimatedXYZ TosRGB: outputColor];
    
    
    for(int ii = 0; ii <=2; ii++)
    {
        if (outputColor[ii] < 0)
        {
            // problem with input color
            outputColor[ii] = 0;
            //success = NO;
        }
        if (outputColor[ii] > 1)
        {
            // problem with input color
            outputColor[ii] = 1;
            //success = NO;
        }
        
    }
    
    //NSLog(@"\n To sRGB: %f %f %f", outputColor[0], outputColor[1], outputColor[2]);
    
    sRGBColor = [UIColor colorWithRed:outputColor[0] green:outputColor[1] blue:outputColor[2] alpha:colorA];
    
    free(outputColor);
    
    return sRGBColor;
    
}

/* --------------------------------------------------------------------------------------
 
 This function converts RGB to YCbCr and returns as float values:
 Assumes RGB to be normalized to 1
 
 ------------------------------------------------------------------------------------------*/

- (int) convertRGB2YCbCr:(CGFloat *)linRGBData toY:(CGFloat *)colorY toCb:(CGFloat *)colorCb toCr:(CGFloat *)colorCr
{
    int ret = 0;
    
    CGFloat colorR = linRGBData[0], colorG = linRGBData[1], colorB = linRGBData[2];
    
    
    
    *colorY = 0.299 * colorR + 0.587 * colorG + 0.114 * colorB;
    *colorCb = 0.5 - (0.168736 * colorR) - (0.331264 * colorG) + (0.5 * colorB);
    *colorCr = 0.5 + (0.5 * colorR) - (0.418688 * colorG) - (0.081312 * colorB);
    
    
    // undersaturated or oversaturated color is indicated by return value
    if(colorR > 0.98 || colorR < 0.02 || colorG > 0.98 || colorG < 0.02 || colorB > 0.98 || colorB < 0.02)
        ret = -1;
    else
        ret = 1;
    
    return ret;
    
}


/* --------------------------------------------------------------------------------------
 
 This function converts YCbCr to RGB and returns as float values:
 Assumes RGB to be normalized to 1
 
 ------------------------------------------------------------------------------------------*/

- (int) convertYCbCr2RGB:(CGFloat *)YCbCrData toR:(CGFloat *)colorR toG:(CGFloat *)colorG toB:(CGFloat *)colorB
{
    int ret = 0;
    
    CGFloat colorY = YCbCrData[0], colorCb = YCbCrData[1], colorCr = YCbCrData[2];
    
    
    *colorR = colorY + 1.402 * (colorCr - 0.5);
    *colorG = colorY - 0.34414 * (colorCb - 0.5) - 0.71414 * (colorCr - 0.5);
    *colorB = colorY + 1.772 * (colorCb - 0.5);
    
    
    // undersaturated or oversaturated color is indicated by return value
    if(*colorR > 0.98 || *colorR < 0.02 || *colorG > 0.98 || *colorG < 0.02 || *colorB > 0.98 || *colorB < 0.02)
        ret = -1;
    else
        ret = 1;
    
    return ret;
    
}


/* --------------------------------------------------------------------------------------
 
 This function converts XYZ to CIELAB L*, a*, b*, C* and h*, and returns as float values:
 
 ------------------------------------------------------------------------------------------*/

- (int) convertXYZ2Lab:(CGFloat *)XYZData WhitePtXYZ:(CGFloat *)XYZnData ToL:(CGFloat *)colorL Toa:(CGFloat *)colora Tob:(CGFloat *)colorb ToChroma:(CGFloat *)colorC ToHue:(CGFloat *)colorh
{
    int ret = 0;
    
    CGFloat *normalizedXYZ = calloc(3, sizeof(float));
    CGFloat *func = calloc(3, sizeof(float));
    
    
    // -------normalize XYZ------------
    for (int ii = 0; ii < 3; ii++)
    {
        
        if (XYZnData[ii] == 0)
            normalizedXYZ[ii] = 0;
        else
            normalizedXYZ[ii] = XYZData[ii]/XYZnData[ii];
        
        if(normalizedXYZ[ii] > 0.008856)
            func[ii] = powf(normalizedXYZ[ii], (1.0/3.0));
        else
            func[ii] = 7.787 * normalizedXYZ[ii] + 16.0/116.0;
        
    }
    
    
    *colorL = 116.0 * func[1] - 16.0;
    *colora = 500.0 * (func[0] - func[1]);
    *colorb = 200.0 * (func[1] - func[2]);
    
    *colorC = powf((powf(*colora, 2.0) + powf(*colorb, 2.0)), 0.5);
    
    if (*colora != 0) {
        *colorh = atan2f(*colorb, *colora); // * 180.0/3.1416;
    }
    else
        *colorh = 1.5708; // 90.0;
    
    
    // undersaturated or oversaturated color is indicated by return value
    if(*colorL > 98.0 || *colorL < 2)
        ret = -1;
    else
        ret = 1;
    
    
    
    free(normalizedXYZ);
    free(func);
    
    return ret;
    
}

/* --------------------------------------------------------------------------------------
 
 This function converts CIELAB L*, a*, b*, to XYZ, and returns as float values:
 
 ------------------------------------------------------------------------------------------*/

- (int) convertLab2XYZ:(CGFloat *)LabData WhitePtXYZ:(CGFloat *)XYZnData ToX:(CGFloat *)colorX ToY:(CGFloat *)colorY ToZ:(CGFloat *)colorZ
{
    int ret = 0;
    
    
    
    CGFloat term1 = (LabData[0] + 16)/116;
    
    
    // --------X = Xn * ((L* + 16)/116 + a*/500)^3--------
    CGFloat term2 = term1 + LabData[1]/500.0;
    
    *colorX = XYZnData[0] * powf(term2, 3.0);
    
    
    // --------Y = Yn * ((L* + 16)/116)^3--------
    *colorY = XYZnData[1] * powf(term1, 3.0);
    
    
    // --------Z = Zn * ((L* + 16)/116 - b*/200)^3--------
    CGFloat term3 =  term1 - LabData[2]/200;
    
    *colorZ = XYZnData[2] * powf(term3, 3.0);
    
    
    // undersaturated or oversaturated color is indicated by return value
    if(*colorY > 0.98 || *colorY < 0.02)
        ret = -1;
    else
        ret = 1;
    
    /* // verified
     NSLog(@"\n In Lab2XYZ. Lab: %f %f %f", LabData[0], LabData[1], LabData[2]);
     NSLog(@"\n In Lab2XYZ. XYZn: %f %f %f", XYZnData[0], XYZnData[1], XYZnData[2]);
     NSLog(@"\n In Lab2XYZ. XYZ: %f %f %f", *colorX, *colorY, *colorZ);
     */
    
    
    
    return ret;
    
}



/* --------------------------------------------------------------------------------------
 
 This function takes XYZ values of a color (float values) and computes
 sRGB-type RGB values.
 
 IMPORTANT NOTE (02/26/12): insead of sRGB gamma of 2.4, iPhone gamma is being applied.
 Function to be updated after further research.
 
 TO DO: Check the role of color space context while forming image
 
 Being called from colorCorrectInputPixel()
 
 ------------------------------------------------------------------------------------------*/

- (void) convertXYZ2sRGB:(CGFloat *) objXYZ TosRGB: (CGFloat *) objsRGB
{
    
    CGFloat linarizedRGB[3] = {0,0,0}, tempRGB[3] = {0,0,0};
    
    CGFloat matXYZ2sRGB[9] = {3.2406, -1.5372, -0.4986, -0.9689, 1.8758, 0.0415, 0.0557, -0.2040, 1.0570};
    
    for(int ii = 0; ii <=2; ii++) {
        
        linarizedRGB[ii] = matXYZ2sRGB[ii * 3] * objXYZ[0] + matXYZ2sRGB[ii * 3 + 1] * objXYZ[1] + matXYZ2sRGB[ii * 3 + 2] * objXYZ[2];
        
        if (linarizedRGB[ii] > 1) linarizedRGB[ii] = 1;
        if (linarizedRGB[ii] < 0) linarizedRGB[ii] = 0;
        
    }
    
    
    for (int ii = 0; ii <= 2; ii++)
    {
        if (linarizedRGB[ii] <= 0.0031308)
            tempRGB[ii] = linarizedRGB[ii] * 12.92;
        else
        {
            
            tempRGB[ii] = powf(linarizedRGB[ii], (1.0/2.4)) * 1.055 - 0.055;
            
        }
        
        objsRGB[ii] = tempRGB[ii];
        
    }
    
    //NSLog(@"\n In XYZ2sRGB. XYZ: %f %f %f", outputColor[0], outputColor[1], outputColor[2]);
    
    return;
}




/* --------------------------------------------------------------------------------------
 
 This function converts RGB float values to YUV and returns as a UIColor:
 To be improved...
 
 ------------------------------------------------------------------------------------------*/

- (int) convertRGB2YUV:(UIColor *)rgbData toY:(CGFloat *)colorY toU:(CGFloat *)colorU toV:(CGFloat *)colorV
{
    CGFloat matRGB2YUV[9] =  {0.299, 0.587, 0.114, -0.14713, -0.28886, 0.436, 0.615, -0.51499, -0.10001};
    CGFloat colorR = 0, colorG = 0, colorB = 0, colorA = 0;
    
    
    [rgbData getRed:&colorR green:&colorG blue:&colorB alpha:&colorA];
    
    // exclude undersaturated or oversaturated colors
    if(colorR > 0.98 || colorR < 0.02 || colorG > 0.98 || colorG < 0.02 || colorB > 0.98 || colorB < 0.02)
        return -1;
    
    
    *colorY = matRGB2YUV[0] * colorR + matRGB2YUV[1] * colorG + matRGB2YUV[2] * colorB;
    *colorU = matRGB2YUV[3] * colorR + matRGB2YUV[4] * colorG + matRGB2YUV[5] * colorB;
    *colorV = matRGB2YUV[6] * colorR + matRGB2YUV[7] * colorG + matRGB2YUV[8] * colorB;
    
    return 1;
    
}

/* --------------------------------------------------------------------------------------
 
 TO BE DISCARDED
 
 
 This function takes an image (ImageRef object) and returns an NSArray of UIColor objects
 with the raw color data
 
 This function will also be called real-time: can we avoid loops??
 
 
 Note: origin top left( 0,0), x along hor, y along vert
 
 ------------------------------------------------------------------------------------------*/

// Metadata and Options data for the image are generated in this function
- (void) saveMetaAndOpts: (CFMutableDictionaryRef *) dictMetaData
{
    
    *dictMetaData = CFDictionaryCreateMutable(nil, 0,
                                              &kCFTypeDictionaryKeyCallBacks,  &kCFTypeDictionaryValueCallBacks);
    
    // save a dictionary of the image properties
    CFDictionaryRef jfifProfs = CFDictionaryGetValue(*dictMetaData, kCGImagePropertyJFIFDictionary);
    
    CFMutableDictionaryRef jfifProfsMut;
    
    if (jfifProfs)
        jfifProfsMut = CFDictionaryCreateMutableCopy(nil, 0, jfifProfs);
    else
        jfifProfsMut = CFDictionaryCreateMutable(nil, 0,
                                                 &kCFTypeDictionaryKeyCallBacks,  &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(*dictMetaData, kCGImagePropertyJFIFDictionary, jfifProfsMut);
    
    CFRelease(jfifProfsMut);
    
    const float picCompQuality = 1.0f; // JPEGHigherQuality - no lossy compression
    
    CFNumberRef qualityNum = CFNumberCreate(0, kCFNumberFloatType, &picCompQuality);
    
    if ( qualityNum ) {
        
        CFDictionarySetValue(*dictMetaData, kCGImageDestinationLossyCompressionQuality, qualityNum);
        
        CFRelease( qualityNum );
    }
    
    
    
    return;
    
}




/* --------------------------------------------------------------------------------------
 
 TO BE DISCARDED
 
 
 This function takes an image (ImageRef object) and returns an NSArray of UIColor objects
 with the raw color data
 
 This function will also be called real-time: can we avoid loops??
 
 
 Note: origin top left( 0,0), x along hor, y along vert
 
 ------------------------------------------------------------------------------------------*/

- (NSArray*) getRGBPixelDataFromImage:(CGImageRef)imageRef atRect:(CGRect)areaOfInterest
{
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:(areaOfInterest.size.width * areaOfInterest.size.height)];
    
    
    // mRawImagePixelData is populated in openColorExtractionSession
    
    // xx, yy starts from 0
    int xx = (int)areaOfInterest.origin.x;
    int yy = (int)areaOfInterest.origin.y;
    
    
    for (int jj = yy ; jj < (int)areaOfInterest.size.height ; ++jj)
    {
        for (int ii = xx ; ii < (int)areaOfInterest.size.width ; ++ii)
        {
            int byteIndex = (mBytesPerRow * jj) + ii * mBytesPerPixel;
            
            CGFloat red   = (mRawImagePixelData[byteIndex]     * 1.0) / 255.0;
            CGFloat green = (mRawImagePixelData[byteIndex + 1] * 1.0) / 255.0;
            CGFloat blue  = (mRawImagePixelData[byteIndex + 2] * 1.0) / 255.0;
            CGFloat alpha = (mRawImagePixelData[byteIndex + 3] * 1.0);
            byteIndex += 4;
            
            UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            
            
            [result addObject:acolor];
        }
    }
    
    
    
    return result;
    
}



/* --------------------------------------------------------------------------------------
 
 TO BE DISCARDED
 
 This function looks at simple image statistics and predicts whether the photo was captured
 under natural daylight, fluorescent, incandescent or mixed lighting
 
 This function will be called real-time: must minimize loops
 
 
 Note: origin top left( 0,0), x along hor, y along vert
 
 ------------------------------------------------------------------------------------------*/

- (int)estimateLightingCondition:(CGImageRef) imageRef
{
    int lightingType = 0;
    CGRect areaOfInterest = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    NSArray *imgData = nil;
    
    imgData = [self getRGBPixelDataFromImage:imageRef atRect:areaOfInterest];
    
    
    
    
    
    int totalInGamutPixels = 0;
    
    for(UIColor *acolor in imgData)
    {
        CGFloat colorY = 0, colorU = 0, colorV = 0;
        
        
        if([self convertRGB2YUV:acolor toY:&colorY toU:&colorU toV:&colorV] < 0)
            continue;
        
        
        //avColorR += colorR; avColorG += colorG; avColorB += colorB; avColorA += colorA;
        
        totalInGamutPixels++;
        
    }
    
    
    lightingType = 1;
    
    return lightingType;
}


/* --------------------------------------------------------------------------------------
 
 
 ------------------------------------------------------------------------------------------*/

static NSString* ImageIOLocalizedString (NSString* key)
{
    static NSBundle* b = nil;
    
    if (b==nil)
        b = [NSBundle bundleWithIdentifier:@"com.apple.ImageIO.framework"];
    
    return [b localizedStringForKey:key value:key table: @"CGImageSource"];
}

/*
 
 Key = Exif Properties, val = {
 ApertureValue = "2.526069";
 BrightnessValue = "3.907037";
 ColorSpace = 1;
 ComponentsConfiguration =     (
 1,
 2,
 3,
 0
 );
 ExifVersion =     (
 2,
 2,
 1
 );
 ExposureMode = 0;
 ExposureProgram = 2;
 ExposureTime = "0.008333334";
 FNumber = "2.4";
 Flash = 32;
 FlashPixVersion =     (
 1,
 0
 );
 FocalLength = "3.85";
 ISOSpeedRatings =     (
 160
 );
 MeteringMode = 5;
 PixelXDimension = 480;
 PixelYDimension = 640;
 SceneCaptureType = 0;
 SensingMethod = 2;
 Sharpness = 0;
 ShutterSpeedValue = "6.912383";
 WhiteBalance = 0;
 }
 
 */


/* --------------------------------------------------------------------------------------
 
 Build image property tree for display of image properties in the
 image information panel
 
 ------------------------------------------------------------------------------------------*/
/*
 - (BOOL) getExifMetadata:(NSURL *) imgURL ExposureTime: (float *)exposureTime ApertureValue: (float *)aperture Sensitivity: (float *)sensitivity BrightnessValue: (float *)brightness  ShutterSpeedValue: (float *)shutterSpeed
 {
 
 BOOL success = NO;
 
 
 CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)imgURL, NULL);
 CFDictionaryRef metaData;
 
 if (!source)
 return(success);
 
 // get image properties (height, width, depth, metadata etc.) for display
 metaData = (CFMutableDictionaryRef)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
 
 NSDictionary* metaDict = (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
 
 
 NSString* key = @"{Exif}";
 //NSString* locKey = ImageIOLocalizedString(key);
 
 id obj = [metaDict objectForKey:key];
 
 //NSLog(@"\nKey = %@, val = %@", locKey, obj);
 
 
 id expVal = [obj valueForKey:@"ExposureTime"];
 id apVal = [obj valueForKey:@"ApertureValue"];
 id bgtVal = [obj valueForKey:@"BrightnessValue"];
 id senVal = [obj valueForKey:@"ISOSpeedRatings"];
 id shutterVal = [obj valueForKey:@"ShutterSpeedValue"];
 
 *exposureTime = [expVal floatValue];
 *aperture = [apVal floatValue];
 *brightness = [bgtVal floatValue];
 *sensitivity = (float)[[senVal objectAtIndex:0] unsignedIntValue];
 *shutterSpeed = [shutterVal floatValue];;
 
 //NSLog(@"\n%f %f %f %f", *exposure, *aperture, *brightness, *sensitivity);
 
 
 
 return(success);
 }
 */


@end
