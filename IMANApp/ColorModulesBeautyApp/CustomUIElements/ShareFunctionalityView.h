//
//  ShareFunctionalityView.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 3/31/13.
//
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import "MessageUI/MFMailComposeViewController.h"

@class SA_OAuthTwitterEngine;

@interface ShareFunctionalityView : UIView <MFMailComposeViewControllerDelegate,SA_OAuthTwitterControllerDelegate>

- (id)initWithProductArray: (NSArray *) productArray
   WithSuperViewController:(UIViewController *) superViewController
          WithViewPosition: (int) viewPosition;

- (void) animateOut;
@end
