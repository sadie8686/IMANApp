//
//  CMApplicationModel.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 1/31/13.
//
//

#import <Foundation/Foundation.h>
#import "CMProductMap.h"


@interface CMApplicationModel : NSObject

- (id) init;

- (void) setDeviceToken: (NSString *) deviceToken;
- (NSString *) getDeviceToken;

- (void) setDeviceTokenUploadedToServer: (BOOL) deviceTokenUploadedToServer;
- (BOOL) isDeviceTokenUploadedToServer;

- (void) setDefaultValuesLoaded: (BOOL) defaultValuesLoaded;
- (BOOL) isDefaultValuesLoaded;


- (BOOL) displayLightBox;
- (void) setToDisplayLightBox: (BOOL) hidden;



// For color correct...
- (void) setToColorCorrect: (BOOL) toColorCorrect;
- (BOOL) toColorCorrect;

- (void) setColorCorrectedValueWithEyeColor: (UIColor *) eyeColor
                              WithSkinColor: (UIColor *) skinColor
                               WithLipColor: (UIColor *) lipColor
                              WithHairColor: (UIColor *) hairColor;
- (UIColor *) colorCorrectedEyeColor;
- (UIColor *) colorCorrectedSkinColor;
- (UIColor *) colorCorrectedLipColor;
- (UIColor *) colorCorrectedHairColor;

- (void) setOriginalImage: (NSData *) imageData;
- (NSData *) getOriginalImage;

- (void) setIsColorCorrectSwitchOn: (BOOL) isColorCorrectSwitchOn;
- (BOOL) isColorCorrectSwitchOn;

- (void) clearColorCorrectedData;


// Cookie functions...
+ (void) storeCookie;
- (void) resetCookie;
+ (void) logout;


// Wishlist functions...
+ (BOOL) isWishlistItem: (CMProductMap *) product;
+ (void) addProductToWishlist: (CMProductMap *) product;
+ (void) removeProductFromWishlist: (CMProductMap *) product;


// Login functions...
+ (void) loginToPlumPerfectWithUsername: (NSString *) username
               withNavigationController: (UINavigationController *) navigationController;

+ (void) registerToPlumperfectWithUsername: (NSString *) username
                             WithFirstName: (NSString *) firstName
                              WithLastName: (NSString *) lastName
                  withNavigationController: (UINavigationController *) navigationController;
@end
