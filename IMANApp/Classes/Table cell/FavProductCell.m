//
//  FavProductCell.m
//  IMAN
//
//  Created by  on 20/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "FavProductCell.h"

@implementation FavProductCell

@synthesize badgeImgView, prodImgView, prodNameLabel, prodDescrLabel, prodPriceLabel;
@synthesize prodRemoveFavBtn, prodFindItBtn;

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
    
    UIView *selectedView = [[UIView alloc] initWithFrame:self.frame];
    selectedView.backgroundColor = [UIColor lightGrayColor];
    self.selectedBackgroundView = selectedView;
    // Configure the view for the selected state
}

@end
