//
//  FindShadeCell.m
//  IMAN
//
//  Created by  on 04/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "FindShadeCell.h"

@implementation FindShadeCell

@synthesize shadeImageView, shadeNameLabel;

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
