//
//  UserProfileMap.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/27/13.
//
//

#import "CMUserProfileMap.h"
#import "CMProductMap.h"
#import "Logging.h"

@implementation CMUserProfileMap

-(void) updateWithJSON: (id) JSON
{
    self.userID = [NSNumber numberWithInt:[[JSON objectForKey:@"user_id"] integerValue]];
    self.profileID = [NSNumber numberWithInt:[[JSON objectForKey:@"profile_id"] integerValue]];
    
    self.imageURL = [NSURL URLWithString:[[JSON objectForKey:@"image_locations"] objectForKey:@"corrected_abs"]];
    self.originalImageURL = [NSURL URLWithString:[[JSON objectForKey:@"image_locations"] objectForKey:@"original_abs"]];

    
    NSDictionary *colorRef = [[JSON objectForKey:@"references"] objectForKey:@"hair"];
    self.hairColor = [self createUIColorFrom:colorRef];
    self.hairChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.hairTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.hairValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.hairColorName = [colorRef objectForKey:@"color_name"];
    
    colorRef = [[JSON objectForKey:@"references"] objectForKey:@"eyes"];
    self.eyesColor = [self createUIColorFrom:colorRef];
    self.eyesChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.eyesTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.eyesValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.eyesColorName = [colorRef objectForKey:@"color_name"];

    
    colorRef = [[JSON objectForKey:@"references"] objectForKey:@"lips"];
    self.lipsColor = [self createUIColorFrom:colorRef];
    self.lipsChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.lipsTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.lipsValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.lipsColorName = [colorRef objectForKey:@"color_name"];

    
    colorRef = [[JSON objectForKey:@"references"] objectForKey:@"skin"];
    self.skinColor = [self createUIColorFrom:colorRef];
    self.skinChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.skinTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.skinValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.skinColorName = [colorRef objectForKey:@"color_name"];
    
    LogInfo(@"UserID: %@", [self.userID stringValue]);
    [self modifyValueForIMAN];
}



- (void) updateUserColorsWithJSON: (id) JSON
{
    self.profileID = [NSNumber numberWithInt:[[JSON objectForKey:@"id"] integerValue]];
    
    NSDictionary *colorRef = [[JSON objectForKey:@"references"] objectForKey:@"hair"];
    self.hairColor = [self createUIColorFrom:colorRef];
    self.hairChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.hairTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.hairValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.hairColorName = [colorRef objectForKey:@"color_name"];

    
    colorRef = [[JSON objectForKey:@"references"] objectForKey:@"eyes"];
    self.eyesColor = [self createUIColorFrom:colorRef];
    self.eyesChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.eyesTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.eyesValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.eyesColorName = [colorRef objectForKey:@"color_name"];

    colorRef = [[JSON objectForKey:@"references"] objectForKey:@"lips"];
    self.lipsColor = [self createUIColorFrom:colorRef];
    self.lipsChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.lipsTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.lipsValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.lipsColorName = [colorRef objectForKey:@"color_name"];

    
    colorRef = [[JSON objectForKey:@"references"] objectForKey:@"skin"];
    self.skinColor = [self createUIColorFrom:colorRef];
    self.skinChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.skinTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.skinValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.skinColorName = [colorRef objectForKey:@"color_name"];

    [self modifyValueForIMAN];
}


- (void) updateWithJSONForUploadsImport: (id) JSON
{
    self.imageURL = [NSURL URLWithString:[[[JSON objectForKey:@"image"]
                                           objectForKey:@"image_locations"]
                                          objectForKey:@"corrected_abs"]];

    self.originalImageURL = [NSURL URLWithString:[[[JSON objectForKey:@"image"]
                                           objectForKey:@"image_locations"]
                                          objectForKey:@"original_abs"]];
    
    JSON = [JSON objectForKey:@"profile"];
    self.profileID = [NSNumber numberWithInt:[[JSON objectForKey:@"id"] integerValue]];
    
    NSDictionary *colorRef = [[JSON objectForKey:@"references"] objectForKey:@"hair"];
    self.hairColor = [self createUIColorFrom:colorRef];
    self.hairChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.hairTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.hairValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.hairColorName = [colorRef objectForKey:@"color_name"];

    colorRef = [[JSON objectForKey:@"references"] objectForKey:@"eyes"];
    self.eyesColor = [self createUIColorFrom:colorRef];
    self.eyesChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.eyesTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.eyesValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.eyesColorName = [colorRef objectForKey:@"color_name"];

    colorRef = [[JSON objectForKey:@"references"] objectForKey:@"lips"];
    self.lipsColor = [self createUIColorFrom:colorRef];
    self.lipsChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.lipsTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.lipsValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.lipsColorName = [colorRef objectForKey:@"color_name"];

    colorRef = [[JSON objectForKey:@"references"] objectForKey:@"skin"];
    self.skinColor = [self createUIColorFrom:colorRef];
    self.skinChroma = [[colorRef objectForKey:@"category"] objectForKey:@"chroma"];
    self.skinTemp = [[colorRef objectForKey:@"category"] objectForKey:@"temp"];
    self.skinValue = [[colorRef objectForKey:@"category"] objectForKey:@"value"];
    self.skinColorName = [colorRef objectForKey:@"color_name"];

    [self modifyValueForIMAN];
}

