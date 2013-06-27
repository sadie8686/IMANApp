//
//  Constants.m
//  
//
//  Created by My Mac on 22/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"

@implementation Constants

+ (UIButton *) customRightHomeButton
{
    //Rightbar button Image
    UIImage *rightButtonImage = [[UIImage imageNamed:@"button.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
    UIButton  *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0.0, 0.0, 40.0, 30.0);
    [rightButton setBackgroundImage:rightButtonImage forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:23];
    [rightButton setTitle:[NSString fontAwesomeIconStringForEnum:FAIconReorder] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    return rightButton;
}

+ (UIButton *) customRightButton
{
    //Rightbar button Image
    UIImage *rightButtonImage = [[UIImage imageNamed:@"button.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
    UIButton  *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0.0, 0.0, 40.0, 30.0);
    [rightButton setBackgroundImage:rightButtonImage forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:23];
    [rightButton setTitle:[NSString fontAwesomeIconStringForEnum:FAIconOk] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    return rightButton;
}

+ (UIButton *) customBackButton
{
    //insert back button on the navigation bar
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 50.0, 30.0);
	UIImage *image = [UIImage imageNamed:@"back_btn.png"];
	[button setBackgroundImage:image forState:UIControlStateNormal];
    
    return button;
}

+ (UIButton *) customRefreshButton
{
    UIImage* menuBackImage = [[UIImage imageNamed:@"button.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
    //Refresh button in bar
    UIButton *refreshButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake(0.0, 0.0, 40.0, menuBackImage.size.height);
    [refreshButton setBackgroundImage:menuBackImage forState:UIControlStateNormal];
    refreshButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:kAwesomeFontSize];
    [refreshButton setTitle:[NSString fontAwesomeIconStringForEnum:FAIconRefresh] forState:UIControlStateNormal];
    [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refreshButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    return refreshButton;
}

+ (UILabel *) customTitleLabel:(NSString *)title
{
    CGRect frame = CGRectMake(0, 0, [title sizeWithFont:[UIFont fontWithName:@"helvetica" size:14.5]].width, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    UIFont *header=[UIFont fontWithName:@"helvetica" size:17];
    header=[UIFont boldSystemFontOfSize:17];
    label.font = header;
    label.textAlignment = UITextAlignmentCenter;
    label.text = title;
    label.adjustsFontSizeToFitWidth = YES;
    
    return label;
}

+ (UILabel *)iconLabelSettings
{
    UILabel *icLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 7, 30, 30)];
    icLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:22];
    icLabel.textColor = [UIColor darkGrayColor];
    icLabel.textAlignment = UITextAlignmentCenter;
    icLabel.backgroundColor = [UIColor clearColor];
    
    return icLabel;
}

// adjust the height of a multi-line label to make it align vertical with top
+ (void) alignLabelWithTop:(UILabel *)label {
    CGSize maxSize = CGSizeMake(label.frame.size.width, 999);
    label.adjustsFontSizeToFitWidth = NO;
    
    // get actual height
    CGSize actualSize = [label.text sizeWithFont:label.font constrainedToSize:maxSize lineBreakMode:label.lineBreakMode];
    CGRect rect = label.frame;
    rect.size.height = actualSize.height;
    label.frame = rect;
}

+ (UIButton *) customFavButton
{
    UIButton *customBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    customBtn.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:22];
    [customBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAIconHeartEmpty] forState:UIControlStateNormal];
    [customBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAIconHeart] forState:UIControlStateSelected];
    [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [customBtn setTitleColor:[UIColor colorWithRed:202.0/255.0 green:153.0/255.0 blue:44.0/255.0 alpha:1.0] forState:UIControlStateSelected];
    
    return customBtn;
}

+ (UIButton *) customSearchButton
{
    UIButton *customBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    customBtn.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:22];
    [customBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAIconSearch] forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    return customBtn;
}

+ (UIButton *) customVideoButton
{
    UIButton *customBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    customBtn.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:22];
    [customBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAIconPlayCircle] forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    return customBtn;
}

+ (UIButton *) customShareButton
{
    UIButton *customBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    customBtn.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:22];
    [customBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAIconShareAlt] forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    return customBtn;
}

@end
