//
//  Constants.h
//  
//
//  Created by My Mac on 22/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#define IS_IPHONE ( [[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"] )
#define IS_IPHONE ( [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] )
#define IS_IPOD   ( [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"] )
#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen] bounds].size.height >= 568.0f
#define IS_IPHONE_5 ( IS_IPHONE && IS_HEIGHT_GTE_568 )

#define wifiValue @"wifi"
#define wwanValue @"wwan"
#define noConnectionValue @"not"

#define kNavImg @"final_header.png"

#define kAwesomeFontSize 20


#define tableColor @"hexellence.png"

//#define mainUrl @"http://192.168.1.35/iman/api/"
#define mainUrl @"http://iman.aririseup.com/api/"

#define kBackgroundImage @"low_contrast_linen.png"

#define favNotification @"favNotificationFired"
#define localSaveNotification @"localSaveNotification"




#define productsLimit @"10"

//Map Constants
#define ZOOM_LEVEL 14
#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360


#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "NSString+FontAwesome.h"
#import "FAImageView.h"

#import "Utils.h"
#import "Keys.h"

@interface Constants : NSObject

+ (UIButton *) customRightHomeButton;
+ (UIButton *) customRightButton;
+ (UIButton *) customBackButton;
+ (UIButton *) customRefreshButton;
+ (UILabel *) customTitleLabel:(NSString *)title;

+ (void) alignLabelWithTop:(UILabel *)label;

+ (UIButton *) customFavButton;
+ (UIButton *) customSearchButton;
+ (UIButton *) customVideoButton;
+ (UIButton *) customShareButton;

+ (UILabel *)iconLabelSettings;

@end
