/*--------------------------------------------------------------------------
 CMSelectModelPhotoViewController.h
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar 
 
 Created by Abhijit Sarkar on 2012/01/24
 
 Description: 
 Header for Select Model Photo view that appears when users press the button with 
 same name under Take Photo View (CMBeautyTakePhotoViewController). 
 
 
 Revision history:
 2012/01/27 - by AS
 
 Existing Problems:
 (date) - 
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/


#import <UIKit/UIKit.h>

@interface CMSelectModelPhotoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (void) configure;
@end