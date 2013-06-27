//
//  CMProductModel.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 3/11/13.
//
//

#import "CMProductModel.h"
#import "CMProductMap.h"

@implementation CMProductModel

+ (NSArray *) getProductsListFromJSON: (id) JSON
{
    NSMutableArray *productList = [NSMutableArray
                                   arrayWithCapacity:[[[JSON objectForKey:@"data"]
                                                       objectForKey:@"products"] count]];
    for(id product in [[JSON objectForKey:@"data"] objectForKey:@"products"])
    {
        [productList addObject:[[CMProductMap alloc] initWithProduct:product]];
    }
    
    [productList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIColor *color1 = [(CMProductMap *)obj1 color];
        UIColor *color2 = [(CMProductMap *)obj2 color];
        
        if(color1 > color2)
            return NSOrderedAscending;
        else if (color1 < color2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    return productList;
}

+ (NSArray *) getOtherProductsListFromJSON: (id) JSON
{
    NSMutableArray *productList = [NSMutableArray
                                   arrayWithCapacity:[[[JSON objectForKey:@"data"]
                                                       objectForKey:@"other_products"] count]];
    for(id product in [[JSON objectForKey:@"data"] objectForKey:@"other_products"])
    {
        [productList addObject:[[CMProductMap alloc] initWithProduct:product]];
    }
    
    return productList;
}


@end
