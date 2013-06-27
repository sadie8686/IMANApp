/*--------------------------------------------------------------------------
 CMBeautyTakePhotoViewController.h
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar 
 
 Created by Abhijit Sarkar on 2012/01/25
 
 Description: 
 Header for Take Photo view that appears when users press the Start button 
 under Profile View (CMBeautyFirstViewController). 
 
 
 Revision history:
 2012/01/27 - by AS
 2012/02/16 - by AS, added code for delegate
 2012/03/21 - by AS, color correction/extraction code incorporated (3 PM)
 
 
 Existing Problems:
 (date) - 
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/


#import <UIKit/UIKit.h>

@interface CMPhotoSource : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>

// this will come from select model photo view controller
@property (nonatomic,retain) NSNumber *mModelPhotoID;

// this string is for the source controller to know what to do
// e.g. when returning after color extraction, discover product page needs to be shown
@property (nonatomic,retain) NSString *mRequestActionToSourceController;

@property (nonatomic,retain) NSURL *mProfilePhotoURL;
@property (nonatomic,retain) CIFaceFeature *mFacialFeatures;

// following is needed since iPhone 3G saves image as 640x480 irrespective of session preset
// so the image is scaled to 320x240 and eye-mouth positions later needs to be scaled as well
@property (nonatomic,retain) NSString *mCaptureSessionPreset;

// for choose image from device
@property (nonatomic, retain) UIImagePickerController *imgPicker;


@end


