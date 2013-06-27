//
//  constants.h
//  ColorModulesBeautyApp
//
//  Created by Nicky Liu on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// ############# VERY IMPORTANT: MAKE SURE THE PRODUCTION SERVER IS USED IN FINAL RELEASE #############

// Production Serve
#define server @"http://www.plumperfect.com"

// dev server
//#define server @"http://50.116.24.182:5002" // TO DO: MAKE SURE NOT TO USE EXCEPT FOR DEBUGGING


// SOCKET token...
#define IMAN_PLUMPERFECT_TOKEN @"$2a$12$P8PzK2nWe5x4A37pFf.nsekEi.UjjcMRGwbwgnnCe3S8.HDG/QrVm"

// Social Network Keys...
// SOCKET: change this with your twitter auth values.
#define twitterConsumerKey @"<SOCKET: ENTER KEY>"
#define twitterConsumerSecret @"<SOCKET: ENTER SECRET>"

// SOCKET seller_id
#define SOCKET_SELLER_ID @"21"

// UserDefault Keys...
#define USER_PROFILE_KEY @"cmPlumPerfectUserProfileKey"
#define APPLICATION_KEY @"cmPlumPerfectAppliationKey"
#define COOKIE_KEY @"cmPlumPerfectCookieKey"
#define FILTER_KEY @"cmPlumPerfectFliterKey"
#define WISHLIST_KEY @"cmPlumPerfectWishlistKey"
#define PRODUCT_KEY @"cmPlumPerfectProductKey"

#define VIEW_LOCATION_TOP 1
#define VIEW_LOCATION_BOTTOM 2

// Images....
#define backgroundImageName @"pattern.png"
#define IMAGE_WISHLIST_SELECTED @"HeartIcon_Pressed.png"
#define IMAGE_WISHLIST @"HeartIcon.png"
#define PLACEHOLDER_IMG @"App_logo_no_hearts_144.png"

// Login, register and user APIs....
#define pathToAPICallForNewRegisterSeller @"/api/users/register/seller"
#define pathToAPICallForLoginSeller @"/api/login/seller"
#define pathToAPICallForLogin @"/api/login/ios"


// Profile APIs...
#define pathToAPICallForUserMyProfileInfo @"/api/users/profile"
#define pathToAPICallToGetAllProfiles @"/api/users/profiles"
#define pathToAPICallToActivateProfileID @"/api/users/profile/active/" // /api/users/profile/active/{id} [POST]
#define pathToAPICallToDeleteProfileID @"/api/users/profile/active/" // /api/users/profile/active/{id} [DELETE]

// Uploading profile Image / color APIs...
#define pathToAPICAllForUploadingProfileImage @"/api/uploads/import"
#define pathToAPICAllForUploadingNewProfileImage @"/api/uploads/new"
#define pathToAPICallForUpdatingUserColorSignature @"/api/profiles/references/update"

// Recommendations and product APIs...
#define pathToAPICallForRecommendationEngine @"/api/profiles/products"
#define pathToAPICallForCheckingIfProductMatch @"/api/profiles/product/match"

// Product APIs...
#define pathToAPICallForGettingFeaturedProducts @"/api/products/featured"
#define pathToAPICallForGettingSearchedProducts @"/api/products/search-products"


// Wishlist APIs...
#define pathToAPICallForGettingWishlistProducts @"/api/users/products"
#define pathToAPICallForSavingItemsToWishlist @"/api/users/products/save"
#define pathToAPICallForDeletingItemsFromWishlist @"/api/users/products/delete"


// General APIs...
#define pathToAPICallForUpdatingDeviceToken @"/api/users/ios/device-token"
#define pathToAPICallForGettingAllFilters @"/api/products/filters"


/*
 /api/users/profile (see user_profile in apiref.json)
 /api/users/profiles (response:  key `profiles`:  list of user profiles, each formated like above)
 /api/users/profile/active/{id} [POST] (same as /api/users/profile)
 /api/users/profile/active/{id} [DELETE] (/api/users/profile)
*/


// ProductTypeIds....
#define productTypeIdForLips @"1"
#define productTypeIdForFace @"2"
#define productTypeIdForEyes @"3"

// SubCategoryIds for lips....
#define subCategoryIdForLipgloss @"13"
#define subCategoryIdForLipstick @"16"
#define subCategoryIdForLipliner @"43"
#define subCategoryIdForLipstains @"44"
#define subCategoryIdForLipshine @"53"
#define subCategoryIdForLipshimmer @"54"
#define subCategoryIdForLippencil @"55"

// SubCategoryIds for eyes....
#define subCategoryIdForEyeshadow @"9"
#define subCategoryIdForEyeliner @"45"
#define subCategoryIdForEyepowder @"50"
#define subCategoryIdForEyepencil @"51"
#define subCategoryIdForEyebrowpencil @"52"

// SubCategoryIds for face....
#define subCategoryIdForNeutralizers @"10"
#define subCategoryIdForFoundation @"11"
#define subCategoryIdForPowder @"12"
#define subCategoryIdForBlush @"46"
#define subCategoryIdForBBCreme @"48"
#define subCategoryIdForBronzer @"49"

// Look names...
#define lookTypeGlam @"Glam"
#define lookTypeSimple @"Simple"
#define lookTypeOffice @"Wear to Work"

// user messages...
#define STR_LOADING NSLocalizedStringFromTable(@"Loading",@"Locale",@"Constants")
#define STR_ERROR NSLocalizedStringFromTable(@"Error",@"Locale",@"Constants")
#define ADDED_TO_WISHLIST NSLocalizedStringFromTable(@"Added to wish list",@"Locale",@"Constants")
#define REMOVE_FROM_WISHLIST NSLocalizedStringFromTable(@"Removed from wish list",@"Locale",@"Constants")


// price arrow down image
#define PRICE_ARROW_DOWN_IMG @"downward_small_arrow_s.png"


// methods...
@interface CMConstants : NSObject
+(UIColor *) getPlumColor;

+(NSDictionary *) getLipSubCategories;
+(NSArray *) getLipSubCategoryOrderedKeys;

+(NSDictionary *) getEyeSubCategories;
+(NSArray *) getEyeSubCategoryOrderedKeys;

+(NSDictionary *) getFaceSubCategories;
+(NSArray *) getFaceSubCategoryOrderedKeys;

@end
