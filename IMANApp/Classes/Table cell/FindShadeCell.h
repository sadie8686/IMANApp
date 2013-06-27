//
//  FindShadeCell.h
//  IMAN
//
//  Created by  on 04/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindShadeCell : UITableViewCell
{
    UIImageView *shadeImageView;
    UILabel *shadeNameLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *shadeImageView;
@property (nonatomic, retain) IBOutlet UILabel *shadeNameLabel;

@end
