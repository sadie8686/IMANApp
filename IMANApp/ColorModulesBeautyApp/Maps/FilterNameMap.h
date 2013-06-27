//
//  FilterNameMap.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/16/13.
//
//

#import <Foundation/Foundation.h>

@interface FilterNameMap : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSArray *values;


- (id) initForValueWithJSONDictionary: (NSDictionary *) thisFilter;
- (NSString *) getSelectedValues;
- (void) reset;
@end
