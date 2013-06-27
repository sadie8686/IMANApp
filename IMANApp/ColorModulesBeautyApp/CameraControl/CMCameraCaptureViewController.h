/*--------------------------------------------------------------------------
 CMCameraCaptureViewController.h
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar 
 
 Created by Abhijit Sarkar on 2012/01/25
 
 Description: 
 Header for Camera capture view that appears when users press the Take My Photo button 
 under Take Photo View (CMBeautyTakePhotoViewController). 
 
 
 Revision history:
 2012/01/27 - by AS
 2012/02/05 - by AS, added major functionalities
 2012/02/16 - by AS, fixed bugs, added code to save image in Documents folder
 2012/03/21 - by AS, color correction/extraction code incorporated (3 PM)
 
 Existing Problems:
 (date) - 
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CMCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;


@class CIDetector;

// declare protocol to be used by the source view controller
@protocol CMCameraCaptureViewControllerDelegate;


@interface CMCameraCaptureViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    BOOL mIfToDetectFaces; // indicates when to detect faces (e.g. false in landscape mode)
    BOOL mViewIsReadyForFaceDetection; // face detection should start only when view is ready
    BOOL mFaceDetected;
    int mCameraWBUpdateStatus; //0: not started, 1 = being updated, 2 = done
    int mCameraExposureUpdateStatus; //0: not started, 1 = being updated, 2 = just updated (show marker), 3 = updated and current
    
    CGPoint mExposurePointInViewLayer;
    CGPoint mExposurePointInDeviceCoords;
    BOOL mExposureNeedsImmediateUpdate; 
    CGFloat mWidthScaleFactor;
    CGFloat mHeightScaleFactor;
    
    CGRect mPreviewBox;
    dispatch_queue_t videoDataOutputQueue;
        
    CGRect mFaceRect;
    
}


@property (nonatomic,retain) CMCamCaptureManager *captureManager;

@property (nonatomic,strong) IBOutlet UIView *videoPreviewView;
@property (nonatomic,retain) IBOutlet UIImageView *faceGuide;
@property (nonatomic,retain) UIView *flashView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *showActivityIndicator;

@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) CAShapeLayer *mExposureMarkerLayer;
@property (nonatomic,retain) NSURL *mImgFileURL;
@property (nonatomic,retain) CIDetector *faceDetector;
@property (nonatomic,retain) CIFaceFeature *mFacialFeatures;

// following is needed since iPhone 3G saves image as 640x480 irrespective of session preset
// so the image is scaled to 320x240 and eye-mouth positions later needs to be scaled as well
@property (nonatomic,retain) NSString *mCaptureSessionPreset;
@property (nonatomic,retain) IBOutlet UIButton *cancelButton;
@property (nonatomic,retain) IBOutlet UIButton *stillButton;
@property (nonatomic,retain) UILabel *userFeedbackLabel;
@property (nonatomic,retain) UILabel *lblCam;
@property (nonatomic,retain) UIImage *square;

- (IBAction)captureStillImage:(id)sender;

// set delegate as a class property, which is set by the source view 
// controller object to self
@property (weak, nonatomic) id <CMCameraCaptureViewControllerDelegate> delegate;


@end


// define protocol to be used by the source view controller
@protocol CMCameraCaptureViewControllerDelegate <NSObject>

-(void) captureViewController:(CMCameraCaptureViewController *)controller didFailWithError:(NSError *)error;
-(void) captureViewControllerDidCancel:(CMCameraCaptureViewController *)controller;
-(void) captureViewControllerDidFinish:(CMCameraCaptureViewController *)controller;

@end







