//
//  FilterValueMap.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/16/13.
//
//

#import <Foundation/Foundation.h>

@interface FilterValueMap : NSObject
@property (nonatomic) NSNumber *filterID;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *key;
@property (nonatomic) BOOL isSelected;


- (void) reset;
@end
