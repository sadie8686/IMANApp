/*--------------------------------------------------------------------------
 CMCamCaptureManager.m
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar 
 
 Created by Abhijit Sarkar on 2012/02/04
 
 Description: 
 Code for camera capture manager responsible for all capture functionalities
 
 
 
 Revision history:
 2012/02/05 - by AS, added major functionalities
 2012/02/14 - by AS, fixed bugs, added code to save image in Documents folder
 2012/03/16 - by AS, fixed orientation issue, set size to 640x480
  2012/05/19 - by AS, added real-time exposure control
 
 
 Existing Problems:
 (date) - 
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/


#import "CMCamCaptureManager.h"
#import "CMCamUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AssertMacros.h>
#import <ImageIO/ImageIO.h>
#import <CoreImage/CoreImage.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "Logging.h"

//@interface CMCamCaptureManager (RecorderDelegate) <AVCamRecorderDelegate>
//@end

// -----------------------------------------------------------------------------------------
// Following block of code comes from SquareCam example

#pragma mark-

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size);
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut);
static CGContextRef CreateCGBitmapContextForSize(CGSize size);


static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size) 
{	
	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
	CVPixelBufferRelease( pixelBuffer );
}



// create a CGImage with provided pixel buffer, pixel buffer must be uncompressed kCVPixelFormatType_32ARGB or kCVPixelFormatType_32BGRA
// ******************************* will use this function output for image statistics in future


static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut) 
{	
	OSStatus err = noErr;
	OSType sourcePixelFormat;
	size_t width, height, sourceRowBytes;
	void *sourceBaseAddr = NULL;
    CGColorSpaceRef colorspace = NULL;
	CGDataProviderRef provider = NULL;
	CGImageRef image = NULL;
    
	CGBitmapInfo bitmapInfo;
	
	
	sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
    
	if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
	else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	else
		return -95014; // only uncompressed pixel formats
	
	sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
	width = CVPixelBufferGetWidth( pixelBuffer );
	height = CVPixelBufferGetHeight( pixelBuffer );
    
    LogInfo(@"Image captured: size (%zu, %zu)", width, height);
	
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
	
	colorspace = CGColorSpaceCreateDeviceRGB();
    
    CVPixelBufferRetain( pixelBuffer );
    
	provider = CGDataProviderCreateWithData( (void *) pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer);
    
	
	image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
	
bail:
	if ( err && image ) {
		CGImageRelease( image );
		image = NULL;
	}
	if ( provider ) CGDataProviderRelease( provider );
	if ( colorspace ) CGColorSpaceRelease( colorspace );
    
	*imageOut = image;
    
	return err;
}



// utility used by newSquareOverlayedImageForFeatures
static CGContextRef CreateCGBitmapContextForSize(CGSize size)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow = (size.width * 4);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate (NULL,
									 size.width,
									 size.height,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
	CGContextSetAllowsAntialiasing(context, NO);
    CGColorSpaceRelease( colorSpace );
    return context;
}




#pragma mark-

@interface UIImage (RotationMethods)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
@end

@implementation UIImage (RotationMethods)

// function not clear
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees 
{   
    
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
	CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	rotatedViewBox = nil;
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	// Rotate the image context
	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0); // rotatedSize.height/rotatedSize.width
	//CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
	CGContextDrawImage(bitmap, CGRectMake(-w/2, -h/2, w, h), [self CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}

@end

// -----------------------------------------------------------------------------------------





#pragma mark -
@interface CMCamCaptureManager (InternalUtilityMethods)
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;

- (NSURL *) docFolderURL;
- (void) removeFile:(NSURL *)outputFileURL;
- (void) copyFileToDocuments:(NSURL *)fileURL;

@end


#pragma mark -
@implementation CMCamCaptureManager



@synthesize session;
@synthesize orientation;
@synthesize videoInput;
@synthesize videoOutput;

@synthesize currentDevice;
@synthesize isUsingFrontFacingCamera;

@synthesize stillImageOutput;

@synthesize deviceConnectedObserver;
@synthesize deviceDisconnectedObserver;

@synthesize delegate;




- (id) init
{
    self = [super init];
    if (self != nil) {
		__block id weakSelf = self;
        void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
			BOOL sessionHasDeviceWithMatchingMediaType = NO;
			NSString *deviceMediaType = nil;
			
            // check if device has video
			if ([device hasMediaType:AVMediaTypeVideo])
                deviceMediaType = AVMediaTypeVideo;
			
            // find which of session inputs has video 
			if (deviceMediaType != nil) {
				for (AVCaptureDeviceInput *input in [session inputs])
				{
					if ([[input device] hasMediaType:deviceMediaType]) {
						sessionHasDeviceWithMatchingMediaType = YES;
						break;
					}
				}
				
				if (!sessionHasDeviceWithMatchingMediaType) {
					NSError	*error;
					AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
					if ([session canAddInput:input])
						[session addInput:input];
				}				
			}
            
			if ([delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
				[delegate captureManagerDeviceConfigurationChanged:self];
			}			
        };
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
            
            if ([device hasMediaType:AVMediaTypeVideo]) {
				[session removeInput:[weakSelf videoInput]];
				[weakSelf setVideoInput:nil];
			}
			
			if ([delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
				[delegate captureManagerDeviceConfigurationChanged:self];
			}			
        };
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        // add observer to notify when a device is connected or disconnected
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];
        
        // notify when orientation is changed
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        
        
		orientation = AVCaptureVideoOrientationPortrait;
        
    }
    
    return self;
}




- (BOOL) setupSession
{
    BOOL success = YES;
    
	// Set torch and flash mode to off
	if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOff]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeOff];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
	if ([[self backFacingCamera] hasTorch]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeOff]) {
				[[self backFacingCamera] setTorchMode:AVCaptureTorchModeOff];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
	
    // Init the device inputs
    
    currentDevice = nil; 
    
    // use front camera if available, otherwise back camera
    if ([self frontFacingCamera]) {
        currentDevice = [self frontFacingCamera];      
        isUsingFrontFacingCamera = YES;
    }
    else if([self backFacingCamera]) {
        currentDevice = [self backFacingCamera];
        isUsingFrontFacingCamera = NO;
    }
    else {
        // no camera - PROBLEM: TO BE HANDLED suitably ???
        isUsingFrontFacingCamera = NO;
        success = NO;
        return success;
    }
    
    
    // Create session 
    session = [[AVCaptureSession alloc] init];
    
    [session beginConfiguration]; //added 06/30/12
    
    
    
    if([session canSetSessionPreset:AVCaptureSessionPreset352x288]) {
        session.sessionPreset = AVCaptureSessionPreset352x288;
    }
    else if([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        session.sessionPreset = AVCaptureSessionPresetMedium;
    }
    else
	    [session setSessionPreset:AVCaptureSessionPreset640x480];
    

    
    // Setup the video input
    videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:currentDevice error:nil];
    
    
    // Setup the still image file output 
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    
    // Make a video data output
	videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoOutput setVideoSettings:rgbOutputSettings];
	[videoOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    
    
    // set the appropriate pixel format / image type output setting
    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
        
    // Add inputs and output to the capture session
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    
    if ([session canAddOutput:videoOutput]) {
        [session addOutput:videoOutput];
    }
    
    [[videoOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
    if ([session canAddOutput:stillImageOutput]) {
        [session addOutput:stillImageOutput];
    }
    
    // Following are NEEDED     
    [self setStillImageOutput:stillImageOutput];
    [self setVideoInput:videoInput];
    [self setVideoOutput:videoOutput];
    
    [session commitConfiguration]; //added 06/30/12
    
    [self setSession:session];
    
    
    
    // ------------------ configure camera: turn off white balance, set focus to center ----------
    /*
    BOOL retExp = [self updateDeviceExposureSetting:CGPointZero];
    BOOL retWB = [self updateDeviceWhiteBalanceSettings:1];
    
    if (!retExp || !retWB) {
        success = NO;
    }
        
    */ 
    
    // do all at once rather than calling individual functions
    NSError *error = nil;
    
    if([currentDevice lockForConfiguration:&error]) 
    {   
        // set focus to the center of the face (screen)
        if([currentDevice isFocusPointOfInterestSupported]) 
            [currentDevice setFocusPointOfInterest:CGPointMake(.5f, .5f)];
        
        // use continuous white balance
        if([currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
            currentDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
            
        }        
         
        /*
        if([currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            currentDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            
        }
        */
        
        if([currentDevice isExposurePointOfInterestSupported]) 
            [currentDevice setExposurePointOfInterest: CGPointMake(0.5f, 0.5f)];
        
        
        // update exposure continuously
        if([currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])            
            [currentDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        
        
        [currentDevice unlockForConfiguration];
        
    }
    
    else {
        // could not lock - PROBLEM: TO BE HANDLED suitably
        
        success = NO;
    }
    
    
    
    
    return success;
}




/* -------------------------------------------------------------------------------------- 
 
 
 
 ---------------------------------------------------------------------------------------*/
- (void) closeSession
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:[self deviceConnectedObserver]];
    [notificationCenter removeObserver:[self deviceDisconnectedObserver]];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[self session] stopRunning];
    
    if (cgImageMetadata)
        CFRelease(cgImageMetadata);
    
    if (mCapturedCGImage)
        CFRelease(mCapturedCGImage);
    
    
    session = nil;
    videoInput = nil;
    videoOutput = nil;
    stillImageOutput = nil;
    
    
}



