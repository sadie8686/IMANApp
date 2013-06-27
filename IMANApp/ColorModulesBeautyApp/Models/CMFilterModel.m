//
//  CMFilterModel.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/16/13.
//
//

#import "CMFilterModel.h"
#import "CMConstants.h"

#import "FilterProductTypeMap.h"
#import "FilterNameMap.h"
#import "FilterValueMap.h"

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "Logging.h"

@interface CMFilterModel()
@end


@implementation CMFilterModel
@synthesize filterDictionary = _filterDictionary;

-(id) init
{
    if(self = [super init])
    {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSData *myEncodedObject = [standardUserDefaults objectForKey:FILTER_KEY];
        
        if(!myEncodedObject)
        {
            // querying for filter data...
            [self updateFilterDataFromServer];
        }
        else
        {
            self.filterDictionary = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
        }
    }
    return self;
}


- (void) createDefaultFilterStructureFromJSON: (id) JSON
{
    JSON = JSON [@"data"];
    
    FilterProductTypeMap *newCategory;
    NSMutableDictionary *filterDictionary = [[NSMutableDictionary alloc] init];
    
    // Adding lips category...
    newCategory = [[FilterProductTypeMap alloc] initWithProductTypeJSON:JSON[@"typed"][productTypeIdForLips]];
    [newCategory addMoreFiltersFromPointerDictionary:JSON[@"common"]];
    [newCategory setMinPrice:@"0"];
    [newCategory setMaxPrice:@"100"];
    [filterDictionary setObject:newCategory forKey:productTypeIdForLips];
    
    // Adding eyes category...
    newCategory = [[FilterProductTypeMap alloc] initWithProductTypeJSON:JSON[@"typed"][productTypeIdForEyes]];
    [newCategory addMoreFiltersFromPointerDictionary:JSON[@"common"]];
    [newCategory setMinPrice:@"0"];
    [newCategory setMaxPrice:@"100"];
    [filterDictionary setObject:newCategory forKey:productTypeIdForEyes];
    
    // Adding face category...
    newCategory = [[FilterProductTypeMap alloc] initWithProductTypeJSON:JSON[@"typed"][productTypeIdForFace]];
    [newCategory addMoreFiltersFromPointerDictionary:JSON[@"common"]];
    [newCategory setMinPrice:@"0"];
    [newCategory setMaxPrice:@"100"];
    [newCategory setMinVariance:@"0"];
    [newCategory setMaxVariance:@"10"];
    [filterDictionary setObject:newCategory forKey:productTypeIdForFace];
    
    self.filterDictionary = [NSDictionary dictionaryWithDictionary:filterDictionary];
    
    // synchronize the standard user defaults with current dictionary.
    [self synchronize];
    
}


- (void) synchronize
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:FILTER_KEY];
    
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.filterDictionary];
    [standardUserDefaults setObject:myEncodedObject forKey:FILTER_KEY];
    [standardUserDefaults synchronize];
}


- (void) updateFilterDataFromServer
{
    
    NSURL *url = [NSURL URLWithString: server];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            SOCKET_SELLER_ID, @"seller_id",
                            nil];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod: @"POST"
                                                            path: pathToAPICallForGettingAllFilters
                                                      parameters: params];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setHTTPShouldHandleCookies:YES];

    
    AFJSONRequestOperation
    *operation = [AFJSONRequestOperation
                  JSONRequestOperationWithRequest:request
                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                  {
                      BOOL success=[[JSON objectForKey:@"success"] boolValue];
                      if (success)
                      {
                          LogInfo(@"Filter data retrieved successfully.");
                          //NSLog(@"Filter JSON: %@", JSON);
                          [self createDefaultFilterStructureFromJSON:JSON];
                      }
                      else
                      {
                          LogInfo(@"ERROR: Filter data could not be retrieved");
                      }
                  }
                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                  {
                      LogError(@"Error while getting user data. \n Request:%@\n Response:%@\n Error:%@\n JSON:%@",
                               request, response, error, JSON);
                      
                      //if(error.code == -1009)
                  }];
    [operation start];
}


- (void) resetForProductTypeID: (NSString *) productTypeID
{
    FilterProductTypeMap *filter = (FilterProductTypeMap*) [self.filterDictionary objectForKey:productTypeID];
    [filter reset];
    [self synchronize];
}


- (NSDictionary *) getSelectedValuesWithFilterNamesForProductTypeID: (NSString *) productTypeID
{
    FilterProductTypeMap *filterProductType = (FilterProductTypeMap *) self.filterDictionary[productTypeID];
    NSMutableDictionary *selectedValuesWithFilterNames = [[NSMutableDictionary alloc] init];
    
    for(FilterNameMap *thisFilterName in filterProductType.filterNames)
    {
        NSString *selectedValues = [thisFilterName getSelectedValues];
        if(selectedValues)
        {
            [selectedValuesWithFilterNames setObject:selectedValues
                                              forKey:thisFilterName.title];
        }
        else
        {
            [selectedValuesWithFilterNames setValue:@"" forKey:thisFilterName.title];
        }
    }
    
    return selectedValuesWithFilterNames;
}



