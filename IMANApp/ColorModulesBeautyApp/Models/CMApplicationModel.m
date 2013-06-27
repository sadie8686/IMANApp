//
//  CMApplicationModel.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 1/31/13.
//
//

#import "CMApplicationModel.h"
#import "CMConstants.h"
#import "SVProgressHUD.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMConstants.h"
#import "CMUserModel.h"
#import "Logging.h"
@interface CMApplicationModel()
@property (nonatomic, strong) NSMutableDictionary *applicationDictionary;
@end

@implementation CMApplicationModel
@synthesize applicationDictionary = _applicationDictionary;

- (id) init
{
    if (self = [super init]) {
        self.applicationDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:APPLICATION_KEY];
        
        if(!self.applicationDictionary)
        {
            self.applicationDictionary = [[NSMutableDictionary alloc] init];
            
            
            // set default values to be loaded when creating applicationDictionary on application load...
            [self.applicationDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isDeviceTokenUploadedToServer"];
            [self.applicationDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"toDisplayLightBoxOnProductLandingPage"];
            [self.applicationDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isDefaultValuesLoaded"];
            
            // synchronize the standard user defaults with current dictionary.
            [self synchronize];
        }
    }
    return self;
}

- (void) synchronize
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:APPLICATION_KEY];
    [standardUserDefaults setObject:self.applicationDictionary forKey:APPLICATION_KEY];
    [standardUserDefaults synchronize];
    standardUserDefaults = nil;
}

/*
 * Setter and getter for isDefaultValuesLoaded
 */
- (void) setDefaultValuesLoaded: (BOOL) defaultValuesLoaded
{
    // Checkout deepMutable...
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.applicationDictionary];
    [tempDict setValue:[NSNumber numberWithBool:defaultValuesLoaded]
                forKey:@"isDefaultValuesLoaded"];
    
    self.applicationDictionary = tempDict;
    [self synchronize];
}
- (BOOL) isDefaultValuesLoaded
{
    return ([[self.applicationDictionary objectForKey:@"isDefaultValuesLoaded"] boolValue]);
}


/*
 * Getter and setter for isDeviceTokenUploadedToServer...
 */
- (void) setDeviceTokenUploadedToServer: (BOOL) deviceTokenUploadedToServer
{
    // Checkout deepMutable...
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.applicationDictionary];
    [tempDict setValue:[NSNumber numberWithBool:deviceTokenUploadedToServer]
                forKey:@"isDeviceTokenUploadedToServer"];
    
    self.applicationDictionary = tempDict;
    [self synchronize];
}

- (BOOL) isDeviceTokenUploadedToServer
{
    return ([[self.applicationDictionary objectForKey:@"isDeviceTokenUploadedToServer"] boolValue]);
}


/*
 * getter and setter for device token...
 */

- (void) setDeviceToken: (NSString *) deviceToken
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.applicationDictionary];
    [tempDict setValue:deviceToken forKey:@"deviceToken"];
    
    self.applicationDictionary = tempDict;
    [self synchronize];
}

- (NSString *) getDeviceToken
{
    return ([self.applicationDictionary objectForKey:@"deviceToken"]);
}

/*
 * getter and setter for toDisplayLightBoxOnProductLandingPage...
 */
- (BOOL) displayLightBox
{
    return ([[self.applicationDictionary objectForKey:@"toDisplayLightBoxOnProductLandingPage"]boolValue]);
}

- (void) setToDisplayLightBox: (BOOL) hidden
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.applicationDictionary];
    [tempDict setValue:[NSNumber numberWithBool:hidden]
                forKey:@"toDisplayLightBoxOnProductLandingPage"];
    
    self.applicationDictionary = tempDict;
    [self synchronize];
}



/*
 * getter and setter for colorCorrect ON or OFF
 */
- (void) setToColorCorrect: (BOOL) toColorCorrect
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.applicationDictionary];
    [tempDict setValue:[NSNumber numberWithBool: toColorCorrect] forKey:@"toColorCorrect"];
    
    self.applicationDictionary = tempDict;
    [self synchronize];
}

- (BOOL) toColorCorrect
{
    return ([[self.applicationDictionary objectForKey:@"toColorCorrect"] boolValue]);
}

