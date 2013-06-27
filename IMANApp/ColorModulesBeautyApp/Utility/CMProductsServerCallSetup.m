//
//  CMProductsModel.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 11/1/12.
//
//

#import "CMProductsServerCallSetup.h"
#import "CMFilterModel.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMConstants.h"
#import "Logging.h"

@interface CMProductsServerCallSetup()
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSDictionary *returnData;
@property (nonatomic, strong) NSString *ptID;
@end



@implementation CMProductsServerCallSetup
@synthesize parameters = _parameter;
@synthesize returnData = _returnData;


- (id) initWithProfileID: (NSNumber *)profileID
                 ForPtID: (NSString *) ptID
          ForSubCategory: (NSString *) subCategory
{
    self = [super init];
    self.ptID = ptID;
    if(self)
    {
        self.parameters = [[NSMutableDictionary alloc] init];
        
        [self.parameters setObject:profileID forKey:@"profile_id"];
        [self.parameters setObject:ptID forKey:@"pt_id"];
        [self.parameters setObject:subCategory forKey:@"subcat_ids"];
        // [self.parameters setObject:@"0" forKey:@"price_from"];
        // [self.parameters setObject:@"100" forKey:@"price_to"];
        // [self.parameters setObject:@"10" forKey:@"variance"];
        // [self.parameters setObject:@"3" forKey:@"max_brand_products"];
        //[self.parameters setObject:@"1" forKey:@"min_records"];
    }
    
    return self;
}


+ (NSArray *) getDefaultLook{
    return [NSArray arrayWithObjects:
            [NSNumber numberWithInt:26],
            [NSNumber numberWithInt:36], nil];
}


- (NSArray *) getDefaultFilterValues {
    // TODO: Add one more layer on top of this so that setting up default filter values can be simplified and more dynamic...
    // To set the default filter value for look so that it can be marked...

    if([self.ptID isEqualToString:@"1"])
    {
        return [NSArray arrayWithObjects: @"26", nil];
    }
    
    else if([self.ptID isEqualToString:@"2"])
    {
        return [NSArray arrayWithObjects: @"43",nil];
    }
    
    else if([self.ptID isEqualToString:@"3"])
    {
        return [NSArray arrayWithObjects: @"37", nil];
    }
    
    else
        return [NSArray arrayWithObjects: nil];
}

- (NSArray *) getDefaultSellerIDs
{
    return [NSArray arrayWithObjects: SOCKET_SELLER_ID, nil];
}



- (NSArray *) getDefaultBrandIDs {
    return [NSArray arrayWithObjects: nil];
}

- (void) setParametersForDefaultFilters
{
    // Default parameters...
    [self.parameters setObject:[self getDefaultSellerIDs] forKey:@"seller_ids"];
    [self.parameters setObject:[self getDefaultFilterValues] forKey:@"filter_values"];
    
    CMFilterModel *filterModel = [[CMFilterModel alloc] init];
    NSDictionary *filterParams = [filterModel getParametersForProductTypeID: self.ptID];
    
    // To merge the values...
    for(id key in filterParams.allKeys)
    {
        [self.parameters setObject:filterParams[key] forKey:key];
    }
}

- (NSDictionary *) getParameters
{
    // NSLog(@"self.parameters: %@", self.parameters);
    
    // return...
    return self.parameters;
}

@end