- (UIColor *) createUIColorFrom: (id) colorDict
{
    float color_r=[[colorDict objectForKey:@"clr_r"] floatValue];
    float color_g=[[colorDict objectForKey:@"clr_g"] floatValue];
    float color_b=[[colorDict objectForKey:@"clr_b"] floatValue];
    
    return [UIColor
            colorWithRed:(float)color_r/255.0f
            green:(float)color_g/255.0f
            blue:(float)color_b/255.0f
            alpha:1.0f];
}


- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties...
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.profileID forKey:@"profileID"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.originalImageURL forKey:@"originalImageURL"];

    
    [encoder encodeObject:self.hairColor forKey:@"hairColor"];
    [encoder encodeObject:self.hairChroma forKey:@"hairChroma"];
    [encoder encodeObject:self.hairTemp forKey:@"hairTemp"];
    [encoder encodeObject:self.hairValue forKey:@"hairValue"];
    [encoder encodeObject:self.hairColorName forKey:@"hairColorName"];

    
    [encoder encodeObject:self.eyesColor forKey:@"eyesColor"];
    [encoder encodeObject:self.eyesChroma forKey:@"eyesChroma"];
    [encoder encodeObject:self.eyesTemp forKey:@"eyesTemp"];
    [encoder encodeObject:self.eyesValue forKey:@"eyesValue"];
    [encoder encodeObject:self.eyesColorName forKey:@"eyesColorName"];

    [encoder encodeObject:self.lipsColor forKey:@"lipsColor"];
    [encoder encodeObject:self.lipsChroma forKey:@"lipsChroma"];
    [encoder encodeObject:self.lipsTemp forKey:@"lipsTemp"];
    [encoder encodeObject:self.lipsValue forKey:@"lipsValue"];
    [encoder encodeObject:self.lipsColorName forKey:@"lipsColorName"];

    
    [encoder encodeObject:self.skinColor forKey:@"skinColor"];
    [encoder encodeObject:self.skinChroma forKey:@"skinChroma"];
    [encoder encodeObject:self.skinTemp forKey:@"skinTemp"];
    [encoder encodeObject:self.skinValue forKey:@"skinValue"];
    [encoder encodeObject:self.skinColorName forKey:@"skinColorName"];

    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init]))
    {
        // Decode properties
        self.userID = [decoder decodeObjectForKey:@"userID"];
        self.profileID = [decoder decodeObjectForKey:@"profileID"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.originalImageURL = [decoder decodeObjectForKey:@"originalImageURL"];

        self.hairColor = [decoder decodeObjectForKey:@"hairColor"];
        self.hairChroma = [decoder decodeObjectForKey:@"hairChroma"];
        self.hairTemp = [decoder decodeObjectForKey:@"hairTemp"];
        self.hairValue = [decoder decodeObjectForKey:@"hairValue"];
        self.hairColorName = [decoder decodeObjectForKey:@"hairColorName"];

        
        self.eyesColor = [decoder decodeObjectForKey:@"eyesColor"];
        self.eyesChroma = [decoder decodeObjectForKey:@"eyesChroma"];
        self.eyesTemp = [decoder decodeObjectForKey:@"eyesTemp"];
        self.eyesValue = [decoder decodeObjectForKey:@"eyesValue"];
        self.eyesColorName = [decoder decodeObjectForKey:@"eyesColorName"];

        self.lipsColor = [decoder decodeObjectForKey:@"lipsColor"];
        self.lipsChroma = [decoder decodeObjectForKey:@"lipsChroma"];
        self.lipsTemp = [decoder decodeObjectForKey:@"lipsTemp"];
        self.lipsValue = [decoder decodeObjectForKey:@"lipsValue"];
        self.lipsColorName = [decoder decodeObjectForKey:@"lipsColorName"];

        self.skinColor = [decoder decodeObjectForKey:@"skinColor"];
        self.skinChroma = [decoder decodeObjectForKey:@"skinChroma"];
        self.skinTemp = [decoder decodeObjectForKey:@"skinTemp"];
        self.skinValue = [decoder decodeObjectForKey:@"skinValue"];
        self.skinColorName = [decoder decodeObjectForKey:@"skinColorName"];

        [self modifyValueForIMAN];
    }
    return self;
}



-(void) modifyValueForIMAN
{
    self.skinValue = [self imanValueMapper:self.skinValue];
//    self.lipsValue = [self imanValueMapper:self.lipsValue];
//    self.hairValue = [self imanValueMapper:self.hairValue];
//    self.eyesValue = [self imanValueMapper:self.eyesValue];
}

-(NSString *) imanValueMapper: (NSString *) value
{
    if([value isEqualToString:@"dark"] || [value isEqualToString:@"deep"])
    {
        return @"earth";
    }
        
    if ([value isEqualToString:@"medium"])
    {
        return @"clay";
    }
    
    if ([value isEqualToString:@"light"])
    {
        return @"sand";
    }
    
    return value;
}

@end
