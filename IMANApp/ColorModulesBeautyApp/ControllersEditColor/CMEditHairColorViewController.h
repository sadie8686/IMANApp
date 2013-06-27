//
//  CMEditHairColorViewController.h
//  ColorModulesBeautyApp
//
//  Created by Abhijit Sarkar on 7/24/12./Users/sarkarabh/Documents/_MyWork_ColorModules/iPhoneAppDev/_DevPlumPerfect/PlumPerfect/ColorModulesBeautyApp.xcodeproj
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CMEditHairColorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UIColor *mHairColorCode;
@property (strong, nonatomic) NSArray *itemList;
@property (weak, nonatomic) UIImageView *lastItemView;
@property (weak, nonatomic) IBOutlet UITableView *editColorTable;
@property (weak, nonatomic) IBOutlet UILabel *lbl_TapColorToSelect;
@property (weak, nonatomic) IBOutlet UIButton *useThisColorButton;

- (IBAction)useThisColor:(id)sender;
- (IBAction)cancelEdit:(id)sender;
@end
