//
//  Utils.m
//  IMAN
//
//  Created by  on 06/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (BOOL)saveToUserDefaults:(id)object forKey:(NSString *)key
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:object forKey:key];
    return [def synchronize];
}

+ (BOOL)removeFromUserDefaults:(NSString *)key
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def removeObjectForKey:key];
    return [def synchronize];
}

+ (id)getObjectFromUserdefaultsWithKey:(NSString *)key
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:key];
}

#pragma mark - Alerts
+ (void)showAlertWithTitles:(NSString *)title message:(NSString *)message andDelegate:(id)target
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:target cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message andDelegate:(id)target
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:target cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

+ (void)showErrorAlertWithMessage:(NSString *)message andDelegate:(id)target
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:message delegate:target cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

+ (BOOL)isValidEmailId:(NSString *)emailId
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:emailId];
    return isValid;
}




//Hex color converter
+ (UIColor *) colorForHex:(NSString *)hexColor
{
    hexColor = [[hexColor stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]
                 ] uppercaseString];
    
    // String should be 6 or 7 characters if it includes '#'
    if ([hexColor length] < 6)
        return [UIColor blackColor];
    
    // strip # if it appears
    if ([hexColor hasPrefix:@"#"])
        hexColor = [hexColor substringFromIndex:1];
    
    // if the value isn't 6 characters at this point return
    // the color black
    if ([hexColor length] != 6)
        return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *rString = [hexColor substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [hexColor substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [hexColor substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
    
}


@end
