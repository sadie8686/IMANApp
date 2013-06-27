/*--------------------------------------------------------------------------
 CMColorProcessing.h
 
 Test project for building color processing functionalities - to be integrated
 with the main app in future
 
 Developed by Abhijit Sarkar 
 
 Created by Abhijit Sarkar on 2012/05/08
 
 Description: 
 Header for color processing library. 
 
 
 Revision history:
 2012/02/26 - by AS
 2012/03/20 - by AS, major feature addition (e.g. sRGB/Device color), exposure 
 correction  
 2012/04/04 - by AS, major update in color correction
 
 Existing Problems:
 (date) - 
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*///

#import <Foundation/Foundation.h>

@protocol CMColorProcessorDelegate;


@interface CMColorProcessing : NSObject
{
    //CFMutableDictionaryRef	mSaveMetaAndOpts;
    
    unsigned char *mRawImagePixelData;
    //unsigned char *mCorrectedImagePixelData;
    
    NSUInteger mBytesPerPixel;
    NSUInteger mBytesPerRow;
    NSUInteger mBitsPerComponent;
    
    BOOL mProcessingStatusCode;
    //BOOL mUserCancelledProcessing;
    
        
    CGRect mHairAreaRect, mSkinAreaRect, mLipAreaRect;
    CGRect mEyeIrisAreaRect_Left, mWholeEyeAreaRect_Left, mEyeIrisAreaRect_Right, mWholeEyeAreaRect_Right;
    
    
}


@property (nonatomic,retain) NSNumber *mUserCancelledProcessing; //BOOL value

//@property (nonatomic,assign) id processingCancelledObserver;

@property (nonatomic,assign) id <CMColorProcessorDelegate> delegate;

// -------- color profile data: hair/eye/skin/lip ------------
@property (nonatomic,retain) NSMutableArray *mProfileColorsOriginal_RawRGB;
@property (nonatomic,retain) NSMutableArray *mProfileColorsCorrected_DeviceRGB;
@property (nonatomic,retain) NSMutableArray *mProfileColorsCorrected_sRGB;
@property (nonatomic,retain) NSMutableArray *mProfileColorsCorrected_Lab;


// -------- dictionary for image pixel data ------------
@property (nonatomic,retain) NSMutableArray *mArrDictImagePixelData; 
 
@property (nonatomic,retain) NSURL *mCorrectedPhotoURL;


//@property (nonatomic,assign) id imageRowWasUpdatedObserver;
//@property (nonatomic,assign) id processingIsCompleteObserver;


- (CGContextRef) createRGBBitmapContext: (unsigned char *) rasterData Width: (size_t) width Height:(size_t) height;
- (CGImageRef) createImageFromBitmapContext: (CGContextRef) context;

- (NSURL *) docFolderURL;

- (void) saveMetaAndOpts: (CFMutableDictionaryRef *) dictMetaData;

- (void) openColorExtractionSession:(CGImageRef)imageRef;
- (void) closeColorExtractionSession;

-(void) dealloc;




- (void) locateSkinAreas:(CGPoint) leftEyePos RightEyePosition:(CGPoint) rightEyePos  MouthPosition:(CGPoint) mouthPos;

- (void) locateHairAreas: (CGRect) areaOfInterest LeftEyePosition:(CGPoint) leftEyePos RightEyePosition:(CGPoint) rightEyePos  MouthPosition:(CGPoint) mouthPos;

- (BOOL) updateHairArea: (CGRect)areaOfInterest SkinColorLAB: (CGFloat *)skinColorLab;



- (void) correctAndExtractColorProfileDataFromFacialImage:(CGImageRef) imageRef atRect:(CGRect)areaOfInterest LeftEyePosition:(CGPoint) leftEyePos RightEyePosition:(CGPoint) rightEyePos MouthPosition:(CGPoint) mouthPos withImageURL: (NSURL *) imgURL;

- (void) getColorimetricDataFromImage: (CGRect)areaOfInterest LuminanceMF:(CGFloat) lumMF WhitePointXYZ: (CGFloat *) srcWhitePtXYZ;


