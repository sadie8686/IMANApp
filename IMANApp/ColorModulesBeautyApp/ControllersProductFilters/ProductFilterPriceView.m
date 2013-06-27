//
//  ProductFilterPriceView.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 4/22/13.
//
//

#import "ProductFilterPriceView.h"
#import "NMRangeSlider.h"


@implementation ProductFilterPriceView

- (void) configureWithMinimumValue: (NSString *) minValue
                  WithMaximumValue: (NSString *) maxValue
                    WithLowerValue: (NSString *) lowerValue
                    WithUpperValue: (NSString *) upperValue
{
    // FIX FIX FIX... change the lower to use lower...
    // Setting slider values...
    //    self.slider.minimumValue = [minValue intValue];
    //    self.slider.maximumValue = [maxValue intValue];
    self.slider.lowerValue = [minValue intValue];
    self.slider.upperValue = [maxValue intValue];
    
    // setting control event to monitor change in value...
    [self.slider addTarget:self action:@selector(sliderChangedValue:) forControlEvents:UIControlEventValueChanged];
}



- (void) sliderChangedValue: (id) sender
{
    self.lowerValueLabel.text = [NSString stringWithFormat:@"$%0.2f", (self.slider.lowerValue * 100)];
    self.upperValueLabel.text = [NSString stringWithFormat:@"$%0.2f", (self.slider.upperValue * 100)];
    
    [self.lowerValueLabel setCenter:CGPointMake((self.slider.lowerCenter.x + 15), self.lowerValueLabel.center.y)];
    [self.upperValueLabel setCenter:CGPointMake((self.slider.upperCenter.x + 15), self.upperValueLabel.center.y)];
}





/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
