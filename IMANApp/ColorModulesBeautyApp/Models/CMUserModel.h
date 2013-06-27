//
//  CMUserInfoModel.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/12/13.
//
//

#import <Foundation/Foundation.h>
#import "CMUserProfileMap.h"
#import "CMProductMap.h"


@interface CMUserModel : NSObject

// Profile details...
- (id) initForUserProfile;
- (CMUserProfileMap *) getUserProfileMapObject;
- (void) updateUserProfileDataWithJSON: (id) JSON;
- (void) updateUserProfileDataWithJSONForUploadsImport: (id) JSON;
- (void) updateUserColorsWithJSON:(id)JSON;
- (void) synchronize;

@end
