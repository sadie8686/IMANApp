//
//  ChangePasswordViewController.m
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Constants.h"
#import "DejalActivityView.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

@synthesize table;
@synthesize oldPwdTextField, mynewPwdTextField, confirmPwdTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordChangeSuccessfully:) name:ChangePasswordSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordChangeErrorFound:) name:ChangePasswordErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordChangeFailed:) name:ChangePasswordFailedNotification object:nil];
    }
    return self;
}

- (void) customUISettings
{
    self.navigationItem.titleView = [Constants customTitleLabel:self.title];
    self.title = @"";
    
    UIButton *leftButton = [Constants customBackButton];
    [leftButton addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIButton *rightButton = [Constants customRightButton];
    [rightButton addTarget:self action:@selector(changePasswordClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    oldPwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 13, 220, 25)];
    mynewPwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 13, 220, 25)];
    confirmPwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 13, 220, 25)];
    
    showPwdSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 55.0, 45.0)];
    showPwdSwitch.onTintColor = [Utils colorForHex:@"#54830e"];
}

- (void) backBtnClicked:(id) sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (IMANAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self customUISettings];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.table reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [oldPwdTextField becomeFirstResponder];
}

- (void) changePasswordClicked:(id) sender
{
    if ([self validateData]) {
        NSLog(@"Validated");
        
        if ([appDelegate.networkValue isEqualToString:wifiValue] || [appDelegate.networkValue isEqualToString:wwanValue]) {
            [self startIndicator];
            NSString *urlString = [NSString stringWithFormat:@"%@index.php/iman/changepassword", mainUrl];
            NSDictionary *userProf = [Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary];
            NSString *uid = [userProf objectForKey:UserID];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"id", oldPwdTextField.text, @"oldpassword", mynewPwdTextField.text, @"newpassword", nil];
            [appDelegate callPostMethod:params connectionTag:queryChangePassword urlString:urlString];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet!", @"AlertView")  message:NSLocalizedString(@"No working internet connection is found.", @"AlertView") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"AlertView") otherButtonTitles:nil];
            [alertView show];
        }
        
    }
    else {
        NSLog(@"Error in validation");
    }
}

