/*--------------------------------------------------------------------------
 CMCamCaptureManager.h
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar 
 
 Created by Abhijit Sarkar on 2012/02/04
 
 Description: 
 Header for camera capture manager responsible for all capture functionalities
 
 
 
 Revision history:
 2012/02/05 - by AS
 2012/02/14 - by AS, fixed bugs, added code to save image in Documents folder
 
 Existing Problems:
 (date) - 
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@protocol CMCamCaptureManagerDelegate;

@interface CMCamCaptureManager : NSObject
{
    
    // the following can be declared locally - to be changed in future
    CFDictionaryRef				cgImageMetadata;
    CGImageRef					mCapturedCGImage;
    
    
    CGRect mFaceRect;
    //CGPoint expPointInViewLayer;
    
}

@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,assign) AVCaptureVideoOrientation orientation;
@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,retain) AVCaptureVideoDataOutput *videoOutput;


@property (nonatomic,retain) AVCaptureDevice *currentDevice;

@property (nonatomic,assign) BOOL isUsingFrontFacingCamera;

@property (nonatomic,retain) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic,assign) id deviceConnectedObserver;
@property (nonatomic,assign) id deviceDisconnectedObserver;

@property (nonatomic,assign) id <CMCamCaptureManagerDelegate> delegate;


- (BOOL) setupSession;
- (void) closeSession;

- (CGContextRef) createRGBBitmapContext: (unsigned char *) rasterData Width: (size_t) width Height:(size_t) height;



- (BOOL) getExposurePointOfInterest:(CVPixelBufferRef) pixelBuffer AreaOfInterest:(CGRect) aoi PreviewBox: (CGRect) previewBox WidthScaleFactor: (float) widthSF HeightScaleFactor: (float) heightSF IsImageMirrored: (BOOL) isMirrored ExposurePointInViewLayer: (CGPoint *) expPointInViewLayer ExposurePointInDeviceCoords: (CGPoint *) expPointInDeviceCoords;

- (BOOL) updateDeviceExposureSetting: (CGPoint) exposurePointOfInterest;
- (BOOL) updateDeviceWhiteBalanceSettings:(int) sayWhen;

-(NSURL *) captureImage: (dispatch_queue_t) videoDataOutputQueue HavingFaceRect: (CGRect) faceRect;
- (void) saveMetaAndOpts: (CFMutableDictionaryRef *) dictMetaData;
- (BOOL)saveCGImageToAlbum:(CGImageRef)cgImage withMetadata:(NSDictionary *)metadata;
- (BOOL)saveCGImageToDocFolder:(CGImageRef)cgImage withMetadata:(NSDictionary *)metadata;

- (NSUInteger) cameraCount;

- (void) autoFocusAtPoint:(CGPoint)point;
- (void) continuousFocusAtPoint:(CGPoint)point;

@end

// These delegate methods can be called on any arbitrary thread. If the delegate does something with the UI when called, make sure to send it to the main thread.
@protocol CMCamCaptureManagerDelegate <NSObject>
@optional
- (void) captureManager:(CMCamCaptureManager *)captureManager didFailWithError:(NSError *)error;

- (void) captureManagerStillImageCaptured:(CMCamCaptureManager *)captureManager;

- (void) captureManagerDeviceConfigurationChanged:(CMCamCaptureManager *)captureManager;
@end


