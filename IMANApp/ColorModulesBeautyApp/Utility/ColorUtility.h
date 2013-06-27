//
//  ColorUtility.h
//  testASIHTTP
//
//  Created by Nicky Liu on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorUtility: NSObject
+ (UIColor *) colorWithHexString:(NSString *)stringToConvert;
+ (NSString *)hexadecimalValueOfAUIColor: (UIColor *) aColor;
+ (NSString *) rgbValueOFUIColor: (UIColor *) aColor;
@end
