//
//  IMANSettingsViewController.m
//  IMANApp
//
//  Created by  on 19/02/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "IMANSettingsViewController.h"
#import "Constants.h"

#import "RegistrationViewController.h"
#import "LoginViewController.h"
#import "MyProfileViewController.h"
#import "ChangePasswordViewController.h"

#import "DejalActivityView.h"

@interface IMANSettingsViewController ()

@end

@implementation IMANSettingsViewController

@synthesize settingsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Settings", @"Settings");
        self.tabBarItem.title = @"";
        
        UIImage *tab0Image = [UIImage imageNamed:@"settingstab.png"];
        UITabBarItem *tab0 = [[UITabBarItem alloc] initWithTitle:@"" image:tab0Image tag:0];
        float topInset = 5.0f;
        tab0.imageInsets = UIEdgeInsetsMake(topInset, 0.0f, -topInset, 0.0f);
        [tab0 setFinishedSelectedImage:tab0Image withFinishedUnselectedImage:tab0Image];
        [self setTabBarItem:tab0];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccessfully:) name:LogoutSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutErrorFound:) name:LogoutErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutFailed:) name:LogoutFailedNotification object:nil];
    }
    return self;
}

- (void) customUISettings
{
    self.navigationItem.titleView = [Constants customTitleLabel:self.title];
    self.title = @"";
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
    
    //Nav bar background image
    UIImage* navImage = [UIImage imageNamed:kNavImg];
    [self.navigationController.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
    
    [self.settingsTable reloadData];
}

- (void) logoutSuccessfully:(NSNotification *) notif
{
    [self stopIndicator];
    self.view.userInteractionEnabled = YES;
    
    [Utils removeFromUserDefaults:UserProfileDictionary];
    [self.settingsTable reloadData];
}

- (void) logoutErrorFound:(NSNotification *) notif
{
    [self stopIndicator];
    self.view.userInteractionEnabled = YES;
    NSArray *metaArray = [notif object];
    [Utils showErrorAlertWithMessage:[metaArray valueForKey:@"message"] andDelegate:self];
}

- (void) logoutFailed:(NSNotification *) notif
{
    [self stopIndicator];
    self.view.userInteractionEnabled = YES;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if ([Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary]) {

        return @"Account";
        }
        else
        {
             return @"Want to receive exclusive updates, offers, specials and promotional information. \nRegister now! It's quick and easy";
        }
        
                //return @"ACCOUNT";
    }
    else {
        return @"OTHER";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary]) {
            return 3;
        }
        else {
            return 2;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0) {
        if ([Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary]) {
            if (row == 0) { //My Profile text
                return [self cellForMyProfile];
            }
            else if (row == 1) { //Change Password text
                return [self cellForChangePassword];
            }
            else if (row == 2) { //Logout text
                return [self cellForLogout];
            }
        }
        else {
            if (row == 0) { //Register text
                return [self cellForRegister];
            }
            else if (row == 1) { //Login text
                return [self cellForLogin];
            }
        }
    }
    
    return [self blankCell];
}

#pragma mark - cell generators
- (UITableViewCell *)blankCell
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.settingsTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

//With login
- (UITableViewCell *)cellForMyProfile
{
    UITableViewCell *cell = [self blankCell];
    
    UIFont *lblFont = [UIFont fontWithName:@"helvetica" size:16.0];
    UILabel *icLabel = [Constants iconLabelSettings];
    
    UILabel *textmainLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 160, 23)];
    textmainLbl.backgroundColor = [UIColor clearColor];
    textmainLbl.textColor = [UIColor darkGrayColor];
    textmainLbl.font = lblFont;
    
    icLabel.text = [NSString fontAwesomeIconStringForEnum:FAIconUser];
    textmainLbl.text = @"My Profile";
    
    [cell.contentView addSubview:icLabel];
    [cell.contentView addSubview:textmainLbl];
    
    return cell;
}

- (UITableViewCell *)cellForChangePassword
{
    UITableViewCell *cell = [self blankCell];
    
    UIFont *lblFont = [UIFont fontWithName:@"helvetica" size:16.0];
    UILabel *icLabel = [Constants iconLabelSettings];
    
    UILabel *textmainLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 160, 23)];
    textmainLbl.backgroundColor = [UIColor clearColor];
    textmainLbl.textColor = [UIColor darkGrayColor];
    textmainLbl.font = lblFont;
    
    icLabel.text = [NSString fontAwesomeIconStringForEnum:FAIconKey];
    textmainLbl.text = @"Change Password";
    
    [cell.contentView addSubview:icLabel];
    [cell.contentView addSubview:textmainLbl];
    
    return cell;
}

