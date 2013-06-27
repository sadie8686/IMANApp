//
//  CMShopByColorViewController.h
//  ColorModulesBeautyApp
//
//  Created by Nicky Liu on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMBrowseProducts : UIViewController <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *Lips;
@property (weak, nonatomic) IBOutlet UIButton *Eyes;
@property (weak, nonatomic) IBOutlet UIButton *Face;

@end
