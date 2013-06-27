//
//  CMProductThisFilterViewController.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 10/24/12.
//
//

#import <UIKit/UIKit.h>
#import "CMFilterModel.h"

@interface CMProductFilterDetailsViewController : UIViewController<UITableViewDataSource>

- (void) myInitializeWithThisViewName: (NSString*) newThisViewName
                      withFilterModel: (CMFilterModel *) filterModel
         withDictionaryOfFilterArrays: (NSArray *) filterValues;

@end
