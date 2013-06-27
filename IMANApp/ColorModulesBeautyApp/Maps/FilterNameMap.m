//
//  FilterNameMap.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/16/13.
//
//

#import "FilterNameMap.h"
#import "FilterValueMap.h"

@implementation FilterNameMap


- (id) initForValueWithJSONDictionary: (NSDictionary *) thisFilter
{
    if (self = [self init])
    {
        _title = thisFilter [@"title"];
        NSString *key = thisFilter [@"key"];
        NSMutableArray *temporaryValues = [[NSMutableArray alloc] init];
        
        for(id thisValue in thisFilter[@"filters"])
        {
            FilterValueMap *value = [[FilterValueMap alloc] init];
            value.filterID = thisValue[@"id"];
            value.title = thisValue[@"title"];
            value.key = key;
            value.isSelected = NO;
            
            [temporaryValues addObject:value];
        }
        // To sort the values...
        [temporaryValues sortUsingComparator:^NSComparisonResult(FilterValueMap *object1, FilterValueMap *object2)
                   {
                       NSString *name1 = object1.title;
                       NSString *name2 = object2.title;
                       return [name1 localizedCaseInsensitiveCompare:name2];
                   }];
        
        _values = temporaryValues;
    }
    
    return self;
}

- (NSString *) getSelectedValues
{
    NSString *selectedValues = nil;
    
    for(FilterValueMap *thisValue in self.values)
    {
        if(thisValue.isSelected && selectedValues == nil)
        {
            selectedValues = [NSString stringWithFormat:@"%@", thisValue.title];
        }
        else if(thisValue.isSelected && selectedValues != nil)
        {
            selectedValues = [NSString stringWithFormat:@"%@, %@", selectedValues, thisValue.title];
        }
    }
    
    return selectedValues;
}



/*
 Encoder and Decoder...
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties...
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.values forKey:@"values"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init]))
    {
        // Decode properties
        self.title = [decoder decodeObjectForKey:@"title"];
        self.values = [decoder decodeObjectForKey:@"values"];
    }
    return self;
}


- (void) reset
{
    for (FilterValueMap *thisValue in self.values)
    {
        [thisValue reset];
    }
}



@end
