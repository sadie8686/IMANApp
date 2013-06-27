//
//  CMProductsModel.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 11/1/12.
//
//

#import <Foundation/Foundation.h>

@interface CMProductsServerCallSetup : NSObject

- (id) initWithProfileID: (NSNumber *)profileID
                 ForPtID: (NSString *) ptID
          ForSubCategory: (NSString *) subCategory;

- (void) setParametersForDefaultFilters;
- (NSDictionary *) getParameters;
+ (NSArray *) getDefaultLook;
@end
