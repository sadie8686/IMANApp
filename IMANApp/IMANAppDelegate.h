//
//  IMANAppDelegate.h
//  IMANApp
//
//  Created by  on 19/02/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TestFlight.h"

@interface IMANAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate>
{
    NSString *networkValue;
  
    NSInteger homeMenuIndex;
    UIImageView *splashView;
        
    
    NSMutableDictionary *productSubCategaoryArray;
}
extern NSString *const FBSessionStateChangedNotification;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSArray *gTestFlightFeedback;
@property (nonatomic, strong) UIViewController *viewController;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (nonatomic, copy) NSString *networkValue;
@property (nonatomic) NSInteger homeMenuIndex;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableDictionary *productSubCategaoryArray;

- (void) reachabilityChanged: (NSNotification* )note;
- (void) callPostMethod:(NSDictionary *)params connectionTag:(int)tag urlString:(NSString *)urlStr;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
@end


// Facebook...