/* -------------------------------------------------------------------------------------- 
 
 called asynchronously
 
 ---------------------------------------------------------------------------------------*/
- (BOOL) getExposurePointOfInterest:(CVPixelBufferRef) pixelBuffer AreaOfInterest:(CGRect) aoi PreviewBox: (CGRect) previewBox WidthScaleFactor: (float) widthSF HeightScaleFactor: (float) heightSF IsImageMirrored: (BOOL) isMirrored ExposurePointInViewLayer: (CGPoint *) expPointInViewLayer ExposurePointInDeviceCoords: (CGPoint *) expPointInDeviceCoords

//- (BOOL) getExposurePointOfInterest:(CGImageRef) imageRef AreaOfInterest:(CGRect) aoi PreviewBox: (CGRect) previewBox WidthScaleFactor: (float) widthSF HeightScaleFactor: (float) heightSF IsImageMirrored: (BOOL) isMirrored ExposurePointInViewLayer: (CGPoint *) expPointInViewLayer ExposurePointInDeviceCoords: (CGPoint *) expPointInDeviceCoords
{
    BOOL success = NO;
    
    
    CGImageRef imageRef = NULL;
    
    OSStatus err = CreateCGImageFromCVPixelBuffer(pixelBuffer, &imageRef);
    
    if(err)
    {        
        LogError(@"Exposure update failed, buffer could not be obtained <<<<<<");        
        return success;
        
    }
     
    

    NSUInteger imgWidth_Landscape = CGImageGetWidth(imageRef);
    NSUInteger imgHeight_Landscape = CGImageGetHeight(imageRef);
    
    
    // --------------- get raw RGB data ------------------
    unsigned char *rawImagePixelData = calloc(imgHeight_Landscape * imgWidth_Landscape * 4, sizeof(unsigned char));    
    
    
    //  create bitmap context 
    CGContextRef context = [self createRGBBitmapContext: rawImagePixelData  Width: imgWidth_Landscape Height: imgHeight_Landscape];
    
    // draw image - mRawImagePixelData gets populated
    CGContextDrawImage(context, CGRectMake(0, 0, imgWidth_Landscape, imgHeight_Landscape), imageRef);  
    
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
        
    int startX = (int)(0.15 * imgWidth_Landscape); 
    int startY = (int)(0.15 * imgHeight_Landscape); 
    int endX = (int)(0.8 * imgWidth_Landscape); 
    int endY = (int)(0.85 * imgHeight_Landscape); 
    
    /*
     // 
     int startX = (int)aoi.origin.x;
     int startY = (int)aoi.origin.y;
     int endX = startX + (int)aoi.size.width;
     int endY = startY + (int)aoi.size.height;
     */
    
    
    CGFloat curPxlR = 0, curPxlG = 0, curPxlB = 0;
    CGFloat maxR = 0, maxG = 0, maxB = 0;
    
    bool brightestPixelFound = false;
    
    NSUInteger bytesPerRow = imgWidth_Landscape * 4;
    NSUInteger bytesPerPixel = 4;
    

    CGPoint brightestPixelCoords = CGPointZero;
    
    for (int jj = startY ; jj < endY; jj+= 3)
    {               
        for (int ii = startX ; ii < endX; ii+= 3)
        {
            int byteIndex = (bytesPerRow * jj) + ii * bytesPerPixel;
            
            curPxlR = (rawImagePixelData[byteIndex]     * 1.0) / 255.0;
            curPxlG = (rawImagePixelData[byteIndex + 1] * 1.0) / 255.0;
            curPxlB = (rawImagePixelData[byteIndex + 2] * 1.0) / 255.0;
            
            // if values are higher than 0.8, look no further
            if (curPxlR > 0.9 && curPxlG > 0.9 && curPxlB > 0.9) 
            {                
                // (ii,jj) correspond to landscape mode - convert to portrait
                brightestPixelCoords = CGPointMake(ii, jj);
                brightestPixelFound = true;
                
                break;
            }
            
            if (curPxlR > maxR && curPxlG > maxG && curPxlB > maxB) 
            {
                // store max values in case there is no pixel > 0.9
                maxR = curPxlR;
                maxG = curPxlG;
                maxB = curPxlB;
                
                // (ii,jj) correspond to landscape mode - convert to portrait
                brightestPixelCoords = CGPointMake(ii, jj);
            }            
            
        }
        
        if (brightestPixelFound) 
            break;
        
    }
    
    
    free(rawImagePixelData);
    
    //brightestPixelCoords = CGPointMake(imgWidth_Landscape * 0.9, imgHeight_Landscape * 0.9);
    
    if (brightestPixelCoords.x == 0 && brightestPixelCoords.y == 0) {
        return success;
    }
    
    // flip x and y and scale
    CGRect areaAroundExposurePoint = CGRectMake(brightestPixelCoords.y * widthSF, brightestPixelCoords.x * heightSF, 0, 0); 
    
    
     if (isMirrored)
         areaAroundExposurePoint = CGRectOffset(areaAroundExposurePoint, previewBox.origin.x + previewBox.size.width - areaAroundExposurePoint.size.width - (areaAroundExposurePoint.origin.x * 2), previewBox.origin.y);
     else 
         areaAroundExposurePoint = CGRectOffset(areaAroundExposurePoint, previewBox.origin.x, previewBox.origin.y);
     
    
    
    // X-AXIS NEEDS ADDITIONAL SCALING of 0.8, SINCE CHANGE IN IMAGE SIZE TO (320 X 460) WAS MADE
    // NOT SURE WHY
    areaAroundExposurePoint.origin.x *= 0.8; 
    
    
    CGPoint expPtImg = CGPointMake(areaAroundExposurePoint.origin.x, areaAroundExposurePoint.origin.y);
    CGPoint expPtDevice;
    
    
    expPtDevice.y = 1 - expPtImg.x/previewBox.size.width;
    expPtDevice.x = expPtImg.y/previewBox.size.height;
    
    //expPtDevice.x = brightestPixelCoords.x/(imgWidth_Landscape * 0.9);
    //expPtDevice.y = brightestPixelCoords.y/(imgHeight_Landscape * 0.9);
    
    
    *expPointInViewLayer = expPtImg;
    *expPointInDeviceCoords = expPtDevice;
    
    
        
    // -------- FOR TEST ------
    //NSLog(@"expPointInViewLayer: (%4.1f, %4.1f) <<<<<<", expPtImg.x, expPtImg.y);
    
    /*
    if ([[self delegate] respondsToSelector:@selector(captureManagerExposurePointOfInterestAvailable:)]) {
        [[self delegate] captureManagerExposurePointOfInterestAvailable:self ExposurePointInViewLayer:(CGPoint) expPointInViewLayer ExposurePointInDeviceCoords: expPointInDeviceCoords];                 
    }
     */
    
    success = YES;
    
    return success;
    
}



