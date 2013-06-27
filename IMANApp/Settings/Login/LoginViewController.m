//
//  LoginViewController.m
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.h"
#import "DejalActivityView.h"
#import "CMConstants.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMApplicationModel.h"
#import "CMUserModel.h"

@interface LoginViewController ()

- (void) forgotPwdClicked:(id) sender;

@end

@implementation LoginViewController

@synthesize table;
@synthesize emailTextField, passwordTextField, forgotPasswordBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessfully:) name:LoginSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginErrorFound:) name:LoginErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:LoginFailedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forgotPwdSuccessfully:) name:ForgotPasswordSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forgotPwdErrorFound:) name:ForgotPasswordErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forgotPwdFailed:) name:ForgotPasswordFailedNotification object:nil];
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
    [rightButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [emailTextField becomeFirstResponder];
}

- (void) login:(id) sender
{
    if ([self validateData]) {
        NSLog(@"Login Validated");
        if ([appDelegate.networkValue isEqualToString:wifiValue] || [appDelegate.networkValue isEqualToString:wwanValue]) {
            [self startIndicator];
            NSString *urlString = [NSString stringWithFormat:@"%@index.php/iman/login", mainUrl];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:emailTextField.text, @"email", passwordTextField.text, @"password", @"ios", @"device_type", [Utils getObjectFromUserdefaultsWithKey:kDeviceID], @"device_id", nil];
            
            [appDelegate callPostMethod:params connectionTag:queryLogin urlString:urlString];
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

- (void) loginSuccessfully:(NSNotification *) notif
{
    
    //[self stopIndicator];
    NSDictionary *resultDict = [notif object];
    NSLog(@"Result dict: %@", resultDict);
    
    [Utils saveToUserDefaults:resultDict forKey:UserProfileDictionary];
    [self loginToPlumPerfect:[resultDict valueForKey:@"email"]];
}
-(void)loginToPlumPerfect:(NSString *)username
{
    NSURL *url = [NSURL URLWithString: server];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            username, @"login",
                            IMAN_PLUMPERFECT_TOKEN, @"api_token",
                            nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod: @"POST"
                                                            path: pathToAPICallForLoginSeller
                                                      parameters: params];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setHTTPShouldHandleCookies:YES];
    AFJSONRequestOperation
    *operation = [AFJSONRequestOperation
                  JSONRequestOperationWithRequest:request
                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                  {
                      BOOL success=[[JSON objectForKey:@"success"] boolValue];
                      if (success)
                      {
                          NSLog(@"Login successful.");
                          [[[CMUserModel alloc] initForUserProfile] updateUserProfileDataWithJSON:JSON];
                          [CMApplicationModel storeCookie];
                          [self stopIndicator];
                          [self.navigationController popViewControllerAnimated:YES];
                      }
                      else
                      {                          
                          [self stopIndicator];
                          [Utils showErrorAlertWithMessage:@"Error in PlumPerfect Registration." andDelegate:self];
                      }
                  }
                  
                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                  {
                      [self stopIndicator];
                      [passwordTextField becomeFirstResponder];
                      [Utils showErrorAlertWithMessage:@"There's some problem in server. Try again later." andDelegate:self];
                  }];
    [operation start];
}

- (void) loginErrorFound:(NSNotification *) notif
{
    NSLog(@"Login error...");
    [self stopIndicator];
    [emailTextField becomeFirstResponder];
    NSArray *metaArray = [notif object];
    [Utils showErrorAlertWithMessage:[metaArray valueForKey:@"message"] andDelegate:self];
}

