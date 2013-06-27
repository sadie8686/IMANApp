//
//  IMANAppDelegate.m
//  IMANApp
//
//  Created by  on 19/02/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "IMANAppDelegate.h"
#import "Constants.h"
#import "Reachability.h"
#import "AFNetworking.h"
#import "JSON.h"
#import "SplashViewController.h"
#import "IMANHomeViewController.h"
#import "IMANSettingsViewController.h"
#import "FacebookSDK/FacebookSDK.h"

NSString *const FBSessionStateChangedNotification = @"ColorModules.Plum-Perfect:FBSessionStateChangedNotification";

@implementation IMANAppDelegate

@synthesize networkValue, homeMenuIndex;
@synthesize locationManager, productSubCategaoryArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  #define TESTING 1
  #ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
  #endif
    [TestFlight takeOff:@"3f5d07b9-5f93-473f-bd62-875e809e524c"];
    
    homeMenuIndex = 99;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    productSubCategaoryArray = [[NSMutableDictionary alloc] init];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    Reachability *intReach = [Reachability reachabilityForInternetConnection];
    intReach.reachableOnWWAN = YES;
    [intReach startNotifier];
    // tell the reachability that we DONT want to be reachable on 3G/EDGE/CDMA, set to NO (If so)
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    reach.reachableOnWWAN = YES;
    [reach startNotifier];
    
    [self tabBarControllerInititalize];
    
    
    
    locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
    locationManager.purpose = NSLocalizedString(@"We use location to track you and invade your privacy", @"");
    
    
//    BCDShareSheet *sharer = [BCDShareSheet sharedSharer];
//    [sharer setRootViewController:self.tabBarController];
//    [sharer setFacebookAppID:@"466050693448920"];
//    [sharer setAppName:@"IMAN Cosmetics"];
    
    SplashViewController *splashViewController = [[SplashViewController alloc] init];
    self.window.rootViewController = splashViewController;
    
    [self.window makeKeyAndVisible];
    [self customizeAppearance];
    return YES;
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        networkValue = @"not"; //Not reachable
    }
    if (netStatus == ReachableViaWWAN) {
        networkValue = @"wwan"; //Reachable via 3g
    }
    if (netStatus == ReachableViaWiFi) {
        networkValue = @"wifi"; //Reachable via wifi
    }
    
    NSLog(@"Net: %@", networkValue);
    //if([reach isReachable])  for only connectivity
}

- (void) tabBarControllerInititalize
{
    [self customizeInterface];
    
    UIViewController *viewController0 = [[IMANHomeViewController alloc] initWithNibName:@"IMANHomeViewController" bundle:nil];
    UINavigationController *navController0 = [[UINavigationController alloc]initWithRootViewController:viewController0];
    [navController0 setNavigationBarHidden:YES animated:NO];
    
    UINavigationController *navController1 =[UINavigationController alloc];
    navController1.tabBarItem.title = @"";
    UIImage *tab0Image = [UIImage imageNamed:@"shop.png"];
    UITabBarItem *tab0 = [[UITabBarItem alloc] initWithTitle:@"" image:tab0Image tag:0];
    float topInset = 5.0f;
    tab0.imageInsets = UIEdgeInsetsMake(topInset, 0.0f, -topInset, 0.0f);
    [tab0 setFinishedSelectedImage:tab0Image withFinishedUnselectedImage:tab0Image];
    [navController1 setTabBarItem:tab0];

    UINavigationController *navController2 =[UINavigationController alloc];
    navController2.tabBarItem.title = @"";
    UIImage *tab1Image = [UIImage imageNamed:@"fav.png"];
    UITabBarItem *tab1 = [[UITabBarItem alloc] initWithTitle:@"" image:tab1Image tag:0];
    tab1.imageInsets = UIEdgeInsetsMake(topInset, 0.0f, -topInset, 0.0f);
    [tab1 setFinishedSelectedImage:tab1Image withFinishedUnselectedImage:tab1Image];
    [navController2 setTabBarItem:tab1];

    UINavigationController *navController3 =[UINavigationController alloc];
    navController3.tabBarItem.title = @"";
    UIImage *tab2Image = [UIImage imageNamed:@"searchtab.png"];
    UITabBarItem *tab2 = [[UITabBarItem alloc] initWithTitle:@"" image:tab2Image tag:0];
    tab2.imageInsets = UIEdgeInsetsMake(topInset, 0.0f, -topInset, 0.0f);
    [tab2 setFinishedSelectedImage:tab2Image withFinishedUnselectedImage:tab2Image];
    [navController3 setTabBarItem:tab2];
    
    UIViewController *viewController4 = [[IMANSettingsViewController alloc] initWithNibName:@"IMANSettingsViewController" bundle:nil];
    UINavigationController *navController4 = [[UINavigationController alloc]initWithRootViewController:viewController4];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[navController0, navController1,navController2,navController3 ,navController4];
}