/*
 * getter and setter for Color corrected values...
 eyeColor,
 skinColor,
 lipColor,
 hairColor
 */
- (void) setColorCorrectedValueWithEyeColor: (UIColor *) eyeColor
                              WithSkinColor: (UIColor *) skinColor
                               WithLipColor: (UIColor *) lipColor
                              WithHairColor: (UIColor *) hairColor
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.applicationDictionary];
    
    [tempDict setValue:[NSKeyedArchiver archivedDataWithRootObject:eyeColor] forKey:@"colorCorrectedEyeColor"];
    [tempDict setValue:[NSKeyedArchiver archivedDataWithRootObject:skinColor] forKey:@"colorCorrectedSkinColor"];
    [tempDict setValue:[NSKeyedArchiver archivedDataWithRootObject:lipColor] forKey:@"colorCorrectedLipColor"];
    [tempDict setValue:[NSKeyedArchiver archivedDataWithRootObject:hairColor] forKey:@"colorCorrectedHairColor"];
    
    self.applicationDictionary = tempDict;
    [self synchronize];
}



- (UIColor *) colorCorrectedEyeColor
{
    return (
            (UIColor *)[NSKeyedUnarchiver
                        unarchiveObjectWithData:[self.applicationDictionary
                                                 objectForKey:@"colorCorrectedEyeColor"]]
            );
}


- (UIColor *) colorCorrectedSkinColor
{
    return (
            (UIColor *)[NSKeyedUnarchiver
                        unarchiveObjectWithData:[self.applicationDictionary
                                                 objectForKey:@"colorCorrectedSkinColor"]]
            );
}


- (UIColor *) colorCorrectedLipColor
{
    return (
            (UIColor *)[NSKeyedUnarchiver
                        unarchiveObjectWithData:[self.applicationDictionary
                                                 objectForKey:@"colorCorrectedLipColor"]]
            );
}


- (UIColor *) colorCorrectedHairColor
{
    return (
            (UIColor *)[NSKeyedUnarchiver
                        unarchiveObjectWithData:[self.applicationDictionary
                                                 objectForKey:@"colorCorrectedHairColor"]]
            );
}

/*
 * getter and setter for Color Correct Switch state
 */
- (void) setIsColorCorrectSwitchOn: (BOOL) isColorCorrectSwitchOn
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.applicationDictionary];
    [tempDict setValue:[NSNumber numberWithBool: isColorCorrectSwitchOn] forKey:@"isColorCorrectSwitchOn"];
    
    self.applicationDictionary = tempDict;
    [self synchronize];
}


- (BOOL) isColorCorrectSwitchOn
{
    return ([[self.applicationDictionary objectForKey:@"isColorCorrectSwitchOn"] boolValue]);
}


/*
 * Setter and getter for user's original image.
 */
- (void) setOriginalImage: (NSData *) imageData
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.applicationDictionary];
    [tempDict setObject:imageData forKey:@"originalImage"];
    self.applicationDictionary = tempDict;
    [self synchronize];
}

- (NSData *) getOriginalImage
{
    return ([self.applicationDictionary objectForKey:@"originalImage"]);
}


/*
 * To clear all color corrected data...
 */
- (void) clearColorCorrectedData
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.applicationDictionary];
    
    [tempDict removeObjectForKey:@"toColorCorrect"];
    [tempDict removeObjectForKey:@"colorCorrectedEyeColor"];
    [tempDict removeObjectForKey:@"colorCorrectedSkinColor"];
    [tempDict removeObjectForKey:@"colorCorrectedLipColor"];
    [tempDict removeObjectForKey:@"colorCorrectedHairColor"];
    [tempDict removeObjectForKey:@"isColorCorrectSwitchOn"];
    [tempDict removeObjectForKey:@"originalImage"];
    
    self.applicationDictionary = tempDict;
    [self synchronize];
}


/*
 * To store a cookie when the user logsIn successfully.
 */
+ (void) storeCookie
{
    NSData *cookiesData = [NSKeyedArchiver
                           archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject: cookiesData forKey: COOKIE_KEY];
    [standardUserDefaults synchronize];
}

- (void) resetCookie
{
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:COOKIE_KEY];
    if([cookiesdata length])
    {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        for (NSHTTPCookie *cookie in cookies)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
}