- (void) loginFailed:(NSNotification *) notif
{
    NSLog(@"Login failed...");
    [self stopIndicator];
    [passwordTextField becomeFirstResponder];
    [Utils showErrorAlertWithMessage:@"There's some problem in server. Try again later." andDelegate:self];
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
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 44) ];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIFont *staticFont = [UIFont fontWithName:@"helvetica" size:17.0];
    
    CGRect lableFrame = CGRectMake(10, 12, 100, 20);
    CGRect textfieldFrame = CGRectMake(95, 11, 195, 25);
    
    if(indexPath.row == 0)
    {
        UILabel *emailLabel=[[UILabel alloc]initWithFrame:lableFrame];
		[emailLabel setText:@"Email:"];
        emailLabel.font = staticFont;
		[emailLabel setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:emailLabel];
		
		emailTextField=[[UITextField alloc]initWithFrame:textfieldFrame];
        emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        emailTextField.returnKeyType = UIReturnKeyNext;
		[emailTextField setPlaceholder:@"Enter email address"];
        emailTextField.delegate = self;
        emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[emailTextField setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:emailTextField];
	}
    
    else if(indexPath.row == 1)
    {
        UILabel *passwordLbl=[[UILabel alloc] initWithFrame:lableFrame];
		[passwordLbl setText:@"Password:"];
        passwordLbl.font = staticFont;
		[passwordLbl setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:passwordLbl];
        
		passwordTextField=[[UITextField alloc]initWithFrame:textfieldFrame];
        passwordTextField.returnKeyType = UIReturnKeyGo;
		[passwordTextField setPlaceholder:@"Enter password"];
        [passwordTextField setSecureTextEntry:YES];
        passwordTextField.delegate = self;
        passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[passwordTextField setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:passwordTextField];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
    //footerView.backgroundColor = [UIColor redColor];
    
    forgotPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgotPasswordBtn.frame = CGRectMake(180, 10, 130, 30);
    [forgotPasswordBtn setBackgroundColor:[UIColor clearColor]];
    [forgotPasswordBtn setTitle:@"Forgot password?" forState:UIControlStateNormal];
    forgotPasswordBtn.titleLabel.font = [UIFont fontWithName:@"helvetica" size:16.0];
    [forgotPasswordBtn setTitleColor:[UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:125.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [forgotPasswordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [forgotPasswordBtn addTarget:self action:@selector(forgotPwdClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:forgotPasswordBtn];
    
    return footerView;
}

//just hide the keyboard in this example
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == emailTextField){
        [passwordTextField becomeFirstResponder];
    }
    else if (textField == passwordTextField){
        [passwordTextField resignFirstResponder];
        [self login:nil];
    }
    
    if (textField == forgotPwdTextField) {
        NSLog(@"Forgot text field...");
        return NO;
    }
    
    return YES;
}

- (BOOL) validateData
{
    [self.view endEditing:YES];
    NSString *alertTitle = @"Error!";
    NSString *alertMsg = @"";
    UIAlertView *alert;
    
    if ([emailTextField.text length] == 0) {
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
    else if ([passwordTextField.text length] == 0) {
        alertMsg = @"Enter Password.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [passwordTextField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}





- (void) forgotPwdClicked:(id) sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Help!" message:@"Enter email address for password recovery." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send email!", nil];
    forgotPwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 70, 260, 25)];
    forgotPwdTextField.delegate = self;
    forgotPwdTextField.keyboardType = UIKeyboardTypeEmailAddress;
    alert.tag = 13;
    [forgotPwdTextField setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:forgotPwdTextField];
    [alert show];
    [forgotPwdTextField becomeFirstResponder];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Alert tag: %d", alertView.tag);
    
    if (alertView.tag == 13) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            //Send forgot pwd web service
            NSString *emailString = forgotPwdTextField.text;
            
            NSString *alertTitle = @"Error!";
            NSString *alertMsg;
            UIAlertView *alert;
            
            if ([emailString length] == 0) {
                NSString *alertMsg = @"Enter Email Address.";
                alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 11;
                [alert show];
            }
            else if (![Utils isValidEmailId:emailString]) {
                alertMsg = @"Invalid Email Address.";
                alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 11;
                [alert show];
            }
            else {
                if ([appDelegate.networkValue isEqualToString:wifiValue] || [appDelegate.networkValue isEqualToString:wwanValue]) {
                    [self startIndicator];
                    
                    NSDictionary *params = [NSDictionary dictionaryWithObject:emailString forKey:@"email"];
                    NSString *urlString = [NSString stringWithFormat:@"%@index.php/iman/forgotpassword", mainUrl];
                    [appDelegate callPostMethod:params connectionTag:queryForgotPassword urlString:urlString];
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet!", @"AlertView")  message:NSLocalizedString(@"No working internet connection is found.", @"AlertView") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"AlertView") otherButtonTitles:nil];
                    [alertView show];
                }
            }
        }
        else {
            [self.emailTextField becomeFirstResponder];
        }
    }
    else if (alertView.tag == 11) {
        [self forgotPwdClicked:nil];
    }
}

- (void) forgotPwdSuccessfully:(NSNotification *) notif
{
    [self stopIndicator];
    NSDictionary *resultDict = [notif object];
    NSLog(@"Result forgot dict: %@", resultDict);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    //[Utils saveToUserDefaults:resultDict forKey:UserProfileDictionary];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void) forgotPwdErrorFound:(NSNotification *) notif
{
    NSLog(@"forgot error...");
    [self stopIndicator];
    NSArray *metaArray = [notif object];
    [Utils showErrorAlertWithMessage:[metaArray valueForKey:@"message"] andDelegate:self];
}

- (void) forgotPwdFailed:(NSNotification *) notif
{
    NSLog(@"forgot failed...");
    [self stopIndicator];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
