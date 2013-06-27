//
//  LoginViewController.h
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMANAppDelegate.h"

@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    IMANAppDelegate *appDelegate;
    
    UITableView *table;
    
    UITextField *emailTextField;
    UITextField *passwordTextField;
    
    UIButton *forgotPasswordBtn;
    UITextField *forgotPwdTextField;
}

@property (nonatomic, retain) IBOutlet UITableView *table;

@property(nonatomic,retain) UITextField *emailTextField;
@property(nonatomic,retain) UITextField *passwordTextField;

@property(nonatomic,retain) UIButton *forgotPasswordBtn;

- (void) loginToPlumPerfect: (NSString *) username;

@end
