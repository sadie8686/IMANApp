//
//  ColorUtility.m
//  testASIHTTP
//
//  Created by Nicky Liu on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorUtility.h" 

@implementation ColorUtility

+ (UIColor *) colorWithHexString:(NSString *)stringToConvert{
    NSString *cString=[[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    //String should be 6 or 8 characters
    
    if ([cString length]<6) {
        return [UIColor blackColor];
    }
    
    //strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) {
        cString=[cString substringFromIndex:2];
    }
    
    if ([cString length]!=6) {
        return [UIColor blackColor];
    }
    
    NSRange range;
    range.location=0;
    range.length=2;
    NSString *rString=[cString substringWithRange:range];
    range.location=2;
    NSString *gString=[cString substringWithRange:range];
    range.location=4;
    NSString *bString=[cString substringWithRange:range];
    
    //Scan values
    unsigned int r,g,b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r/255.0f) green:((float) g/255.0f) blue:((float) b/255.0f) alpha:1.0f];
}

+ (NSString *)hexadecimalValueOfAUIColor: (UIColor *) aColor
{
    float redFloatValue = 0, greenFloatValue = 0, blueFloatValue = 0, colorA = 0;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;

    if(aColor)
    {
        // Get the red, green, and blue components of the color
        [aColor  getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:&colorA];
        
        
        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue=redFloatValue*255.99999f;
        greenIntValue=greenFloatValue*255.99999f;
        blueIntValue=blueFloatValue*255.99999f;
        
        // Convert the numbers to hex strings
        redHexValue=[NSString stringWithFormat:@"%02X", redIntValue]; 
        greenHexValue=[NSString stringWithFormat:@"%02X", greenIntValue];
        blueHexValue=[NSString stringWithFormat:@"%02X", blueIntValue];
   
        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return [NSString stringWithFormat:@"%@%@%@", redHexValue, greenHexValue, blueHexValue];
        
    }
    return nil;
}

+ (NSString *) rgbValueOFUIColor: (UIColor *) aColor
{
    float redFloatValue = 0, greenFloatValue = 0, blueFloatValue = 0, colorA = 0;
    int redIntValue, greenIntValue, blueIntValue;
    
    if(aColor)
    {
        // Get the red, green, and blue components of the color
        [aColor  getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:&colorA];
        
        
        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue = redFloatValue*255.99999f;
        greenIntValue = greenFloatValue*255.99999f;
        blueIntValue = blueFloatValue*255.99999f;
        
                
        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return [NSString stringWithFormat:@"Red: %d Green: %d Blue: %d", redIntValue, greenIntValue, blueIntValue];
        
    }
    return nil;
}


@end
