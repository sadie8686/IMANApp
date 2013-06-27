//
//  CMCustomTheme.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 1/7/13.
//
//

#import <Foundation/Foundation.h>

@interface CMCustomTheme : NSObject

+ (NSString *) getFontNameForBold: (BOOL) bold;
+ (void) underlineButton: (UIButton *) button;
@end
