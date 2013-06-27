//
//  CMPreColorProcessing.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/15/13.
//
//

#import <Foundation/Foundation.h>

// declare protocol to be used by the source view controller
@protocol CMColorProcessingViewControllerDelegate;

@interface CMPreColorProcessing : NSObject


- (id) initWithModelPhotoID: (NSNumber *) modelPhotoID
               WithImageURL: (NSURL *) imageFileURL
             WithController: (UIViewController *) controller;

- (id) initWithCaptureSessionPreset: (NSString *) mCaptureSessionPreset
                       WithImageURL: (NSURL *) imageFileURL
                 WithFacialFeatures: (CIFaceFeature *) mFacialFeatures
                     WithController: (UIViewController *) controller;

- (void) extractColorsForModelPhoto;
- (void) extractColorsForPhotoCapturedFromCamera;

@property BOOL isModelPhoto;
@property (weak, nonatomic) id <CMColorProcessingViewControllerDelegate> delegate;
@end
