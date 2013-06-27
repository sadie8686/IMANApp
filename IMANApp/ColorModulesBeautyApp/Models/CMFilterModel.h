//
//  CMFilterModel.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/16/13.
//
//

#import <Foundation/Foundation.h>
#import "FilterProductTypeMap.h"

@interface CMFilterModel : NSObject

@property (nonatomic) NSDictionary *filterDictionary;

- (id) init;
- (void) createDefaultFilterStructureFromJSON: (id) JSON;


- (NSDictionary *) getParametersForProductTypeID: (NSString *) productTypeID;

- (NSDictionary *) getSelectedValuesWithFilterNamesForProductTypeID: (NSString *) productTypeID;

- (NSArray *) getFilterValuesForFilterNameTitle: (NSString *) targetFilterNameTitle
                          ForProductTypeID: (NSString *) productTypeID;


// To get and set prices...
- (FilterProductTypeMap *) getProductTypeMapForProductTypeID: (NSString *) productTypeID;
- (void) setCurrentMinPrice: (float) currentMinPrice
         AndCurrentMaxPrice: (float) currentMaxPrice
    ForProductTypeID: (NSString *) productTypeID;

- (void) setCurrentVariance: (float) currentVariance;

// setter for look...
- (void) setLook: (NSString *) look
  ForProductType: (NSString *) productTypeID;




- (void) synchronize;

- (void) reset;
@end
