//
//  CMEditColorCell.m
//  ColorModulesBeautyApp
//
//  Created by Abhijit Sarkar on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMEditColorCell.h"

@implementation CMEditColorCell

@synthesize leftEditColorView = _leftEditColorView;
@synthesize midEditColorView = _midEditColorView;
@synthesize rightEditColorView=_rightEditColorView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
