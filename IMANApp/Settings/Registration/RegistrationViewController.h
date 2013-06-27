//
//  RegistrationViewController.h
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMANAppDelegate.h"

@interface RegistrationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    IMANAppDelegate *appDelegate;
    
    UITableView *table;
    
    UITextField *userNameTextField;
    UITextField *passwordTextField;
    UITextField *emailTextField;
}

@property (nonatomic, retain) IBOutlet UITableView *table;

@property(nonatomic,retain) UITextField *userNameTextField;
@property(nonatomic,retain) UITextField *passwordTextField;
@property(nonatomic,retain) UITextField *emailTextField;

- (void) registerToPlumperfectWithUsername: (NSString *) username
                             WithFirstName: (NSString *) firstName
                              WithLastName: (NSString *) lastName;
@end
