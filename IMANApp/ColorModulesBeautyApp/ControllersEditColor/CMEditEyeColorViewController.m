//
//  CMEditEyeColorViewController.m
//  ColorModulesBeautyApp
//
//  Created by Abhijit Sarkar on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMEditEyeColorViewController.h"
#import "CMEditColorCell.h"
#import "ColorUtility.h"
#import "CMUserModel.h"
#import "AFHTTPClient.h"
#import "CMConstants.h"
#import "AFJSONRequestOperation.h"
#import "Logging.h"
#import "SVProgressHUD.h"

@interface CMEditEyeColorViewController ()
@property int selected_index;
@property (strong, nonatomic) IBOutlet UIImageView *colorSelectedImage;

@end

@implementation CMEditEyeColorViewController
@synthesize itemList = _itemList;
@synthesize useThisColorButton = _useThisColorButton;
@synthesize lastItemView = _lastItemView;
@synthesize mEyeColorCode = _mEyeColorCode;
@synthesize editColorTable = _editColorTable;
@synthesize selected_index = _selected_index;
@synthesize colorSelectedImage = _colorSelectedImage;


// dataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows = [self.itemList count];
    NSLog(@"Item size: %i",[self.itemList count]);
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"editColor";
    CMEditColorCell *cell=(CMEditColorCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CMEditColorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSLog(@"indexPath.row: %d",indexPath.row);
    
    //display available cell item
    NSDictionary *rowData = [self.itemList objectAtIndex: indexPath.row];
    
    UIImage *leftImage = [UIImage imageNamed: [rowData objectForKey:@"LeftImage"]];
    UIImage *leftHighlightedImage = [UIImage imageNamed: [rowData objectForKey:@"LeftImageSelected"]];
    cell.leftEditColorView.image = leftImage;
    cell.leftEditColorView.highlightedImage = leftHighlightedImage;
    cell.leftEditColorView.tag=indexPath.row * 3;
    UITapGestureRecognizer *tapGuesture_left=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [cell.leftEditColorView addGestureRecognizer:tapGuesture_left];
    [cell.leftEditColorView setUserInteractionEnabled:YES];
    
    
    UIImage *midImage = [UIImage imageNamed: [rowData objectForKey:@"MidImage"]];
    UIImage *midHighlightedImage = [UIImage imageNamed: [rowData objectForKey:@"MidImageSelected"]];
    cell.midEditColorView.image = midImage;
    cell.midEditColorView.highlightedImage = midHighlightedImage;
    cell.midEditColorView.tag=indexPath.row * 3 + 1;
    UITapGestureRecognizer *tapGuesture_mid=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [cell.midEditColorView addGestureRecognizer:tapGuesture_mid];
    [cell.midEditColorView setUserInteractionEnabled:YES];
    
    
    UIImage *rightImage = [UIImage imageNamed: [rowData objectForKey:@"RightImage"]];
    UIImage *rightHighlightedImage = [UIImage imageNamed: [rowData objectForKey:@"RightImageSelected"]];
    cell.rightEditColorView.image = rightImage;
    cell.rightEditColorView.highlightedImage = rightHighlightedImage;
    cell.rightEditColorView.tag=indexPath.row * 3 + 2;
    UITapGestureRecognizer *tapGuesture_right=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [cell.rightEditColorView addGestureRecognizer:tapGuesture_right];
    [cell.rightEditColorView setUserInteractionEnabled:YES];
    
    [cell setUserInteractionEnabled:YES];
    return  cell;
}