- (NSArray *) getFilterValuesForFilterNameTitle: (NSString *) targetFilterNameTitle
                               ForProductTypeID: (NSString *) productTypeID
{
    FilterProductTypeMap *filterProductType = (FilterProductTypeMap *) self.filterDictionary[productTypeID];
    for(FilterNameMap *thisFilterName in filterProductType.filterNames)
    {
        if([thisFilterName.title isEqualToString:targetFilterNameTitle])
        {
            return thisFilterName.values;
        }
    }
    
    return nil;
}


- (NSDictionary *) getParametersForProductTypeID: (NSString *) productTypeID
{
    FilterProductTypeMap *filter = (FilterProductTypeMap *) [self.filterDictionary objectForKey:productTypeID];
    NSMutableDictionary *filterParameters = [[NSMutableDictionary alloc] init];
    
    for(FilterNameMap *filterName in filter.filterNames)
    {
        for(FilterValueMap *filterValue in filterName.values)
        {
            if(filterValue.isSelected)
            {
                // if the filter key is present in the parameters then add to that list...
                if([[filterParameters allKeys] containsObject:filterValue.key])
                {
                    NSMutableArray *parameterValues = filterParameters[filterValue.key];
                    [parameterValues addObject:filterValue.filterID];
                    filterParameters[filterValue.key] = parameterValues;
                }
                // else create a list with the parameter key...
                else
                {
                    NSMutableArray *parameterValues = [[NSMutableArray alloc] initWithObjects:filterValue.filterID, nil];
                    [filterParameters setValue:parameterValues forKey:filterValue.key];
                }
            }
        }
    }
    
    // To set price parameters...
    if (filter.currentMinPrice)
    {
        [filterParameters setObject:filter.currentMinPrice forKey:@"price_from"];
        [filterParameters setObject:filter.currentMaxPrice forKey:@"price_to"];
    }
    
    else
    {
        [filterParameters setValue:[NSNumber numberWithInt:0] forKey:@"price_from"];
        [filterParameters setValue:[NSNumber numberWithInt:100] forKey:@"price_to"];
    }
    
    
    // To set variance parameter...
    if([productTypeID isEqualToString:productTypeIdForFace])
    {
        if(filter.currentVariance)
            [filterParameters setObject:filter.currentVariance forKey:@"variance"];
        
        else
            [filterParameters setValue:[NSNumber numberWithInt:10] forKey:@"variance"];
    }
    
    return filterParameters;
}


/*
 Setter for look...
 */
- (void) setLook: (NSString *) look
  ForProductType: (NSString *) productTypeID
{
    FilterProductTypeMap *filter = (FilterProductTypeMap*) [self.filterDictionary objectForKey:productTypeID];
    for (FilterNameMap *filterName in filter.filterNames)
    {
        if([filterName.title isEqualToString:@"Look"])
        {
            for(FilterValueMap *filterValue in filterName.values)
            {
                if([filterValue.title isEqualToString:look])
                {
                    filterValue.isSelected = YES;
                }
                else
                {
                    filterValue.isSelected = NO;
                }
            }
            [self synchronize];
        }
    }
}



// To get and set prices...
- (FilterProductTypeMap *) getProductTypeMapForProductTypeID: (NSString *) productTypeID
{
    return ((FilterProductTypeMap*) [self.filterDictionary objectForKey:productTypeID]);
}

- (void) setCurrentMinPrice: (float) currentMinPrice
         AndCurrentMaxPrice: (float) currentMaxPrice
           ForProductTypeID: (NSString *) productTypeID
{
    FilterProductTypeMap *filter = (FilterProductTypeMap*) [self.filterDictionary objectForKey:productTypeID];
    filter.currentMinPrice = [NSString stringWithFormat:@"%0.2f",currentMinPrice];
    filter.currentMaxPrice = [NSString stringWithFormat:@"%0.2f", currentMaxPrice];
    [self synchronize];
}


// To set the variance..
- (void) setCurrentVariance: (float) currentVariance
{
    FilterProductTypeMap *filter = (FilterProductTypeMap*) [self.filterDictionary objectForKey:productTypeIdForFace];
    filter.currentVariance = [NSString stringWithFormat:@"%0.0f", currentVariance];
    [self synchronize];
}


- (void) reset
{
    for (id key in self.filterDictionary)
    {
        FilterProductTypeMap *productTypeMap = self.filterDictionary[key];
        [productTypeMap reset];
    }
    [self synchronize];
}
@end
