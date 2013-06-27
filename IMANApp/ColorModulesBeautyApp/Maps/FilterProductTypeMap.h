//
//  FilterCategory.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/17/13.
//
//

#import <Foundation/Foundation.h>

@interface FilterProductTypeMap : NSObject

@property (nonatomic) NSString *productTypeID;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *key;
@property (nonatomic) NSArray *filterNames;

@property (nonatomic) NSString *maxPrice;
@property (nonatomic) NSString *minPrice;
@property (nonatomic) NSString *currentMaxPrice;
@property (nonatomic) NSString *currentMinPrice;

@property (nonatomic) NSString *minVariance;
@property (nonatomic) NSString *maxVariance;
@property (nonatomic) NSString *currentVariance;

- (id) initWithProductTypeJSON: (NSDictionary *) productTypeJSON;
- (void) addMoreFiltersFromPointerDictionary: (NSDictionary *) pointerDictionary;
- (void) reset;
@end
