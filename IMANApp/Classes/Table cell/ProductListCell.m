//
//  ProductListCell.m
//  IMAN
//
//  Created by  on 22/02/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "ProductListCell.h"

@implementation ProductListCell

@synthesize prodImageView, prodNameLabel;

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


/*
 CGFloat indent = 10;
 CGRect innerRect = CGRectMake(indent,indent,view.frame.size.width-2*indent,view.frame.size.height-2*indent);
 UIView * shadowView = [[UIView alloc] initWithFrame:innerRect];
 shadowView.backgroundColor = [UIColor clearColor];
 shadowView.layer.masksToBounds = NO;
 shadowView.layer.cornerRadius = 8; // if you like rounded corners
 shadowView.layer.shadowRadius = 5;
 shadowView.layer.shadowOpacity = 0.5;
 shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowView.bounds].CGPath;
 [view addSubview:shadowView];

*/


@end
