//
//  RegistrationViewController.m
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "RegistrationViewController.h"
#import "Constants.h"
#import "DejalActivityView.h"
#import "CMConstants.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMApplicationModel.h"
#import "CMUserModel.h"
@interface RegistrationViewController ()
@end

@implementation RegistrationViewController

@synthesize table;
@synthesize userNameTextField, passwordTextField, emailTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationSuccessfully:) name:RegistrationSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationErrorFound:) name:RegistrationErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationFailed:) name:RegistrationFailedNotification object:nil];
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
    [rightButton addTarget:self action:@selector(registration:) forControlEvents:UIControlEventTouchUpInside];
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
    [userNameTextField becomeFirstResponder];
}

- (void) registration:(id) sender
{
    if ([self validateData]) {
        NSLog(@"Validated");
        
        if ([appDelegate.networkValue isEqualToString:wifiValue] || [appDelegate.networkValue isEqualToString:wwanValue]) {
            [self startIndicator];
            NSString *urlString = [NSString stringWithFormat:@"%@index.php/iman/register", mainUrl];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:userNameTextField.text, @"username", emailTextField.text, @"email", passwordTextField.text, @"password", @"ios", @"device_type", [Utils getObjectFromUserdefaultsWithKey:kDeviceID], @"device_id", nil];
            [appDelegate callPostMethod:params connectionTag:queryRegistration urlString:urlString];
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

- (void) registrationSuccessfully:(NSNotification *) notif
{
    NSDictionary *resultDict = [notif object];
    NSString *eMail=[resultDict valueForKey:@"email"];
    NSString *firstName=[resultDict valueForKey:@"username"];
    NSString *lastName=@"...";
    [self registerToPlumperfectWithUsername:eMail WithFirstName:firstName WithLastName:lastName];
    NSLog(@"Result dict: %@", resultDict);
    [Utils saveToUserDefaults:resultDict forKey:UserProfileDictionary];
}
-(void) registerToPlumperfectWithUsername:(NSString *)username WithFirstName:(NSString *)firstName WithLastName:(NSString *)lastName
{
    NSURL *url = [NSURL URLWithString: server];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            username, @"email",
                            firstName, @"first_name",
                            lastName, @"last_name",
                            @"NYTM", @"inviter",
                            IMAN_PLUMPERFECT_TOKEN, @"api_token",
                            nil];
    
    NSMutableURLRequest *request = [httpClient
                                    requestWithMethod:@"POST"
                                    path: pathToAPICallForNewRegisterSeller
                                    parameters: params];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    AFJSONRequestOperation
    *operation = [AFJSONRequestOperation
                  JSONRequestOperationWithRequest:request
                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                  {
                      BOOL success=[[JSON objectForKey:@"success"] boolValue];
                      if (success)
                      {
                          [self stopIndicator];
                          CMUserModel *userModel = [[CMUserModel alloc] initForUserProfile];
                          [userModel updateUserProfileDataWithJSON:JSON];
                          [CMApplicationModel storeCookie];
                          NSLog(@"JSON: %@", JSON);
                      }
                      else
                      {
                          [self stopIndicator];
                          [Utils showErrorAlertWithMessage:@"Error in PlumPerfect Registration." andDelegate:self];
                      }
                      [self.navigationController popViewControllerAnimated:YES];
                  }
                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                  {
                      [self stopIndicator];
                      [Utils showErrorAlertWithMessage:@"There's some problem in server. Try again later." andDelegate:self];
                      [self.navigationController popViewControllerAnimated:YES];
                  }];
    [operation start];
}

- (void) registrationErrorFound:(NSNotification *) notif
{
    NSLog(@"Reg error...");
    [self stopIndicator];
    [userNameTextField becomeFirstResponder];
    NSArray *metaArray = [notif object];
    [Utils showErrorAlertWithMessage:[metaArray valueForKey:@"message"] andDelegate:self];
}

- (void) registrationFailed:(NSNotification *) notif
{
    NSLog(@"Reg failed...");
    [self stopIndicator];
    [userNameTextField becomeFirstResponder];
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
    return 3;
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
    CGRect textfieldFrame = CGRectMake(110, 11, 190, 25);
    
    if(indexPath.row == 0)
    {
        UILabel *userNameLbl = [[UILabel alloc] initWithFrame:lableFrame];
        [userNameLbl setText:@"Name:"];
        userNameLbl.font = staticFont;
        [userNameLbl setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:userNameLbl];
        
        userNameTextField = [[UITextField alloc] initWithFrame:textfieldFrame];
        userNameTextField.returnKeyType = UIReturnKeyNext;
        userNameTextField.delegate = self;
        [userNameTextField setPlaceholder:@"Enter User name"];
        userNameTextField.userInteractionEnabled = YES;
        userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [userNameTextField setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:userNameTextField];
    }
    
    else if(indexPath.row == 1)
    {
        UILabel *passwordLbl=[[UILabel alloc] initWithFrame:lableFrame];
		[passwordLbl setText:@"Password:"];
        passwordLbl.font = staticFont;
		[passwordLbl setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:passwordLbl];
        
		passwordTextField=[[UITextField alloc]initWithFrame:textfieldFrame];
        passwordTextField.returnKeyType = UIReturnKeyNext;
		[passwordTextField setPlaceholder:@"Enter password"];
        [passwordTextField setSecureTextEntry:YES];
        passwordTextField.delegate = self;
        passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[passwordTextField setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:passwordTextField];
    }
    
    else if(indexPath.row == 2)
    {
        UILabel *emailLabel=[[UILabel alloc]initWithFrame:lableFrame];
		[emailLabel setText:@"Email:"];
        emailLabel.font = staticFont;
		[emailLabel setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:emailLabel];
		
		emailTextField=[[UITextField alloc]initWithFrame:textfieldFrame];
        emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        emailTextField.returnKeyType = UIReturnKeyGo;
		[emailTextField setPlaceholder:@"Enter email address"];
        emailTextField.delegate = self;
        emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[emailTextField setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:emailTextField];
	}
	
    return cell;
}

//just hide the keyboard in this example
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == userNameTextField){
        [passwordTextField becomeFirstResponder];
    }
    else if (textField == passwordTextField){
        [emailTextField becomeFirstResponder];
    }
    else if (textField == emailTextField){
        [emailTextField becomeFirstResponder];
        [self registration:nil];
    }
    return YES;
}

- (BOOL) validateData
{
    [self.view endEditing:YES];
    NSString *alertTitle = @"Error!";
    NSString *alertMsg = @"";
    UIAlertView *alert;
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange range = [userNameTextField.text rangeOfCharacterFromSet:whitespace];
    
    if ([userNameTextField.text length] == 0) {
        alertMsg = @"Enter User Name.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [userNameTextField becomeFirstResponder];
        return NO;
    }
    else if ([userNameTextField.text length] < 4) {
        alertMsg = @"User Name must be atleast four characters.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [userNameTextField becomeFirstResponder];
        return NO;
    }
    else if (range.location != NSNotFound) {
        alertMsg = @"User name can not contain white space.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [userNameTextField becomeFirstResponder];
        return NO;
    }
    else if ([passwordTextField.text length] == 0) {
        alertMsg = @"Enter Password.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [passwordTextField becomeFirstResponder];
        return NO;
    }
    else if ([passwordTextField.text length] < 4) {
        alertMsg = @"Password cannot be less than 4 characters.";
        alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [passwordTextField becomeFirstResponder];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
