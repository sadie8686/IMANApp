//
//  ProductListCell.h
//  IMAN
//
//  Created by  on 22/02/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductListCell : UITableViewCell
{
    UIImageView *prodImageView;
    UILabel *prodNameLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *prodImageView;
@property (nonatomic, retain) IBOutlet UILabel *prodNameLabel;
@end
