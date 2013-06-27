//
//  FilterValueMap.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/16/13.
//
//

#import "FilterValueMap.h"

@implementation FilterValueMap


/*
 Encoder and Decoder...
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties...
    [encoder encodeObject:self.filterID forKey:@"filterID"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isSelected] forKey:@"isSelected"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init]))
    {
        // Decode properties
        self.filterID = [decoder decodeObjectForKey:@"filterID"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.isSelected = [[decoder decodeObjectForKey:@"isSelected"] boolValue];
    }
    return self;
}

- (void) reset {
    self.isSelected = NO;
}

@end