/* -------------------------------------------------------------------------------------- 
 exposurePointOfInterest = (0,0): e.g. when the camera is started for the first time, 
 continuous auto-exposure
 otherwise, auto-exposure at pt of interest and locked
 
 ---------------------------------------------------------------------------------------*/
- (BOOL) updateDeviceExposureSetting: (CGPoint) exposurePointOfInterest
{
    BOOL success = NO;
        
    NSError *error = nil;    
    
        
    // ----------------- update exposure -------------------------
    if (exposurePointOfInterest.x == 0 && exposurePointOfInterest.y == 0) 
    {
        if([currentDevice lockForConfiguration:&error])             
        {
            if([currentDevice isExposurePointOfInterestSupported]) 
                [currentDevice setExposurePointOfInterest: CGPointMake(0.5f, 0.5f)];
            
            if([currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                //NSLog(@"Exp setting being updated cont auto exp ");
                [currentDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            
            [currentDevice unlockForConfiguration];
            
            success = YES;

        }
        
                
    }
    else 
    {
        if([currentDevice lockForConfiguration:&error])             
        {            
            if([currentDevice isExposurePointOfInterestSupported]) 
                [currentDevice setExposurePointOfInterest: exposurePointOfInterest];
            
            
            if([currentDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose])
            {                
                [currentDevice setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            
            //if([currentDevice isExposureModeSupported:AVCaptureExposureModeLocked])
            //    [currentDevice setExposureMode:AVCaptureExposureModeLocked];
            
            [currentDevice unlockForConfiguration];
            
            success = YES;
            
            
        }
        else {
            LogError(@"Device could not be locked ");
        }
        
                
    }
        
    
    //NSLog(@"Exposure update at (%4.3f, %4.3f): Success=%d", exposurePointOfInterest.x, exposurePointOfInterest.y, success);
    
    return success;
    
}


/* -------------------------------------------------------------------------------------- 
  sayWhen = 1, when the camera is started for the first time, continuous white balance
  sayWhen = 2, once at arm's length, white balance is locked
 ---------------------------------------------------------------------------------------*/
- (BOOL) updateDeviceWhiteBalanceSettings:(int) sayWhen
{
    BOOL success = NO;
    
    NSError *error = nil;
    
    
    
    if(sayWhen == 1) 
    {
        // when the camera is started for the first time, white balance 
        // is adjusted continuously
        
        if([currentDevice lockForConfiguration:&error]) 
        {
            
            if([currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) 
            {
                currentDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
                
                success = YES;
                
            }
                        
            [currentDevice unlockForConfiguration];
                        
        }
                
        
    }
    else if(sayWhen == 2) 
    {
        
        // lock white balance 
        if([currentDevice lockForConfiguration:nil]) 
        {     
            if([currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) 
                currentDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
            
            if([currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) 
                currentDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;                
            
            
            [currentDevice unlockForConfiguration];
            
            success = YES;
            
        }
                
    }
    
    //NSLog(@"WB update done: when=%d, ret=%d ", sayWhen, success);
    
    
    return success;
    
}


/* -------------------------------------------------------------------------------------- 
 
 creates an RGB bitmap context
 
 ------------------------------------------------------------------------------------------*/
- (CGContextRef) createRGBBitmapContext: (unsigned char *) rasterData Width: (size_t) width Height:(size_t) height
{
    if (rasterData == NULL) 
        return NULL;
    
    
    // 4 bytes/pixel * number of pixels/row
    //NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = width * 4;
    NSUInteger bitsPerComponent = 8;
    //CGFloat bitsPerPixel = 32;
    
    // round up to nearest multiple of 16
    //bytesPerRow = COMPUTE_BEST_BYTES_PER_ROW(bytesPerRow);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(rasterData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);    //  kCGImageAlphaNoneSkipLast
    
        
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) 
        return NULL;
        
    CGContextSaveGState(context);
    CGFloat opaqueWhite[4] = {1.0, 1.0, 1.0, 1.0};
    CGColorRef fillColorWhite = CGColorCreate(colorSpace, opaqueWhite);
    CGContextSetFillColorWithColor(context, fillColorWhite);
    
    CGColorRelease(fillColorWhite);
    
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    CGContextRestoreGState(context);
    
    
    
    return context;
}






// Metadata and Options data for the image are generated in this function
- (void) saveMetaAndOpts: (CFMutableDictionaryRef *) dictMetaData
{
    
    
    //if (dictMetaData != nil)
    //    return;
    
    
    if (cgImageMetadata)
        *dictMetaData = CFDictionaryCreateMutableCopy(nil, 0, cgImageMetadata);
    else
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
    
    // updated on 3/16/12: to stop change in orientation 
    const int photoOrientation = 1; // origin at top-left
    
    
    CFMutableDictionaryRef exifProfsMut = (CFMutableDictionaryRef) CFDictionaryGetValue(*dictMetaData, kCGImagePropertyExifDictionary);
    
    
    CFNumberRef cfOrientation = CFNumberCreate(0, kCFNumberIntType, &photoOrientation);
    
    if ( cfOrientation ) {
        CFDictionarySetValue(exifProfsMut, kCGImagePropertyTIFFOrientation, cfOrientation);            
        CFDictionarySetValue(*dictMetaData, kCGImagePropertyExifDictionary, exifProfsMut);    
        
        CFDictionarySetValue(*dictMetaData, kCGImagePropertyOrientation, cfOrientation);
        
        CFRelease( cfOrientation );
    }
    
    const int photoWB = 1; // manual WB
    
    CFNumberRef exifWhiteBalance = CFNumberCreate(0, kCFNumberIntType, &photoWB);
    
    if ( exifWhiteBalance ) {
        
        CFDictionarySetValue(exifProfsMut, kCGImagePropertyExifWhiteBalance, exifWhiteBalance);
        CFDictionarySetValue(*dictMetaData, kCGImagePropertyExifDictionary, exifProfsMut);
        
        CFRelease( exifWhiteBalance );
    } 
    
    
    
    // ---------------- TO DO: add faceRect as SubjectArea -----------
    /*
     NSString *strSubjectArea = [NSString stringWithFormat:@"%d, %d, %d, %d", mFaceRect.origin.x, mFaceRect.origin.y, mFaceRect.size.width, mFaceRect.size.height];
     
     //CFNumberRef cfOrientation = CFNumberCreate(0, kCFNumberIntType, &photoOrientation);
     
     CFStringRef cfSubArea = CFStringCreateCopy(0, (__bridge CFStringRef) strSubjectArea);
     
     if ( cfSubArea ) {
     
     CFDictionarySetValue(exifProfsMut, kCGImagePropertyExifSubjectArea, cfSubArea);
     CFDictionarySetValue(dictMetaData, kCGImagePropertyExifDictionary, exifProfsMut);
     
     CFRelease( cfSubArea );
     }      
     */
        
            
    return;
    
}



// utility routine used after taking a still image to write the resulting image to the camera roll
- (BOOL)saveCGImageToAlbum:(CGImageRef)cgImage withMetadata:(NSDictionary *)metadata
{
    BOOL successWritingToAlbum = NO;
    
        
    
    // create empty object
	CFMutableDataRef destinationData = CFDataCreateMutable(kCFAllocatorDefault, 0);
	CGImageDestinationRef destRefAlbumsFolder = CGImageDestinationCreateWithData(destinationData, 
                                                                                 CFSTR("public.jpeg"), 
                                                                                 1, 
                                                                                 NULL);
	
    
    if(destRefAlbumsFolder == NULL)
    {
        if (destinationData)
            CFRelease(destinationData);
        return successWritingToAlbum;
    }
    
    
    CGImageDestinationAddImage(destRefAlbumsFolder, cgImage, (__bridge CFDictionaryRef)metadata);
    
	successWritingToAlbum = CGImageDestinationFinalize( destRefAlbumsFolder );
    
    if (destRefAlbumsFolder)
        CFRelease(destRefAlbumsFolder);
    
    if(!successWritingToAlbum)
    {
        if (destinationData)
            CFRelease(destinationData);
                
        return successWritingToAlbum;
    }
    
	CFRetain(destinationData);    
	ALAssetsLibrary *library = [ALAssetsLibrary new];
	[library writeImageDataToSavedPhotosAlbum:(__bridge id)destinationData metadata: metadata completionBlock:^(NSURL *assetURL, NSError *error) {
		if (destinationData)
			CFRelease(destinationData);
	}];
    
	library = nil;
    
    
	

    return (successWritingToAlbum );
    
}


// utility routine used after taking a still image to write the resulting image to app doc folder
- (BOOL)saveCGImageToDocFolder:(CGImageRef)cgImage withMetadata:(NSDictionary *)metadata
{
    BOOL successWritingToDocFolder = NO;
    
    
    
    // ------------------------  save in Documents folder ------------------------
    
    CGImageDestinationRef destRefDocFolder = nil;
    
    NSURL *outputFileURL = [self docFolderURL];
    
    //NSLog(@"url: %@", outputFileURL);
    
    
    
    // Create an image destination writing to `url'
    destRefDocFolder = CGImageDestinationCreateWithURL((__bridge CFURLRef)outputFileURL, CFSTR("public.jpeg"), 1, nil);
    
    if (destRefDocFolder==nil) {
        return successWritingToDocFolder;
    }
    
    // Set the image in the image destination to be `image' with
    // optional properties specified in saved properties dict.
    //CGImageDestinationAddImage(destRefDocFolder, cgImage, (__bridge CFDictionaryRef)[self saveMetaAndOpts]);
    CGImageDestinationAddImage(destRefDocFolder, cgImage, (__bridge CFDictionaryRef)metadata);
    
    successWritingToDocFolder = CGImageDestinationFinalize(destRefDocFolder);
    
    CFRelease(destRefDocFolder);
    
    
    return (successWritingToDocFolder );
    
}



-(NSURL *) captureImage: (dispatch_queue_t) videoDataOutputQueue HavingFaceRect: (CGRect) faceRect
{
    
    LogInfo(@"Session preset used: %@", session.sessionPreset);
    
    AVCaptureConnection *stillImageConnection = [CMCamUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections: [[self stillImageOutput] connections]];
    
    if ([stillImageConnection isVideoOrientationSupported])
        [stillImageConnection setVideoOrientation: orientation];
    
    //[stillImageConnection setVideoScaleAndCropFactor: 1.0]; // effectiveScale = 1.0 see squareCam
    
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) 
     {
         ALAssetsLibraryWriteImageCompletionBlock completionBlock = ^(NSURL *assetURL, NSError *error) {
             if (error) {
                 if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                     [[self delegate] captureManager:self didFailWithError:error];
                 }
             }
         };
         
         if (imageDataSampleBuffer != NULL) {                
             // when processing an existing frame we want any new frames to be automatically dropped
             // queueing this block to execute on the videoDataOutputQueue serial queue ensures this
             // see the header doc for setSampleBufferDelegate:queue: for more information
             dispatch_sync(videoDataOutputQueue, ^(void) {
                 
                 // discard previous image data
                 if (mCapturedCGImage)
                     CFRelease(mCapturedCGImage);
                 
                 mCapturedCGImage = NULL;
                 
                 // tested various options on 0/05/12 to prevent leak in CreateCGImageFromCVPixelBuffer:                 
                 // ANY ATTEMPT TO RELEASE pxlBuffer CAUSES CRASH                 
                 
                 CVPixelBufferRef pxlBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
                 

                 // careful - pxlBuffer will be released in the function
                 OSStatus err = CreateCGImageFromCVPixelBuffer(pxlBuffer, &mCapturedCGImage);
                 
                 
                 int photoOrientation = 0;
                 float scaleFactor = 1.0;
                 
                                  
                 // added 06/30/12 - to resolve 3GS image resolution issue - always saving 640x480                 
                 size_t bufferWidth = CVPixelBufferGetWidth(pxlBuffer);
                 size_t bufferHeight = CVPixelBufferGetHeight(pxlBuffer);
                 
                 
                 
                 LogInfo(@"Image captured: size (%zu, %zu)", bufferWidth, bufferHeight);
                  
                 // following is needed for iPhone 3G - size is always 640x480 irrespective of session preset
                 // crashing 
                 if ((float) bufferWidth == 640.0) {
                     scaleFactor = (float) bufferWidth / 320.0;
                  }
                  
                 
                 
                 if(!err)
                 {                     
                     // CFDictionaryRef cgImageMetadata 
                     cgImageMetadata = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
                     
                     mFaceRect = faceRect;
                     
                     // save metadata with additional info
                     CFMutableDictionaryRef imgCFMetaData = nil;
                     
                     [self saveMetaAndOpts: &imgCFMetaData];
                     
                     //NSMutableDictionary *imgMetaData = [NSMutableDictionary dictionaryWithCapacity:1];
                     
                     
                     UIImage *capturedRotatedImage = [UIImage imageWithCGImage:mCapturedCGImage scale:scaleFactor orientation:UIImageOrientationUp];
                     
                     
                     // when orientation = UIDeviceOrientationPortrait, image must be rotated before saving
                     UIImage *imageWithOrientationUp = [capturedRotatedImage imageRotatedByDegrees: 90.];
                     
                     CGImageRef capturedCGRotatedImage = [imageWithOrientationUp CGImage];
                     
                     CFNumberRef curOreintation = CFDictionaryGetValue(imgCFMetaData, kCGImagePropertyOrientation);        
                     CFNumberGetValue(curOreintation, kCFNumberIntType, &photoOrientation);
                     
                     //NSLog(@"\nCur Orientation: %d", photoOrientation);
                     
                     // ------------------------  save in App doc folder ------------------------
                     [self saveCGImageToDocFolder:capturedCGRotatedImage withMetadata: (__bridge NSMutableDictionary *) imgCFMetaData];   
                     
                     
                     // ------------------------  save in Photo Album folder ------------------------                     
                     [self saveCGImageToAlbum:capturedCGRotatedImage withMetadata: (__bridge NSMutableDictionary *) imgCFMetaData];   
                     
                     CFRelease(imgCFMetaData);
                     
                     if ([[self delegate] respondsToSelector:@selector(captureManagerStillImageCaptured:)])
                     {
                         [[self delegate] captureManagerStillImageCaptured:self];                 
                     }
                 }
             });
         }
         else
             completionBlock(nil, error);   
     }];
    
    return [self docFolderURL];
}







// Toggle between the front and back camera, if both are present.
- (BOOL) toggleCamera
{
    BOOL success = NO;
    
    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        else
            goto bail;
        
        if (newVideoInput != nil) {
            [[self session] beginConfiguration];
            [[self session] removeInput:[self videoInput]];
            if ([[self session] canAddInput:newVideoInput]) {
                [[self session] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [[self session] addInput:[self videoInput]];
            }
            [[self session] commitConfiguration];
            success = YES;
            //newVideoInput = nil;
            
        } else if (error) {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
    
bail:
    return success;
}


#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}




#pragma mark Camera Properties
// Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
- (void) autoFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }        
    }
}

// Switch to continuous auto focus mode at the specified point
- (void) continuousFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
	
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		} else {
			if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
			}
		}
	}
}

@end


#pragma mark -
@implementation CMCamCaptureManager (InternalUtilityMethods)

// Keep track of current device orientation so it can be applied to movie recordings and still image captures
- (void)deviceOrientationDidChange
{	
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
	if (deviceOrientation == UIDeviceOrientationPortrait)
		orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	
	// AVCapture and UIDevice have opposite meanings for landscape left and right (AVCapture orientation is the same as UIInterfaceOrientation)
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		orientation = AVCaptureVideoOrientationLandscapeLeft;
	
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


- (NSURL *) docFolderURL
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", documentsDirectory, @"/userPhoto.jpg"]];
    
}

- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }            
        }
    }
}

- (void) copyFileToDocuments:(NSURL *)fileURL
{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
	NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/userPhoto%@.jpg", [dateFormatter stringFromDate:[NSDate date]]];
	
    
	NSError	*error;
	if (![[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error]) {
		if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
			[[self delegate] captureManager:self didFailWithError:error];
		}
	}
}	

@end


#pragma mark -

