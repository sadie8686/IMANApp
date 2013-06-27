//
//  CMProductModel.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 3/11/13.
//
//

#import <Foundation/Foundation.h>

@interface CMProductModel : NSObject
+ (NSArray *) getProductsListFromJSON: (id) JSON;
+ (NSArray *) getOtherProductsListFromJSON: (id) JSON;
@end