- (void) colorCorrectInputPixel:(CGFloat *) inputColor WhitePointXYZ: (CGFloat *) wpXYZ LuminanceMF:(CGFloat) lumMF sRGBOutput:(CGFloat *) outputsRGB DeviceRGBOutput:(CGFloat *) outputDeviceRGB XYZOutput: (CGFloat *) outXYZ LabOutput: (CGFloat *) outLab;

- (int) getDominantColorOfTaggedPixels: (int)whatTag RGBInput:(CGFloat *) inputRGB WhitePointXYZ: (CGFloat *) srcWhitePtXYZ LuminanceMF:(CGFloat) lumMF sRGBOutput:(CGFloat *) outputsRGB DeviceRGBOutput:(CGFloat *) outputDeviceRGB LabOutput: (CGFloat *) outLab;


- (NSArray *) sortDictArrayAndFindMaxAndMin: (NSArray *) data ForKey: (NSString *) forKey MaxValue: (CGFloat *) maxVal  MinValue: (CGFloat *) minVal;



- (BOOL)estimateSceneWhitePoint:(CGFloat *) meanEyeWhitePointXYZ LuminanceCorrectionFactor:(CGFloat *) lumCF FromWholeLeftEyeArea:(CGRect) wholeEyeArea_Left FromWholeRightEyeArea:(CGRect) wholeEyeArea_Right ImageAreaOfInterest:(CGRect)areaOfInterest LightingType:(int *) lightingType;




// --------------------------- color conversion routines --------------------------
- (UIColor *) convertDeviceRGB2sRGB:(UIColor *) deviceRGBColor;

- (void) convertXYZ2sRGB:(CGFloat *) objXYZ TosRGB: (CGFloat *) objsRGB;

- (int) convertRGB2YCbCr:(CGFloat *)linRGBData toY:(CGFloat *)colorY toCb:(CGFloat *)colorCb toCr:(CGFloat *)colorCr;
- (int) convertYCbCr2RGB:(CGFloat *)YCbCrData toR:(CGFloat *)colorR toG:(CGFloat *)colorG toB:(CGFloat *)colorB;

- (int) convertXYZ2Lab:(CGFloat *)XYZData WhitePtXYZ:(CGFloat *)XYZnData ToL:(CGFloat *)colorL Toa:(CGFloat *)colora Tob:(CGFloat *)colorb ToChroma:(CGFloat *)colorC ToHue:(CGFloat *)colorh;
- (int) convertLab2XYZ:(CGFloat *)LabData WhitePtXYZ:(CGFloat *)XYZnData ToX:(CGFloat *)colorX ToY:(CGFloat *)colorY ToZ:(CGFloat *)colorZ;

- (int) convertRGB2YUV:(UIColor *)rgbData toY:(CGFloat *)colorY toU:(CGFloat *)colorU toV:(CGFloat *)colorV;

// ------------------------


//- (BOOL) getExifMetadata:(NSURL *) imgURL ExposureTime: (float *)exposureTime ApertureValue: (float *)aperture Sensitivity: (float *)sensitivity BrightnessValue: (float *)brightness ShutterSpeedValue: (float *)shutterSpeed;



static NSString* ImageIOLocalizedString (NSString* key);



@end


// These delegate methods can be called on any arbitrary thread. If the delegate does something with the UI when called, make sure to send it to the main thread.
@protocol CMColorProcessorDelegate <NSObject>

@optional

- (void)colorProcessor:(CMColorProcessing *)colorProcessor didFailWithError:(NSError *)error;
- (void) showError:(CMColorProcessing *)colorProcessor ErrorMessage:(NSString *) errMsg;

- (void)  updateProcessingStatus:(CMColorProcessing *)colorProcessor StatusCode:(int) code;
- (void) newImageRowComputed:(CMColorProcessing *)colorProcessor
                RawPixelData:(unsigned char *) imageData
                  ImageWidth: (int) width
                 ImageHeight: (int) height
                    RowIndex: (int) rowIndex
          ProcessingTimeLeft: (float) t;

- (void) profileColorsComputed:(CMColorProcessing *)colorProcessor;
- (void) processingDidCancel:(CMColorProcessing *)colorProcessor;
- (void) processingComplete:(CMColorProcessing *)colorProcessor;

@end
