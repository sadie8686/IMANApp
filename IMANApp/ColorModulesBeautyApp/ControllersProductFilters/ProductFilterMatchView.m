//
//  ProductFilterMatchView.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/22/13.
//
//

#import "ProductFilterMatchView.h"

@implementation ProductFilterMatchView

-(void) configureWithMinimumVariance: (NSString *) minValue
                 WithMaximumVariance: (NSString *) maxValue
                    WithCurrentValue: (NSString *) currentValue
{
    self.slider.minimumValue = [minValue floatValue];
    self.slider.maximumValue = [maxValue floatValue];
    self.slider.value = [currentValue floatValue];
    self.currentSelectionLabel.text = [NSString stringWithFormat:@"%@%%", currentValue];
    
    // setting control event to monitor change in value...
    [self.slider addTarget:self action:@selector(sliderChangedValue:) forControlEvents:UIControlEventValueChanged];
}



- (void) sliderChangedValue: (id) sender
{
    self.currentSelectionLabel.text = [NSString stringWithFormat:@"%0.0f%%", self.slider.value];
    
    
   // [self.currentSelectionLabel setCenter:CGPointMake((self.slider.center.x + 15), self.lowerValueLabel.center.y)];
}



@end
