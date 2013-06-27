//
//  CMSplashScreenViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/12/13.
//
//

#import "CMRootViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMUserModel.h"
#import "CMConstants.h"
#import "Logging.h"
#import "CMApplicationModel.h"
#import "CMFilterModel.h"
#import "SVProgressHUD.h"

@interface CMRootViewController ()
@property (nonatomic, strong) CMUserModel *userModel;
@end

@implementation CMRootViewController
@synthesize userModel = _userModel;

-(void) viewDidLoad
{
    // Get current version ("Bundle Version") from the default Info.plist file
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSArray *prevStartupVersions = [[NSUserDefaults standardUserDefaults] arrayForKey:@"prevStartupVersions"];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isFirstStart"];
    if (prevStartupVersions == nil)
    {
        // Starting up for first time with NO pre-existing installs (e.g., fresh
        // install of some version)
        //[self firstStartAfterFreshInstall];
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:currentVersion] forKey:@"prevStartupVersions"];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isFirstStart"];
        
    }
    else
    {
        if (![prevStartupVersions containsObject:currentVersion])
        {
            // Starting up for first time with this version of the app. This
            // means a different version of the app was alread installed once
            // and started.
            //[self firstStartAfterUpgradeDowngrade];
            NSMutableArray *updatedPrevStartVersions = [NSMutableArray arrayWithArray:prevStartupVersions];
            [updatedPrevStartVersions addObject:currentVersion];
            [[NSUserDefaults standardUserDefaults] setObject:updatedPrevStartVersions forKey:@"prevStartupVersions"];
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isFirstStart"];
        }
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    // if EXIT then... use the following line of code to exit the Plum Perfect part of the application.
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    // To hide the default navigation controller...
    [self.navigationController.navigationBar setHidden: YES];
    
    // To get user data...
    self.userModel = [[CMUserModel alloc] initForUserProfile];
    
    // To get the user map
    CMUserProfileMap *userData = [self.userModel getUserProfileMapObject];
    
    // Redirect to Home
    if(userData.userID == nil)
    {
         LogInfo(@"User needs to log in or register.");
        /*
         SOCKET: ADD LOGIN LOGIC.
         .
         .
         .
         */
        
        // Remove the below line when the login logic is added.
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    // To new register process
    else if ([userData.profileID intValue] == 0 || userData.profileID == nil)
    {
        LogInfo(@"User logged-in, but no profile.");
        [self performSegueWithIdentifier:@"showTakeMyPhoto" sender:self];
    }
    // To Product Landing Page
    else
    {
        LogInfo(@"User logged-in, redirecting to productLandingPage");
        
        // To redirect...
        [self performSegueWithIdentifier:@"showProductLandingView" sender:self];
        
        // To perform async operations if 1st time use...
        CMApplicationModel *cmApplicationModel = [[CMApplicationModel alloc] init];
        
        // To reset the cookie...
        [cmApplicationModel resetCookie];
        
        // Loading default values...
        if(![cmApplicationModel isDefaultValuesLoaded])
        {
            // To update the local user profile data from server...
            [self updateUserProfileFromServer];
                        
            // To update the filter data...
            CMFilterModel *filterModel = [[CMFilterModel alloc] init];
            filterModel = nil;
            
            // To set the default values are loaded...
            [cmApplicationModel setDefaultValuesLoaded:YES];
        }
    }

}


- (void) updateUserProfileFromServer
{
    
    NSURL *url = [NSURL URLWithString:[NSString
                                       stringWithFormat:@"%@%@", server, pathToAPICallForUserMyProfileInfo]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL: url];
    
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setHTTPShouldHandleCookies:YES];
    
    // NSLog(@"%@", [request allHTTPHeaderFields]);
    // NSLog(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    // NSLog(@"%@",[request valueForHTTPHeaderField:field]);
    
    AFJSONRequestOperation
    *operation = [AFJSONRequestOperation
                  JSONRequestOperationWithRequest:request
                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                  {
                      BOOL success=[[JSON objectForKey:@"success"] boolValue];
                      if (success)
                      {
                          LogInfo(@"Root view: User data updated successfully upon launch.");
                          [self.userModel updateUserProfileDataWithJSON:JSON];
                      }
                      else
                      {
                          LogInfo(@"ERROR: User data could not be updated JSON: %@", JSON);
                      }
                  }
                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                  {
                      LogError(@"Error while getting user data. \n Request:%@\n Response:%@\n Error:%@\n JSON:%@",
                               request, response, error, JSON);
                      
                      if(error.code == -1009)
                      {
                          [SVProgressHUD showErrorWithStatus:@"It appears you have lost internet connectivity. Please check your network settings."];
                      }
                  }];
    
    [operation start];
}



@end