- (UITableViewCell *)cellForLogout
{
    UITableViewCell *cell = [self blankCell];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UIFont *lblFont = [UIFont fontWithName:@"helvetica" size:16.0];
    UILabel *icLabel = [Constants iconLabelSettings];
    
    UILabel *textmainLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 160, 23)];
    textmainLbl.backgroundColor = [UIColor clearColor];
    textmainLbl.textColor = [UIColor darkGrayColor];
    textmainLbl.font = lblFont;
    
    icLabel.text = [NSString fontAwesomeIconStringForEnum:FAIconSignout];
    textmainLbl.text = @"Sign out";
    
    [cell.contentView addSubview:icLabel];
    [cell.contentView addSubview:textmainLbl];
    
    return cell;
}

//Without login
- (UITableViewCell *)cellForRegister
{
    UITableViewCell *cell = [self blankCell];
    
    UIFont *lblFont = [UIFont fontWithName:@"helvetica" size:16.0];
    UILabel *icLabel = [Constants iconLabelSettings];
    
    UILabel *textmainLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 160, 23)];
    textmainLbl.backgroundColor = [UIColor clearColor];
    textmainLbl.textColor = [UIColor darkGrayColor];
    textmainLbl.font = lblFont;
    
    icLabel.text = [NSString fontAwesomeIconStringForEnum:FAIconUser];
    textmainLbl.text = @"Register";
    
    [cell.contentView addSubview:icLabel];
    [cell.contentView addSubview:textmainLbl];
    
    return cell;
}

- (UITableViewCell *)cellForLogin
{
    UITableViewCell *cell = [self blankCell];
    
    UIFont *lblFont = [UIFont fontWithName:@"helvetica" size:16.0];
    UILabel *icLabel = [Constants iconLabelSettings];
    
    UILabel *textmainLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 160, 23)];
    textmainLbl.backgroundColor = [UIColor clearColor];
    textmainLbl.textColor = [UIColor darkGrayColor];
    textmainLbl.font = lblFont;
    
    icLabel.text = [NSString fontAwesomeIconStringForEnum:FAIconSignin];
    textmainLbl.text = @"Sign in";
    
    [cell.contentView addSubview:icLabel];
    [cell.contentView addSubview:textmainLbl];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.settingsTable deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0) {
        UIViewController *pushControl;
        if ([Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary]) {
            if (row == 0) { //My Profile text
                pushControl = [[MyProfileViewController alloc] init];
                pushControl.title = @"My Profile";
                [self.navigationController pushViewController:pushControl animated:YES];
            }
            else if (row == 1) { //Change Password text
                pushControl = [[ChangePasswordViewController alloc] init];
                pushControl.title = @"Change Password";
                [self.navigationController pushViewController:pushControl animated:YES];
            }
            else if (row == 2) { //Logout text
                UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign out", nil];
                logoutAlert.tag = 21;
                [logoutAlert show];
                return;
            }
        }
        else {
            if (row == 0) { //Register text
                pushControl = [[RegistrationViewController alloc] init];
                pushControl.title = @"Registration";
                [self.navigationController pushViewController:pushControl animated:YES];
            }
            else if (row == 1) { //Login text
                pushControl = [[LoginViewController alloc] init];
                pushControl.title = @"Sign In";
                [self.navigationController pushViewController:pushControl animated:YES];
            }
        }
    }
    else {
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 21) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if ([appDelegate.networkValue isEqualToString:wifiValue] || [appDelegate.networkValue isEqualToString:wwanValue]) {
                [self startIndicator];
                self.view.userInteractionEnabled = NO;
                NSString *urlString = [NSString stringWithFormat:@"%@index.php/iman/logout", mainUrl];
                NSDictionary *userProf = [Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary];
                NSString *uid = [userProf objectForKey:UserID];
                
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"userid", @"ios", @"device_type", [Utils getObjectFromUserdefaultsWithKey:kDeviceID], @"device_id", nil];
                [appDelegate callPostMethod:params connectionTag:queryLogout urlString:urlString];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet!", @"AlertView")  message:NSLocalizedString(@"No working internet connection is found.", @"AlertView") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"AlertView") otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
