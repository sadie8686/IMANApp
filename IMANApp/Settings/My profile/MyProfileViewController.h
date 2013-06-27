//
//  MyProfileViewController.h
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMANAppDelegate.h"

@interface MyProfileViewController : UIViewController <UITextFieldDelegate>
{
    IMANAppDelegate *appDelegate;
    
    UITableView *table;
    
    UITextField *usernameTextField;
    UITextField *emailTextField;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *emailTextField;

@end
