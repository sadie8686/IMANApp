//
//  UserProfileMap.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/27/13.
//
//

#import <Foundation/Foundation.h>

@interface CMUserProfileMap : NSObject
@property NSNumber *userID;
@property NSNumber *profileID;
@property NSURL *imageURL;
@property NSURL *originalImageURL;


@property UIColor *hairColor;
@property NSString *hairChroma;
@property NSString *hairTemp;
@property NSString *hairValue;
@property NSString *hairColorName;


@property UIColor *eyesColor;
@property NSString *eyesChroma;
@property NSString *eyesTemp;
@property NSString *eyesValue;
@property NSString *eyesColorName;


@property UIColor *lipsColor;
@property NSString *lipsChroma;
@property NSString *lipsTemp;
@property NSString *lipsValue;
@property NSString *lipsColorName;


@property UIColor *skinColor;
@property NSString *skinChroma;
@property NSString *skinTemp;
@property NSString *skinValue;
@property NSString *skinColorName;


- (void) updateWithJSON: (id) JSON;
- (void) updateWithJSONForUploadsImport: (id) JSON;
- (void) updateUserColorsWithJSON: (id) JSON;

@end