+ (void) deleteCookie
{
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:COOKIE_KEY];
    if([cookiesdata length])
    {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        for (NSHTTPCookie *cookie in cookies)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

+ (void) logout
{
    [self deleteCookie];
    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:APPLICATION_KEY];
    [standardUserDefaults removeObjectForKey:USER_PROFILE_KEY];
    [standardUserDefaults removeObjectForKey:FILTER_KEY];
    [standardUserDefaults removeObjectForKey:COOKIE_KEY];
    [standardUserDefaults removeObjectForKey:WISHLIST_KEY];
    [standardUserDefaults synchronize];
}


/*
 SOCKET: need to add the functionality from SOCKET's end.
 */
+ (BOOL) isWishlistItem: (CMProductMap *) product
{
   // product.externalID;
    
    return FALSE; //remove this line of code.
}


/*
 SOCKET: need to add the functionality from SOCKET's end.
 */
+ (void) addProductToWishlist: (CMProductMap *) product
{
    
}


/*
 SOCKET: need to add the functionality from SOCKET's end.
 */
+ (void) removeProductFromWishlist: (CMProductMap *) product
{
    
}


/*
 Method to login to plumperfect, need to provide the username.
 */
+ (void) loginToPlumPerfectWithUsername: (NSString *) username
               withNavigationController: (UINavigationController *) navigationController
{
     LogInfo(@"Logging into Plumperfect.");
    [SVProgressHUD showWithStatus:STR_LOADING maskType:SVProgressHUDMaskTypeGradient];
    
    // Send the login request to server.
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
                          LogInfo(@"Login successful.");
                          [[[CMUserModel alloc] initForUserProfile] updateUserProfileDataWithJSON:JSON];
                          [CMApplicationModel storeCookie];
                          
                          if(navigationController)
                          {
                              [navigationController popToRootViewControllerAnimated:YES];
                          }
                      }
                      else
                      {
                          int errorStatus = [[JSON objectForKey:@"status"] integerValue];
                          if(errorStatus == 401)
                          {
                              // Register the user
                              [CMApplicationModel registerToPlumperfectWithUsername:username
                                                                      WithFirstName:@"IMAN user" WithLastName:@" " withNavigationController:navigationController];
                          }
                          
                          LogError(@"Error While logging in. JSON: %@", JSON);
                      }
                      [SVProgressHUD dismiss];
                  }
                  
                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                  {
                      [SVProgressHUD showErrorWithStatus:@"It appears you have lost internet connectivity. Please check your network settings."];
                      
                      LogError(@"Login API FALIURE: API:%@ \nRequest Body: %@, \nResponse Status Code:%d, Response: %@ \nError Code:%d",
                            request,
                            [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding],
                            [response statusCode],
                            [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]], error.code);
                  }];
    
    
    [operation start];
    
}



+ (void) registerToPlumperfectWithUsername: (NSString *) username
                             WithFirstName: (NSString *) firstName
                              WithLastName: (NSString *) lastName
                  withNavigationController: (UINavigationController *) navigationController
{
    
    LogInfo(@"Email create account button pressed");
    
    // To start activity indicator and end editing.
    [SVProgressHUD showWithStatus:STR_LOADING maskType:SVProgressHUDMaskTypeGradient];
    
    // Send the information to server to register the new user.
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
                          LogInfo(@"Email registered successfully.");
                          CMUserModel *userModel = [[CMUserModel alloc] initForUserProfile];
                          [userModel updateUserProfileDataWithJSON:JSON];
                          [CMApplicationModel storeCookie];
                          NSLog(@"JSON: %@", JSON);
                          
                          if(navigationController)
                          {
                              [navigationController popToRootViewControllerAnimated:YES];
                          }
                      }
                      else
                      {
                          LogInfo(@"Error While registering. JSON: %@", JSON);
                      }
                      
                      [SVProgressHUD dismiss];
                  }
                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                  {
                      [SVProgressHUD showErrorWithStatus:@"It appears you have lost internet connectivity. Please check your network settings."];
                      LogInfo(@"Register API FALIURE: request: %@, response: %@, JSON: %@", request, response, JSON);
                  }];
    
    [operation start];
    
}
@end
