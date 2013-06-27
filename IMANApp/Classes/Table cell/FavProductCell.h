//
//  FavProductCell.h
//  IMAN
//
//  Created by  on 20/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavProductCell : UITableViewCell
{
    UIImageView *badgeImgView;
    UIImageView *prodImgView;
    UILabel *prodNameLabel;
    UILabel *prodDescrLabel;
    UILabel *prodPriceLabel;
    UIButton *prodRemoveFavBtn;
    UIButton *prodFindItBtn;
}

@property (nonatomic, retain) IBOutlet UIImageView *badgeImgView;
@property (nonatomic, retain) IBOutlet UIImageView *prodImgView;
@property (nonatomic, retain) IBOutlet UILabel *prodNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *prodDescrLabel;
@property (nonatomic, retain) IBOutlet UILabel *prodPriceLabel;
@property (nonatomic, retain) IBOutlet UIButton *prodRemoveFavBtn;
@property (nonatomic, retain) IBOutlet UIButton *prodFindItBtn;

@end
