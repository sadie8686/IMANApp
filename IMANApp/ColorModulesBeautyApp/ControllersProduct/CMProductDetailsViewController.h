//
//  CMProductDetailsViewController.h
//  ColorModulesBeautyApp
//
//  Created by Nicky Liu on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import "MessageUI/MFMailComposeViewController.h"

@class SA_OAuthTwitterEngine;



@interface CMProductDetailsViewController : UIViewController <MFMailComposeViewControllerDelegate,SA_OAuthTwitterControllerDelegate>

@property (strong,nonatomic) NSArray *product_list;
@property int starting_index;
@property (strong, nonatomic) NSString *currentProductCategory;
@property (nonatomic, retain) NSNumber *mBetaTesting_ProductDetailsFeedbackNeeded;
@end
