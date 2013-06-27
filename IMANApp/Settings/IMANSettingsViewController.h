//
//  IMANSettingsViewController.h
//  IMANApp
//
//  Created by  on 19/02/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMANAppDelegate.h"

@interface IMANSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    IMANAppDelegate *appDelegate;
    UITableView *settingsTable;
    
}

@property (nonatomic, retain) IBOutlet UITableView *settingsTable;

@end
