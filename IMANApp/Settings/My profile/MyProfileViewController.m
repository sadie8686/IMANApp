//
//  MyProfileViewController.m
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "MyProfileViewController.h"
#import "Constants.h"
#import "DejalActivityView.h"

@interface MyProfileViewController ()

@end

@implementation MyProfileViewController

@synthesize table;
@synthesize usernameTextField, emailTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfSuccessfully:) name:ProfileUpdateSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfErrorFound:) name:ProfileUpdateErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfFailed:) name:ProfileUpdateFailedNotification object:nil];
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
    [rightButton addTarget:self action:@selector(updateProfileClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(92, 13, 210, 25)];
    emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(92, 13, 210, 25)];
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
    [usernameTextField becomeFirstResponder];
}

- (void) updateProfileClicked:(id) sender
{
    if ([self validateData]) {
        NSLog(@"Validated");
        
        if ([appDelegate.networkValue isEqualToString:wifiValue] || [appDelegate.networkValue isEqualToString:wwanValue]) {
            [self startIndicator];
            NSString *urlString = [NSString stringWithFormat:@"%@index.php/iman/updateprofile", mainUrl];
            NSDictionary *userProf = [Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary];
            NSString *uid = [userProf objectForKey:UserID];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"id", usernameTextField.text, @"username", emailTextField.text, @"email", nil];
            [appDelegate callPostMethod:params connectionTag:queryUpdateProfile urlString:urlString];
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

- (void) updateProfSuccessfully:(NSNotification *) notif
{
    [self stopIndicator];
    NSDictionary *resultDict = [notif object];
    NSLog(@"Result dict: %@", resultDict);
    
    NSMutableDictionary *userProf = [[Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary] mutableCopy];
    [userProf setObject:[resultDict valueForKey:@"UserName"] forKey:UserLoginName];
    [userProf setObject:[resultDict valueForKey:@"Email"] forKey:UserEmail];
    [Utils saveToUserDefaults:userProf forKey:UserProfileDictionary];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) updateProfErrorFound:(NSNotification *) notif
{
    NSLog(@"Update prof error...");
    [self stopIndicator];
    [usernameTextField becomeFirstResponder];
    NSArray *metaArray = [notif object];
    [Utils showErrorAlertWithMessage:[metaArray valueForKey:@"message"] andDelegate:self];
}

- (void) updateProfFailed:(NSNotification *) notif
{
    NSLog(@"Update prof failed...");
    [self stopIndicator];
    [usernameTextField becomeFirstResponder];
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
    return 2;
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
    UIFont *lblFont1 = [UIFont fontWithName: @"helvetica" size:15.0];
    //UIFont *textValueFont = [UIFont fontWithName: @"Helvetica" size:15.0];
    NSDictionary *profileDict = [Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary];
    
    if(indexPath.row == 0)
    {
        UILabel *userNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 100, 20)];
        [userNameLbl setText:@"User name:"];
        [userNameLbl setBackgroundColor:[UIColor clearColor]];
        userNameLbl.font = lblFont1;
        [cell.contentView addSubview:userNameLbl];
        
        usernameTextField.returnKeyType = UIReturnKeyNext;
        usernameTextField.delegate = self;
        //usernameTextField.font = textValueFont;
        usernameTextField.tag = indexPath.row;
        [usernameTextField setPlaceholder:@"Enter user name"];
        [usernameTextField setText:[profileDict valueForKey:UserLoginName]];
        usernameTextField.userInteractionEnabled = YES;
        usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [usernameTextField setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:usernameTextField];
    }
    else if(indexPath.row == 1)
    {
        UILabel *emailLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 100, 20)];
        [emailLbl setText:@"Email:"];
        [emailLbl setBackgroundColor:[UIColor clearColor]];
        emailLbl.font = lblFont1;
        [cell.contentView addSubview:emailLbl];
        
        emailTextField.tag = indexPath.row;
        emailTextField.returnKeyType = UIReturnKeyGo;
        //emailTextField.font = textValueFont;
		[emailTextField setPlaceholder:@"Enter email address"];
        [emailTextField setText:[profileDict valueForKey:UserEmail]];
        emailTextField.delegate = self;
        emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[emailTextField setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:emailTextField];
	}
    return cell;
}

- (BOOL) validateData
{
    [self.view endEditing:YES];
    NSString *alertTitle = @"Error!";
    NSString *alertMsg = @"";
    UIAlertView *alert;
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange range = [usernameTextField.text rangeOfCharacterFromSet:whitespace];
    
    if ([usernameTextField.text length] == 0) {
        alertMsg = @"Enter User Name.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [usernameTextField becomeFirstResponder];
        return NO;
    }
    else if ([usernameTextField.text length] < 4) {
        alertMsg = @"User Name must be atleast four characters.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [usernameTextField becomeFirstResponder];
        return NO;
    }
    else if (range.location != NSNotFound) {
        alertMsg = @"User name can not contain white space.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [usernameTextField becomeFirstResponder];
        return NO;
    }
    else if ([emailTextField.text length] == 0) {
        alertMsg = @"Enter Email Address.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [emailTextField becomeFirstResponder];
        return NO;
    }
    else if (![Utils isValidEmailId:emailTextField.text]) {
        alertMsg = @"Invalid Email Address.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [emailTextField becomeFirstResponder];
        return NO;
    }
    return YES;
}

//just hide the keyboard in this example
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameTextField){
        [emailTextField becomeFirstResponder];
    }
    else if (textField == emailTextField){
        [emailTextField resignFirstResponder];
        [self updateProfileClicked:nil];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