#pragma mark -
#pragma mark Location manager


/**
 Return a location manager -- create one if necessary.
 */

- (CLLocationManager *)locationManager {
    if (locationManager != nil) {
		return locationManager;
	}
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
    locationManager.purpose = NSLocalizedString(@"We use location to track you and invade your privacy", @"");
	
	return locationManager;
}

/**
 Conditionally enable the Add button:
 If the location manager is generating updates, then enable the button;
 If the location manager is failing, then disable the button.
 **/
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    NSLog(@"didUpdateLocation fired...");
    [locationManager stopUpdatingLocation];
    NSLog(@"Latitude: %.6f, longitude: %.6f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
    
    NSNotification *notif = [NSNotification notificationWithName:CallStoreLocatorNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notif];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didfailWithError");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                    message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (void)customizeInterface
{
    UIImage* tabBarBackground = [UIImage imageNamed:@"tab_bar.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceTokenData
{
    NSString *iosDeviceID = [[[[deviceTokenData description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    [Utils saveToUserDefaults:iosDeviceID forKey:kDeviceID];
    NSLog(@"Device token is: %@", iosDeviceID);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSString *iosDeviceID = [NSString stringWithFormat:@"%d", 0];
    [Utils saveToUserDefaults:iosDeviceID forKey:kDeviceID];
	NSLog(@"Failed to get token, error: %@", error);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"User info: %@", userInfo);
}

- (void) callPostMethod:(NSDictionary *)params connectionTag:(int)tag urlString:(NSString *)urlStr
{
    NSURL *baseURL = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [httpClient defaultValueForHeader:@"Accept"];
    NSLog(@"Url: %@", urlStr);
    NSLog(@"Params: %@", params);
    
    [httpClient postPath:@"method" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // reponseObject will hold the data returned by the server.
        NSData *resp = (NSData *) responseObject;
        NSString *resultString=[[NSString alloc]initWithData:resp encoding:NSUTF8StringEncoding];
        NSLog(@"Result string: %@", resultString);
        NSMutableArray *responseArray = [resultString JSONValue];
        //NSLog(@"Response array: %@", responseArray);
        NSMutableArray *metaArray = [responseArray valueForKey:@"meta"];
        int code = [[metaArray valueForKey:@"code"] intValue];
        NSLog(@"Code: %d", code);
        
        if (code == 200) {
            NSMutableArray *resultArray = [[NSMutableArray alloc] init];
            resultArray = [responseArray valueForKey:@"result"];
            NSLog(@"Result: %@", resultArray);
            
            switch (tag) {
                case queryRegistration: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:RegistrationSuccessNotification object:resultArray];
                    break;
                }
                case queryLogin: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccessNotification object:resultArray];
                    break;
                }
                case queryLogout: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:LogoutSuccessNotification object:resultArray];
                    break;
                }
                case queryUpdateProfile: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ProfileUpdateSuccessNotification object:resultArray];
                    break;
                }
                case queryChangePassword: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ChangePasswordSuccessNotification object:resultArray];
                    break;
                }
                case queryForgotPassword: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ForgotPasswordSuccessNotification object:resultArray];
                    break;
                }
                default:
                    break;
            }
        }
        else {
            switch (tag) {
                case queryRegistration: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:RegistrationErrorNotification object:metaArray];
                    break;
                }
                case queryLogin: {
                    NSLog(@"Error found...");
                    [[NSNotificationCenter defaultCenter] postNotificationName:LoginErrorNotification object:metaArray];
                    break;
                }
                case queryLogout: {
                    NSLog(@"Error found...");
                    [[NSNotificationCenter defaultCenter] postNotificationName:LogoutErrorNotification object:metaArray];
                    break;
                }
                case queryUpdateProfile: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ProfileUpdateErrorNotification object:metaArray];
                    break;
                }
                case queryChangePassword: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ChangePasswordErrorNotification object:metaArray];
                    break;
                }
                case queryForgotPassword: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ForgotPasswordErrorNotification object:metaArray];
                    break;
                }
                default:
                    break;
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error retrieving data: %@", error);
        switch (tag) {
            case queryRegistration: {
                [[NSNotificationCenter defaultCenter] postNotificationName:RegistrationFailedNotification object:nil];
                break;
            }
            case queryLogin: {
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginFailedNotification object:nil];
                break;
            }
            case queryLogout: {
                [[NSNotificationCenter defaultCenter] postNotificationName:LogoutFailedNotification object:nil];
                break;
            }
            case queryUpdateProfile: {
                [[NSNotificationCenter defaultCenter] postNotificationName:ProfileUpdateFailedNotification object:nil];
                break;
            }
            case queryChangePassword: {
                [[NSNotificationCenter defaultCenter] postNotificationName:ChangePasswordFailedNotification object:nil];
                break;
            }
            case queryForgotPassword: {
                [[NSNotificationCenter defaultCenter] postNotificationName:ForgotPasswordFailedNotification object:nil];
                break;
            }
            default:
                break;
        }
    }];
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewControlle {
    if (tabBarController.selectedIndex == 3) {
        //if the user will select tab  3 so user will not go to it
        NSLog(@"Tab 3 selected...");
        return NO;
    }else{
        // if any other tab so return yse will let you to other tabs
        NSLog(@"Other tab selected...");
        return YES;
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
    
//    NSLog(@"Url scheme: %@", [url scheme]);
//    if ([[url scheme] hasPrefix:@"fb"]) {
//        return [[BCDShareSheet sharedSharer] openURL:url];
//    } else {
//        return NO; // handle any other URLs your app responds to here.
//    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // To properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/
- (void) customizeAppearance
{
    // Status Bar...
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    // UISlider...
    UIImage *minImage = [[UIImage imageNamed:@"horizontal_price_bar.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage *maxImage = [[UIImage imageNamed:@"horizontal_price_bar_grey.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage *thumbImage = [UIImage imageNamed:@"downward_small_arrow_s.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    
    [[UISlider appearance] setThumbImage:thumbImage      forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage      forState:UIControlStateHighlighted];
    
}
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            // Facebook Session is open...
            NSLog(@"Facebook Session is open.");
            break;
        }
            
        case FBSessionStateClosed:{
            // Facebook session has been closed...
            [FBSession.activeSession closeAndClearTokenInformation];
            [self showAlertWithTitle:@"Facebook" WithMessage:@"You have successfully logged out."];
            NSLog(@"Facebook Session is Closed.");
            break;
        }
            
            
        case FBSessionStateClosedLoginFailed: {
            // Facebook session has been failed...
            [FBSession.activeSession closeAndClearTokenInformation];
            [self showAlertWithTitle:@"Facebook" WithMessage:@"Could not login via Facebook."];
            NSLog(@"Facebook session is closed and login failed.");
            break;
        }
        default:
            break;
    }
    
    // To notify that the facebook session has changed...
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        NSLog(@"Facebook Login Error: %@", error);
    }
}




/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    
    NSArray *permissions = [[NSArray alloc] initWithObjects: @"email", nil];
    
    return [FBSession
            openActiveSessionWithReadPermissions:permissions
            allowLoginUI:allowLoginUI
            completionHandler:^(FBSession *session,
                                FBSessionState state,
                                NSError *error) {
                [self sessionStateChanged:session
                                    state:state
                                    error:error];
            }];
}

/*
 * To display the alert.
 */
- (void) showAlertWithTitle: (NSString *) title
                WithMessage: (NSString *) message
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}


@end
