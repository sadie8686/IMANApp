//
//  IMANHomeViewController.h
//  IMANApp
//
//  Created by  on 19/02/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMANAppDelegate.h"

@interface IMANHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IMANAppDelegate *appDelegate;
    
    IBOutlet UIView *textOverBannerView;
    IBOutlet UITableView *table;    
    IBOutlet UILabel *bannerTitle;
    IBOutlet UILabel *bannerDescription;
    
    NSMutableArray *table_data;
    
    NSTimer *bannerTimer;
    NSTimer *showbannerTimer;
   
}
- (IBAction)openPlumPerfect:(id)sender;
@end
