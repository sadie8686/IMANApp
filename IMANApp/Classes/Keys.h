//
//  Keys.h

#import <Foundation/Foundation.h>

typedef enum {
    queryNone                       = 0,
    queryRegistration               = 1,
    queryLogin                      = 2,
    queryLogout                     = 3,
    queryUpdateProfile              = 4,
    queryChangePassword             = 5,
    queryForgotPassword             = 6,
} queryType;

//Product list notifications
extern NSString * const AllProductsNotification;
extern NSString * const AllProductsErrorNotification;
extern NSString * const AllProductsFailedNotification;

//Product details notifications
extern NSString * const ProductDetailsSuccessNotification;
extern NSString * const ProductDetailsErrorNotification;
extern NSString * const ProductDetailsFailedNotification;

//Product Sub details notifications
extern NSString * const ProductSubDetailsSuccessNotification;
extern NSString * const ProductSubDetailsErrorNotification;
extern NSString * const ProductSubDetailsFailedNotification;

//Quiz Products Notifications
extern NSString * const QuizProductsSuccessNotification;
extern NSString * const QuizProductsErrorNotification;
extern NSString * const QuizProductsFailedNotification;
/*
//Quiz Product Details Notifications ///////////////////////////////////////
extern NSString * const QuizProductDetailsSuccessNotification;
extern NSString * const QuizProductDetailsErrorNotification;
extern NSString * const QuizProductDetailsFailedNotification;
*/
//Find Shade products Notifications
extern NSString * const FindShadeProductsSuccessNotification;
extern NSString * const FindShadeProductsErrorNotification;
extern NSString * const FindShadeProductsFailedNotification;

//Registration Notifications
extern NSString * const RegistrationSuccessNotification;
extern NSString * const RegistrationErrorNotification;
extern NSString * const RegistrationFailedNotification;

//Login Notifications
extern NSString * const LoginSuccessNotification;
extern NSString * const LoginErrorNotification;
extern NSString * const LoginFailedNotification;

//Logout Notifications
extern NSString * const LogoutSuccessNotification;
extern NSString * const LogoutErrorNotification;
extern NSString * const LogoutFailedNotification;

//Profile update Notifications
extern NSString * const ProfileUpdateSuccessNotification;
extern NSString * const ProfileUpdateErrorNotification;
extern NSString * const ProfileUpdateFailedNotification;

//Change password Notifications
extern NSString * const ChangePasswordSuccessNotification;
extern NSString * const ChangePasswordErrorNotification;
extern NSString * const ChangePasswordFailedNotification;

//Forgot password Notifications
extern NSString * const ForgotPasswordSuccessNotification;
extern NSString * const ForgotPasswordErrorNotification;
extern NSString * const ForgotPasswordFailedNotification;

//Account keys
extern NSString * const UserProfileDictionary;
extern NSString * const UserID;
extern NSString * const UserLoginName;
extern NSString * const UserPassword;
extern NSString * const UserEmail;
extern NSString * const UserDeviceID;

//Device id
extern NSString * const kDeviceID;

//Product Fav Notifications
extern NSString * const ProductFavSuccessNotification;
extern NSString * const ProductFavErrorNotification;
extern NSString * const ProductFavFailedNotification;

//Product Un-Fav Notifications
extern NSString * const ProductUnFavSuccessNotification;
extern NSString * const ProductUnFavErrorNotification;
extern NSString * const ProductUnFavFailedNotification;

//Skincare Product Fav Notifications
extern NSString * const SkincareProductFavSuccessNotification;
extern NSString * const SkincareProductFavErrorNotification;
extern NSString * const SkincareProductFavFailedNotification;

//Skincare Product Un-Fav Notifications
extern NSString * const SkincareProductUnFavSuccessNotification;
extern NSString * const SkincareProductUnFavErrorNotification;
extern NSString * const SkincareProductUnFavFailedNotification;

//Call store locator view
extern NSString * const CallStoreLocatorNotification;

//Store locator Notifications
extern NSString * const StoreLocatorSuccessNotification;
extern NSString * const StoreLocatorErrorNotification;
extern NSString * const StoreLocatorFailedNotification;

//Try It On Notifications
extern NSString * const TryItOnSuccessNotification;
extern NSString * const TryItOnErrorNotification;
extern NSString * const TryItOnFailedNotification;

//User favorites Notifications
extern NSString * const UserFavoritesSuccessNotification;
extern NSString * const UserFavoritesErrorNotification;
extern NSString * const UserFavoritesFailedNotification;

//What's Hot Notifications
extern NSString * const whatsHotSuccessNotification;
extern NSString * const whatsHotErrorNotification;
extern NSString * const whatsHotFailedNotification;

//What's Hot details Notifications
extern NSString * const whatsHotDetailsSuccessNotification;
extern NSString * const whatsHotDetailsErrorNotification;
extern NSString * const whatsHotDetailsFailedNotification;

//homepage banner details Notifications
extern NSString * const homepagebannerDetailsSuccessNotification;
extern NSString * const homepagebannerDetailsErrorNotification;
extern NSString * const homepagebannerDetailsFailedNotification;
