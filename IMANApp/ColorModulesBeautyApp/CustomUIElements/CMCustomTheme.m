//
//  CMCustomTheme.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 1/7/13.
//
//

#import "CMCustomTheme.h"

@implementation CMCustomTheme

/*+ (UIView *) getScreenTitleView: (NSString *) title
 {
 UILabel *labelScreenTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
 [labelScreenTitle setFont:[UIFont systemFontOfSize:18]];
 //[labelScreenTitle setText:self.navigationItem.title];
 [labelScreenTitle setText:title];
 [labelScreenTitle sizeToFit];
 [labelScreenTitle setTextAlignment:NSTextAlignmentCenter];
 [labelScreenTitle setBackgroundColor:[UIColor clearColor]];
 [labelScreenTitle setTextColor:[UIColor whiteColor]];
 //[[self navigationItem] setTitleView:labelScreenTitle];
 return labelScreenTitle;
 }*/



+ (NSString *) getFontNameForBold: (BOOL) bold
{
    if(bold)
        return @"STHeitiSC-Medium";
    else
        return @"STHeitiSC-Light";
    
}

+ (void) underlineButton: (UIButton *) button
{
    // To underline forgot password link!
    float x = button.titleLabel.frame.origin.x;
    float y = button.titleLabel.frame.origin.y + button.titleLabel.frame.size.height;
    float titleWidth = button.titleLabel.frame.size.width;
    UILabel *underline = [[UILabel alloc] initWithFrame:CGRectMake(x, y, titleWidth, 1)];
    [underline setBackgroundColor:[UIColor blackColor]];
    [button addSubview:underline];
}

@end