//Action when a color is selected. Go to product detail page
-(void)tapAction: (UIGestureRecognizer *)gestureRecognizer
{
    if (self.selected_index >= 0) {
        [self.lastItemView setHighlighted:NO];
    }
    UIImageView *view = (UIImageView *)[gestureRecognizer view];
    NSLog(@"%i",view.tag);
    self.selected_index=view.tag;
    [view setHighlighted:YES];
    self.lastItemView = view;
    
    int rowNumber = self.selected_index / 3;
    int columNumber = self.selected_index % 3;
    NSDictionary *rowData = [self.itemList objectAtIndex: rowNumber];
    NSString *selectedImageName;
    
    if(columNumber == 0)
        selectedImageName = [rowData objectForKey:@"LeftImage"];
    
    else if(columNumber == 1)
        selectedImageName = [rowData objectForKey:@"MidImage"];
    
    else
        selectedImageName = [rowData objectForKey:@"RightImage"];
    
    if(selectedImageName != nil)
    {
        /*
         UIImage *selectedImage =  [UIImage imageNamed: selectedImageName];
         [self.colorSelectedImage setImage:selectedImage];
         [self.colorSelectedImage setHidden:NO];
         */
        
        CGFloat red = 0, green = 0, blue = 0;
        
        switch (self.selected_index) {
            case 0:
            {
                // green
                red = 66.0f/255.0f; green = 73.0f/255.0f; blue = 65.0f/255.0f;
                break;
            }
            case 1:
            {
                // blue
                red = 107.0f/255.0f; green = 133.0f/255.0f; blue = 151.0f/255.0f;
                break;
            }
            case 2:
            {
                // light blue
                red = 153.0f/255.0f; green = 158.0f/255.0f; blue = 161.0f/255.0f;
                break;
            }
            case 3:
            {
                // hazel
                red = 124.0f/255.0f; green = 100.0f/255.0f; blue = 57.0f/255.0f;
                break;
            }
            case 4:
            {
                // light brown
                red = 114.0f/255.0f; green = 75.0f/255.0f; blue = 47.0f/255.0f;
                break;
            }
            case 5:
            {
                // deep brown
                red = 49.0f/255.0f; green = 32.0f/255.0f; blue = 31.0f/255.0f;
                break;
            }
            default:
            {
                break;
            }
        }
        
        self.colorSelectedImage.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
        [self.colorSelectedImage setHidden:NO];
        
    }
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.editColorTable.scrollEnabled = NO;
	// Do any additional setup after loading the view.
    
    NSDictionary *row1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Green", @"LeftName", @"green.png", @"LeftImage", @"green.png", @"LeftImageSelected",
                          @"Blue", @"MidName", @"blue.png", @"MidImage", @"blue.png", @"MidImageSelected",
                          @"Light Blue", @"RightName", @"light_blue.png", @"RightImage", @"light_blue.png", @"RightImageSelected", nil];
    
    NSDictionary *row2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Hazel", @"LeftName", @"hazel.png", @"LeftImage", @"hazel.png",@"LeftImageSelected",
                          @"Light Brown", @"MidName", @"light_brown.png", @"MidImage", @"light_brown.png", @"MidImageSelected",
                          @"Deep Brown", @"RightName", @"dark_brown.png", @"RightImage", @"dark_brown.png", @"RightImageSelected", nil];
    
    
    NSArray *array = [[NSArray alloc] initWithObjects: row1, row2, nil];
    self.itemList = array;
    self.selected_index = -1;
}


- (IBAction)useThisColor:(id)sender
{
    CGFloat red = 0, green = 0, blue = 0;
    
    if (self.selected_index < 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Eye Color Selected"
                                                            message:[NSString stringWithFormat:@"Please first select an eye color to proceed."]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        alertView=nil;
        return;
        
    }
    
    NSLog(@"Sel Idx:: %i", self.selected_index);
    
    /*
     Green:       66, 73, 65
     Blue:        107, 133, 151
     Light_Blue:  153, 158, 161
     Hazel:       124, 100, 57
     Light_Brown: 114, 75, 47
     Dark_Brown:  49, 32, 31
     */
    
    switch (self.selected_index) {
        case 0:
        {
            // green
            red = 66.0f/255.0f; green = 73.0f/255.0f; blue = 65.0f/255.0f;
            break;
        }
        case 1:
        {
            // blue
            red = 107.0f/255.0f; green = 133.0f/255.0f; blue = 151.0f/255.0f;
            break;
        }
        case 2:
        {
            // light blue
            red = 153.0f/255.0f; green = 158.0f/255.0f; blue = 161.0f/255.0f;
            break;
        }
        case 3:
        {
            // hazel
            red = 124.0f/255.0f; green = 100.0f/255.0f; blue = 57.0f/255.0f;
            break;
        }
        case 4:
        {
            // light brown
            red = 114.0f/255.0f; green = 75.0f/255.0f; blue = 47.0f/255.0f;
            break;
        }
        case 5:
        {
            // deep brown
            red = 49.0f/255.0f; green = 32.0f/255.0f; blue = 31.0f/255.0f;
            break;
        }
            
        default:
        {
            break;
        }
    }
    
    self.mEyeColorCode = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    [self updateServerForEditColors];
}


-(IBAction)cancelEdit:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}




- (void) updateServerForEditColors
{
    [SVProgressHUD showWithStatus:@"Analyzing color" maskType:SVProgressHUDMaskTypeGradient];
    
    NSURL *url = [NSURL URLWithString:server];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    CMUserModel *userModel = [[CMUserModel alloc] initForUserProfile];
    CMUserProfileMap *userData = [userModel getUserProfileMapObject];
    
    [parameter setObject:userData.profileID forKey:@"profile_id"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.hairColor] forKey:@"hair"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:self.mEyeColorCode] forKey:@"eyes"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.skinColor] forKey:@"skin"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.lipsColor] forKey:@"lips"];
    
    NSMutableURLRequest *request = [httpClient
                                    requestWithMethod:@"POST"
                                    path: pathToAPICallForUpdatingUserColorSignature
                                    parameters:parameter];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         BOOL success=[[JSON objectForKey:@"success"] boolValue];
         if (success)
         {
             LogInfo(@"Updated user colors!!");
             [userModel updateUserColorsWithJSON: JSON];
             [self.navigationController popViewControllerAnimated:NO];
         }
         else
         {
             LogInfo(@"ERROR: %@ %@", response, JSON);
         }
         [SVProgressHUD dismiss];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         NSLog(@"error:%i, desc: %@", response.statusCode,response.description);
         [SVProgressHUD showErrorWithStatus:@"It appears you have lost internet connectivity. Please check your network settings."];
     }];
    
    [operation start];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.lastItemView = nil;
    self.itemList = nil;
    self.useThisColorButton = nil;
    self.editColorTable = nil;
}

@end
