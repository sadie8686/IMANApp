//
//  CMFacebookPhotoAlbumCell.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 1/30/13.
//
//

#import <UIKit/UIKit.h>

@interface CMFacebookPhotoAlbumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *albumAContainer;
@property (weak, nonatomic) IBOutlet UIImageView *albumACoverImage;
@property (weak, nonatomic) IBOutlet UILabel *albumAName;

@property (weak, nonatomic) IBOutlet UIView *albumBContainer;
@property (weak, nonatomic) IBOutlet UIImageView *albumBCoverImage;
@property (weak, nonatomic) IBOutlet UILabel *albumBName;

@end