- (void) passwordChangeSuccessfully:(NSNotification *) notif
{
    [self stopIndicator];
    NSDictionary *resultDict = [notif object];
    NSLog(@"Result dict: %@", resultDict);
    
    [Utils showAlertWithTitle:@"Success" message:@"Password changed successfully." andDelegate:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) passwordChangeErrorFound:(NSNotification *) notif
{
    NSLog(@"Update prof error...");
    [self stopIndicator];
    [oldPwdTextField becomeFirstResponder];
    NSArray *metaArray = [notif object];
    [Utils showErrorAlertWithMessage:[metaArray valueForKey:@"message"] andDelegate:self];
}

- (void) passwordChangeFailed:(NSNotification *) notif
{
    NSLog(@"Update prof failed...");
    [self stopIndicator];
    [oldPwdTextField becomeFirstResponder];
    [Utils showErrorAlertWithMessage:@"There's some problem in server. Try again later." andDelegate:self];
}

- (void) startIndicator
{
    [DejalBezelActivityView activityViewForView:self.navigationController.view];
    appDelegate.tabBarController.tabBar.userInteractionEnabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) stopIndicator
{
    [DejalBezelActivityView removeViewAnimated:YES];
    appDelegate.tabBarController.tabBar.userInteractionEnabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.tag = indexPath.row;
    UIFont *lblFont1 = [UIFont fontWithName: @"helvetica" size:16.0];
    
    if(indexPath.row == 0)
    {
        UILabel *oldPwdLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 100, 20)];
        [oldPwdLbl setText:@"Old:"];
        [oldPwdLbl setBackgroundColor:[UIColor clearColor]];
        oldPwdLbl.font = lblFont1;
        [cell.contentView addSubview:oldPwdLbl];
        
        oldPwdTextField.returnKeyType = UIReturnKeyNext;
        oldPwdTextField.delegate = self;
        oldPwdTextField.tag = indexPath.row;
        oldPwdTextField.secureTextEntry = YES;
        [oldPwdTextField setPlaceholder:@"Old password"];
        oldPwdTextField.userInteractionEnabled = YES;
        oldPwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        oldPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [oldPwdTextField setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:oldPwdTextField];
    }
    else if(indexPath.row == 1)
    {
        UILabel *mynewPwdLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 100, 20)];
        [mynewPwdLbl setText:@"New:"];
        [mynewPwdLbl setBackgroundColor:[UIColor clearColor]];
        mynewPwdLbl.font = lblFont1;
        [cell.contentView addSubview:mynewPwdLbl];
        
        mynewPwdTextField.tag = indexPath.row;
        mynewPwdTextField.returnKeyType = UIReturnKeyNext;
        mynewPwdTextField.secureTextEntry = YES;
		[mynewPwdTextField setPlaceholder:@"New password"];
        mynewPwdTextField.delegate = self;
        mynewPwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        mynewPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[mynewPwdTextField setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:mynewPwdTextField];
	}
    else if(indexPath.row == 2)
    {
        UILabel *confirmPwdLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 100, 20)];
        [confirmPwdLbl setText:@"Confirm:"];
        [confirmPwdLbl setBackgroundColor:[UIColor clearColor]];
        confirmPwdLbl.font = lblFont1;
        [cell.contentView addSubview:confirmPwdLbl];
        
        confirmPwdTextField.tag = indexPath.row;
        confirmPwdTextField.returnKeyType = UIReturnKeyGo;
        confirmPwdTextField.secureTextEntry = YES;
		[confirmPwdTextField setPlaceholder:@"Confirm password"];
        confirmPwdTextField.delegate = self;
        confirmPwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        confirmPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[confirmPwdTextField setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:confirmPwdTextField];
	}
    else if (indexPath.row == 3)
    {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 44.0)];
        
        UILabel *showPwdLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 120, 20)];
        [showPwdLbl setText:@"Show password"];
        [showPwdLbl setBackgroundColor:[UIColor clearColor]];
        showPwdLbl.font = lblFont1;
        [cell.contentView addSubview:showPwdLbl];
        
        // Add the switch
        [showPwdSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [footerView addSubview:showPwdSwitch];
        
        [cell.contentView addSubview:footerView];
    }
    return cell;
}

//just hide the keyboard in this example
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == oldPwdTextField){
        [mynewPwdTextField becomeFirstResponder];
    }
    else if (textField == mynewPwdTextField){
        [confirmPwdTextField becomeFirstResponder];
    }
    else if (textField == confirmPwdTextField){
        [confirmPwdTextField resignFirstResponder];
        [self changePasswordClicked:nil];
    }
    return YES;
}

- (void) switchValueChanged:(id) sender
{
    [self.view endEditing:YES];
    if (showPwdSwitch.isOn) {
        oldPwdTextField.secureTextEntry = NO;
        mynewPwdTextField.secureTextEntry = NO;
        confirmPwdTextField.secureTextEntry = NO;
    }
    else {
        oldPwdTextField.secureTextEntry = YES;
        mynewPwdTextField.secureTextEntry = YES;
        confirmPwdTextField.secureTextEntry = YES;
    }
}

- (BOOL) validateData
{
    [self.view endEditing:YES];
    NSString *alertTitle = @"Error!";
    NSString *alertMsg = @"";
    UIAlertView *alert;
    
    if ([oldPwdTextField.text length] == 0) {
        alertMsg = @"Enter old password.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [oldPwdTextField becomeFirstResponder];
        return NO;
    }
    else if ([mynewPwdTextField.text length] == 0) {
        alertMsg = @"Enter new password.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [mynewPwdTextField becomeFirstResponder];
        return NO;
    }
    else if ([mynewPwdTextField.text length] < 4) {
        alertMsg = @"New password cannot be less than 4 characters.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [mynewPwdTextField becomeFirstResponder];
        return NO;
    }
    else if (![confirmPwdTextField.text isEqualToString:mynewPwdTextField.text]) {
        alertMsg = @"Confirm password does not match the new password.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [confirmPwdTextField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
