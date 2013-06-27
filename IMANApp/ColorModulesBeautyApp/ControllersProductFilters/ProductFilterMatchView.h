//
//  ProductFilterMatchView.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/22/13.
//
//

#import <UIKit/UIKit.h>

@interface ProductFilterMatchView : UIView

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (nonatomic, strong) IBOutlet UILabel *currentSelectionLabel;

-(void) configureWithMinimumVariance: (NSString *) minValue
                 WithMaximumVariance: (NSString *) maxValue
                    WithCurrentValue: (NSString *) currentValue;
@end
