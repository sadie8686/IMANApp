//
//  IMANHomeViewController.m
//  IMANApp
//
//  Created by  on 19/02/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "IMANHomeViewController.h"
#import "Constants.h"
#import "NSString+FontAwesome.h"
#import "CMRootViewController.h"
@interface IMANHomeViewController ()

@end

@implementation IMANHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = NSLocalizedString(@"Beauty For Your Skintone", @"Beauty For Your Skintone");
        self.tabBarItem.title = @"";
        UIImage *tab0Image = [UIImage imageNamed:@"home.png"];
        UITabBarItem *tab0 = [[UITabBarItem alloc] initWithTitle:@"" image:tab0Image tag:0];
        float topInset = 5.0f;
        tab0.imageInsets = UIEdgeInsetsMake(topInset, 0.0f, -topInset, 0.0f);
        [tab0 setFinishedSelectedImage:tab0Image withFinishedUnselectedImage:tab0Image];
        [self setTabBarItem:tab0];
        return self;
        
        
    }
    return self;
}

- (void) customUISettings
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (IMANAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationItem.titleView = [Constants customTitleLabel:@"Beauty For Your Skintone"];
    self.title = @"";
    
    [self customUISettings];
    
    textOverBannerView.layer.cornerRadius = 5.0;
    
    table_data = [[NSMutableArray alloc] initWithObjects:@"BROWSE COSMETICS", @"FIND YOUR SHADE", @"SKINCARE", @"TRY IT ON", @"WHAT'S HOT!", @"GET THE LOOK", nil];
    
    table.dataSource = self;
    table.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Nav bar background image
    UIImage* navImage = [UIImage imageNamed:kNavImg];
    [self.navigationController.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
   // [self.navigationController.navigationBar setHidden:YES];
    NSLog(@"WIFIII: %@", appDelegate.networkValue);
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [table flashScrollIndicators];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [table_data count];
}

- (CGFloat)tableView:(UITableView *)tableView1 heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5) {
        return 44;
    }
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    // Configure the cell...
    cell.backgroundColor = [UIColor whiteColor];
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView = bgView;
    
    UIFont *lblFont = [UIFont fontWithName:@"helvetica" size:16.0];
    lblFont=[UIFont boldSystemFontOfSize:16.0];
    UILabel *textmainLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 300, 21)];
    if (IS_IPHONE_5) {
        textmainLbl.frame = CGRectMake(0, 11, 300, 21);
    }
    textmainLbl.backgroundColor = [UIColor clearColor];
    textmainLbl.textColor = [UIColor blackColor];
    textmainLbl.font = lblFont;
    textmainLbl.textAlignment = UITextAlignmentCenter;
    textmainLbl.text = [table_data objectAtIndex:[indexPath row]];
    
    [cell.contentView addSubview:textmainLbl];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)openPlumPerfect:(id)sender
{
    NSString *uid = @"0";
    if ([Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary])
    {
        NSLog(@"Profile dict: %@", [Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary]);
        uid = [[Utils getObjectFromUserdefaultsWithKey:UserProfileDictionary] valueForKey:UserID];
    }
    if (![uid isEqualToString:@"0"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PlumPerfect" bundle:nil];
        CMRootViewController *myVC = (CMRootViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CMRootViewController"];
        UINavigationController *plumNavigation=[[UINavigationController alloc] initWithRootViewController:myVC];
        [self presentModalViewController:plumNavigation animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already registered?" message:@"Please signin to continue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        alert.tag = 77;
        [alert show];
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 77) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            NSLog(@"Open");
            appDelegate.tabBarController.selectedIndex = 4;
        }
    }
}
@end
