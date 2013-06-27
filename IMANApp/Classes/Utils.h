//
//  Utils.h
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (BOOL) isValidEmailId:(NSString *) emailId;

+ (BOOL)saveToUserDefaults:(id)object forKey:(NSString *)key;
+ (BOOL)removeFromUserDefaults:(NSString *)key;
+ (id)getObjectFromUserdefaultsWithKey:(NSString *)key;

+ (void)showErrorAlertWithMessage:(NSString *)message andDelegate:(id)target;
+ (void)showAlertWithTitles:(NSString *)title message:(NSString *)message andDelegate:(id)target;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message andDelegate:(id)target;

+ (UIColor *) colorForHex:(NSString *)hexColor;

@end
