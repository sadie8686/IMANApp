//
//  CMUserInfoModel.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/12/13.
//
//

#import "CMUserModel.h"
#import "CMUserProfileMap.h"
#import "CMApplicationModel.h"
#import "CMProductMap.h"
#import "CMConstants.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "Logging.h"

@interface CMUserModel()
@property (nonatomic, strong) CMUserProfileMap *userProfileData;
@end


@implementation CMUserModel
@synthesize userProfileData = _userProfileData;


- (id) initForUserProfile
{
    if (self = [super init]) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSData *myEncodedObject = [standardUserDefaults objectForKey:USER_PROFILE_KEY];
        
        if(!myEncodedObject)
        {
            // creating new userProfileData...
            self.userProfileData = [[CMUserProfileMap alloc] init];
            
            // synchronize the standard user defaults with current dictionary.
            [self synchronize];
        }
        else
        {
            self.userProfileData = (CMUserProfileMap *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
        }
    }
    return self;
}

- (void) synchronize
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:USER_PROFILE_KEY];
    
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.userProfileData];
    [standardUserDefaults setObject:myEncodedObject forKey:USER_PROFILE_KEY];
    [standardUserDefaults synchronize];
}

- (CMUserProfileMap *) getUserProfileMapObject
{
    return self.userProfileData;
}

- (void) updateUserProfileDataWithJSON: (id) JSON
{
    [self.userProfileData updateWithJSON:[JSON objectForKey:@"data"]];
    [self synchronize];
}

- (void) updateUserColorsWithJSON:(id)JSON
{
    [self.userProfileData updateUserColorsWithJSON:[[JSON objectForKey:@"data"] objectForKey:@"profile"]];
    [self synchronize];
}

- (void) updateUserProfileDataWithJSONForUploadsImport: (id) JSON
{
    [self.userProfileData updateWithJSONForUploadsImport:[JSON objectForKey:@"data"]];
    [self synchronize];
}

@end