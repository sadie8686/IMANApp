//
//  ChangePasswordViewController.h
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMANAppDelegate.h"

@interface ChangePasswordViewController : UIViewController <UITextFieldDelegate>
{
    IMANAppDelegate *appDelegate;
    
    UITableView *table;
    
    UITextField *oldPwdTextField;
    UITextField *mynewPwdTextField;
    UITextField *confirmPwdTextField;
    
    UISwitch *showPwdSwitch;
}

@property (nonatomic, retain) IBOutlet UITableView *table;

@property (nonatomic, retain) UITextField *oldPwdTextField;
@property (nonatomic, retain) UITextField *mynewPwdTextField;
@property (nonatomic, retain) UITextField *confirmPwdTextField;

@end
