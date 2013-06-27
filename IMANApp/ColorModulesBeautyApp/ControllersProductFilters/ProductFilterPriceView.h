//
//  ProductFilterPriceView.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/22/13.
//
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"

@interface ProductFilterPriceView : UIView

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *lowerValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *upperValueLabel;
@property (nonatomic, strong) IBOutlet NMRangeSlider *slider;

- (void) configureWithMinimumValue: (NSString *) minValue
                  WithMaximumValue: (NSString *) maxValue
                    WithLowerValue: (NSString *) lowerValue
                    WithUpperValue: (NSString *) upperValue;

@end
