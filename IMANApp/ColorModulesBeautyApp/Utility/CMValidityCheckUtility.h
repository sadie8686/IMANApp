//
//  CMValidityCheckUtility.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 12/10/12.
//
//

#import <Foundation/Foundation.h>

@interface CMValidityCheckUtility : NSObject
+ (BOOL) isValidEmail: (NSString *) emailString;
+ (BOOL) isValidPassword: (NSString *) passwordString;
@end
