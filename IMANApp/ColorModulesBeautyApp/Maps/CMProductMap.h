//
//  CMProductMap.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/27/13.
//
//

#import <Foundation/Foundation.h>

@interface CMProductMap : NSObject
@property NSNumber *productID;
@property NSNumber *externalID;
@property NSNumber *typeID;
@property NSNumber *categoryID;

@property NSString *title;
@property NSString *colorName;
@property UIColor *color;
@property NSString *brandName;
@property NSString *sellerName;
@property NSString *description;
@property float price;
@property NSURL *url;
@property NSURL *imageURL;
@property NSString *matchMessage;
@property BOOL isWishlist;

- (id) initWithProduct: (id) JSON;
@end
