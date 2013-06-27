//
//  CMProductThisFilterViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 10/24/12.
//
//

#import "CMProductFilterDetailsViewController.h"
#import "FilterValueMap.h"
#import "CMFilterModel.h"
#import "CMConstants.h"
#import "QuartzCore/QuartzCore.h"

@interface CMProductFilterDetailsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *viewTitle;
@property (strong, nonatomic) NSString *viewTitleString;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CMFilterModel *filterModel;
@property (nonatomic, strong) NSArray *filterValues;
@property (nonatomic, strong) NSIndexPath *previousSelectedCellIndexPath;
@end

@implementation CMProductFilterDetailsViewController
@synthesize tableView = _tableView;

- (void) myInitializeWithThisViewName: (NSString*) newThisViewName
                      withFilterModel: (CMFilterModel *) filterModel
         withDictionaryOfFilterArrays: (NSArray *) filterValues
{
    _viewTitleString = newThisViewName;
    _filterValues = filterValues;
    _filterModel = filterModel;
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewTitle.text = self.viewTitleString;
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
    return [self.filterValues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"filterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // To set the cell title...
    FilterValueMap *thisFilterValue = [self.filterValues objectAtIndex:indexPath.row];
    
    // To check / uncheck the previously set values...
    if(thisFilterValue.isSelected)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = thisFilterValue.title;
    cell.textLabel.alpha = 1.0f;
    cell.userInteractionEnabled = YES;
    
    if(thisFilterValue.isSelected)
    {
        self.previousSelectedCellIndexPath = indexPath;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilterValueMap *thisFilterValue = [self.filterValues objectAtIndex:indexPath.row];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(thisFilterValue.isSelected)
    {
        thisFilterValue.isSelected = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if([self.viewTitleString isEqualToString:@"Look"] || [self.viewTitleString isEqualToString:@"Match"])
        {
            self.previousSelectedCellIndexPath = nil;
        }
    }
    
    else
    {
        // As we can select only one Look / Match at a time...
        if(([self.viewTitleString isEqualToString:@"Look"] || [self.viewTitleString isEqualToString:@"Match"]) && self.previousSelectedCellIndexPath)
        {
            UITableViewCell* previousSelectedCell = [tableView cellForRowAtIndexPath:self.previousSelectedCellIndexPath];
            previousSelectedCell.accessoryType = UITableViewCellAccessoryNone;
            FilterValueMap *previousFilterValue = [self.filterValues objectAtIndex:self.previousSelectedCellIndexPath.row];
            previousFilterValue.isSelected = NO;
        }
        
        // To toggle the checkmark. To Check.
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        thisFilterValue.isSelected = YES;
        self.previousSelectedCellIndexPath = indexPath;
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:NO];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [self.filterModel synchronize];
}

- (void) viewDidUnload
{
    [self setTableView:nil];
    [self setViewTitle:nil];
    [super viewDidUnload];
}
@end
