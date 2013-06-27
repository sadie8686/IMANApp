//
//  FilterCategory.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/17/13.
//
//

#import "FilterProductTypeMap.h"
#import "FilterNameMap.h"
#import "FilterValueMap.h"

@implementation FilterProductTypeMap

- (id) initWithProductTypeJSON: (NSDictionary *) productTypeJSON
{
    if(self = [self init])
    {
        _productTypeID = productTypeJSON[@"id"];
        _title = productTypeJSON[@"title"];
        _key = productTypeJSON[@"key"];
        
        [self addMoreFiltersFromPointerDictionary:productTypeJSON[@"filters"]];
    }
    
    return self;
}


- (void) setMinPrice:(NSString *)minPrice
{
    _minPrice = minPrice;
    _currentMinPrice = [NSString stringWithFormat:@"%@", minPrice];
}

-(void) setMaxPrice:(NSString *)maxPrice
{
    _maxPrice = maxPrice;
    _currentMaxPrice = [NSString stringWithFormat:@"%@", maxPrice];
}

-(void) setMaxVariance:(NSString *)maxVariance
{
    _maxVariance = maxVariance;
    _currentVariance = [NSString stringWithFormat:@"%@", maxVariance];
}

- (void) addMoreFiltersFromPointerDictionary: (NSDictionary *) pointerDictionary
{
     NSMutableArray *temporaryFilterNamesArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in pointerDictionary)
    {
        if(![key isEqualToString:@"color_families"] &&
           ![key isEqualToString:@"variance"] &&
           ![key isEqualToString:@"price"])
        {
            FilterNameMap *thisFilter = [[FilterNameMap alloc]
                                         initForValueWithJSONDictionary:pointerDictionary[key]];
            
            [temporaryFilterNamesArray addObject:thisFilter];
        }
    }
    
    if(self.filterNames)
    {
        [temporaryFilterNamesArray addObjectsFromArray:self.filterNames];
    }
    
    self.filterNames = [NSArray arrayWithArray:temporaryFilterNamesArray];
}


/*
 Encoder and Decoder...
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties...
    [encoder encodeObject:self.productTypeID forKey:@"productTypeID"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.filterNames forKey:@"filterNames"];
    [encoder encodeObject:self.minPrice forKey:@"minPrice"];
    [encoder encodeObject:self.maxPrice forKey:@"maxPrice"];
    [encoder encodeObject:self.currentMinPrice forKey:@"currentMinPrice"];
    [encoder encodeObject:self.currentMaxPrice forKey:@"currentMaxPrice"];
    
    [encoder encodeObject:self.minVariance forKey:@"minVariance"];
    [encoder encodeObject:self.maxVariance forKey:@"maxVariance"];
    [encoder encodeObject:self.currentVariance forKey:@"currentVariance"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init]))
    {
        // Decode properties
        self.productTypeID = [decoder decodeObjectForKey:@"productTypeID"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.filterNames = [decoder decodeObjectForKey:@"filterNames"];
        self.minPrice = [decoder decodeObjectForKey:@"minPrice"];
        self.maxPrice = [decoder decodeObjectForKey:@"maxPrice"];
        self.currentMinPrice = [decoder decodeObjectForKey:@"currentMinPrice"];
        self.currentMaxPrice = [decoder decodeObjectForKey:@"currentMaxPrice"];
        self.minVariance = [decoder decodeObjectForKey:@"minVariance"];
        self.maxVariance = [decoder decodeObjectForKey:@"maxVariance"];
        self.currentVariance = [decoder decodeObjectForKey:@"currentVariance"];
    }
    return self;
}


- (void) reset
{
    _currentMinPrice = [NSString stringWithFormat:@"%@", _minPrice];
    _currentMaxPrice = [NSString stringWithFormat:@"%@", _maxPrice];
    
    for (FilterNameMap *thisFilter in self.filterNames)
    {
        [thisFilter reset];
    }
}
@end
