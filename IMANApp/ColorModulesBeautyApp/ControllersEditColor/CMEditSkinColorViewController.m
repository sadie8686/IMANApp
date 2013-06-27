//
//  CMEditSkinColorViewController.m
//  ColorModulesBeautyApp
//
//  Created by Abhijit Sarkar on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMEditSkinColorViewController.h"
#import "CMEditColorCell.h"
#import "ColorUtility.h"
#import "CMUserModel.h"
#import "Logging.h"
#import "AFHTTPClient.h"
#import "CMConstants.h"
#import "AFJSONRequestOperation.h"
#import "SVProgressHUD.h"

@interface CMEditSkinColorViewController ()
@property int selected_index;
@property (strong, nonatomic) IBOutlet UIImageView *colorSelectedImage;
@end

@implementation CMEditSkinColorViewController
@synthesize itemList = _itemList;
@synthesize lbl_TapColorToSelect = _lbl_TapColorToSelect;
@synthesize useThisColorButton = _useThisColorButton;
@synthesize lastItemView = _lastItemView;
@synthesize mSkinColorCode = _mSkinColorCode;
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
                red = 245.0f/255.0f; green = 219.0f/255.0f; blue = 210.0f/255.0f;
                break;
            }
            case 1:
            {
                red = 254.0f/255.0f; green = 218.0f/255.0f; blue = 206.0f/255.0f;
                break;
            }
            case 2:
            {
                red = 253.0f/255.0f; green = 221.0f/255.0f; blue = 198.0f/255.0f;
                break;
            }
            case 3:
            {
                red = 223.0f/255.0f; green = 179.0f/255.0f; blue = 149.0f/255.0f;
                break;
            }
            case 4:
            {
                red = 196.0f/255.0f; green = 138.0f/255.0f; blue = 104.0f/255.0f;
                break;
            }
            case 5:
            {
                red = 230.0f/255.0f; green = 183.0f/255.0f; blue = 157.0f/255.0f;
                break;
            }
            case 6:
            {
                red = 223.0f/255.0f; green = 162.0f/255.0f; blue = 125.0f/255.0f;
                break;
            }
            case 7:
            {
                red = 209.0f/255.0f; green = 159.0f/255.0f; blue = 134.0f/255.0f;
                break;
            }
            case 8:
            {
                red = 242.0f/255.0f; green = 159.0f/255.0f; blue = 112.0f/255.0f;
                break;
            }
            case 9:
            {
                red = 176.0f/255.0f; green = 110.0f/255.0f; blue = 84.0f/255.0f;
                break;
            }
            case 10:
            {
                red = 194.0f/255.0f; green = 131.0f/255.0f; blue = 100.0f/255.0f;
                break;
            }
            case 11:
            {
                red = 182.0f/255.0f; green = 110.0f/255.0f; blue = 72.0f/255.0f;
                break;
            }
            case 12:
            {
                red = 138.0f/255.0f; green = 69.0f/255.0f; blue = 54.0f/255.0f;
                break;
            }
            case 13:
            {
                red = 147.0f/255.0f; green = 98.0f/255.0f; blue = 80.0f/255.0f;
                break;
            }
            case 14:
            {
                red = 120.0f/255.0f; green = 95.0f/255.0f; blue = 88.0f/255.0f;
                break;
            }
            case 15:
            {
                red = 67.0f/255.0f; green = 38.0f/255.0f; blue = 37.0f/255.0f;
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
    
	// Do any additional setup after loading the view.
    NSDictionary *row1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"skin_new1", @"LeftName", @"skin_new1.png", @"LeftImage", @"skin_new1.png",@"LeftImageSelected",
                          @"skin_new2", @"MidName", @"skin_new2.png", @"MidImage", @"skin_new2.png", @"MidImageSelected",
                          @"skin_new3", @"RightName", @"skin_new3.png", @"RightImage", @"skin_new3.png", @"RightImageSelected",
                          nil];
    
    NSDictionary *row2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"skin_new4", @"LeftName", @"skin_new4.png", @"LeftImage", @"skin_new4.png", @"LeftImageSelected",
                          @"skin_new5", @"MidName", @"skin_new5.png", @"MidImage", @"skin_new5.png",@"MidImageSelected",
                          @"skin_new6", @"RightName", @"skin_new6.png", @"RightImage", @"skin_new6.png", @"RightImageSelected",
                          nil];
    
    NSDictionary *row3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"skin_new7", @"LeftName", @"skin_new7.png", @"LeftImage", @"skin_new7.png", @"LeftImageSelected",
                          @"skin_new8", @"MidName", @"skin_new8.png", @"MidImage", @"skin_new8.png",@"MidImageSelected",
                          @"skin_new9", @"RightName", @"skin_new9.png", @"RightImage", @"skin_new9.png", @"RightImageSelected",
                          nil];
    
    NSDictionary *row4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"skin_new10", @"LeftName", @"skin_new10.png", @"LeftImage", @"skin_new10.png", @"LeftImageSelected",
                          @"skin_new11", @"MidName", @"skin_new11.png", @"MidImage", @"skin_new11.png",@"MidImageSelected",
                          @"skin_new12", @"RightName", @"skin_new12.png", @"RightImage", @"skin_new12.png", @"RightImageSelected",
                          nil];
    
    NSDictionary *row5 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"skin_new13", @"LeftName", @"skin_new13.png", @"LeftImage", @"skin_new13.png", @"LeftImageSelected",
                          @"skin_new14", @"MidName", @"skin_new14.png", @"MidImage", @"skin_new14.png", @"MidImageSelected",
                          @"skin_new15", @"RightName", @"skin_new15.png", @"RightImage", @"skin_new15.png",@"RightImageSelected",
                          nil];
    
    NSDictionary *row6 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"skin_new16", @"LeftName", @"skin_new16.png", @"LeftImage", @"skin_new16.png", @"LeftImageSelected",
                          nil];
    
    NSArray *array = [[NSArray alloc] initWithObjects: row1, row2, row3, row4, row5, row6, nil];
    self.itemList = array;
    self.selected_index = -1;
}

- (IBAction)useThisColor:(id)sender
{
    CGFloat red = 0, green = 0, blue = 0;
    
    if (self.selected_index < 0 || self.selected_index > 15)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Skin Color Selected"
                                                            message:[NSString stringWithFormat:@"Please first select an Skin color to proceed."]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        alertView=nil;
        return;
        
    }
    
    NSLog(@"Sel Idx:: %i", self.selected_index);
    
    switch (self.selected_index) {
            /*
             1:  245,  219, 210
             2:  254, 218, 206
             3:  253, 221, 198
             */
        case 0:
        {
            red = 245.0f/255.0f; green = 219.0f/255.0f; blue = 210.0f/255.0f;
            break;
        }
        case 1:
        {
            red = 254.0f/255.0f; green = 218.0f/255.0f; blue = 206.0f/255.0f;
            break;
        }
        case 2:
        {
            red = 253.0f/255.0f; green = 221.0f/255.0f; blue = 198.0f/255.0f;
            break;
        }
            /*
             4:  223, 179, 149
             5:  196, 138, 104
             6:  230, 183, 157
             */
        case 3:
        {
            red = 223.0f/255.0f; green = 179.0f/255.0f; blue = 149.0f/255.0f;
            break;
        }
        case 4:
        {
            red = 196.0f/255.0f; green = 138.0f/255.0f; blue = 104.0f/255.0f;
            break;
        }
        case 5:
        {
            red = 230.0f/255.0f; green = 183.0f/255.0f; blue = 157.0f/255.0f;
            break;
        }
            /*
             7:  223, 162, 125
             8:  209, 159, 134
             9:  242, 159, 112
             */
        case 6:
        {
            red = 223.0f/255.0f; green = 162.0f/255.0f; blue = 125.0f/255.0f;
            break;
        }
        case 7:
        {
            red = 209.0f/255.0f; green = 159.0f/255.0f; blue = 134.0f/255.0f;
            break;
        }
        case 8:
        {
            red = 242.0f/255.0f; green = 159.0f/255.0f; blue = 112.0f/255.0f;
            break;
        }
            /*
             10:  176, 110, 84
             11:  194, 131, 100
             12:  182, 110, 72
             */
        case 9:
        {
            red = 176.0f/255.0f; green = 110.0f/255.0f; blue = 84.0f/255.0f;
            break;
        }
        case 10:
        {
            red = 194.0f/255.0f; green = 131.0f/255.0f; blue = 100.0f/255.0f;
            break;
        }
        case 11:
        {
            red = 182.0f/255.0f; green = 110.0f/255.0f; blue = 72.0f/255.0f;
            break;
        }
            /*
             13:  138, 69, 54
             14:  147, 98, 80
             15:  120, 95, 88
             */
        case 12:
        {
            red = 138.0f/255.0f; green = 69.0f/255.0f; blue = 54.0f/255.0f;
            break;
        }
        case 13:
        {
            red = 147.0f/255.0f; green = 98.0f/255.0f; blue = 80.0f/255.0f;
            break;
        }
        case 14:
        {
            red = 120.0f/255.0f; green = 95.0f/255.0f; blue = 88.0f/255.0f;
            break;
        }
            
            //  16:  67, 38, 37
        case 15:
        {
            red = 67.0f/255.0f; green = 38.0f/255.0f; blue = 37.0f/255.0f;
            break;
        }
        default:
        {
            break;
        }
    }
    
    self.mSkinColorCode = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
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
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.eyesColor] forKey:@"eyes"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:self.mSkinColorCode] forKey:@"skin"];
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
    [self setColorSelectedImage:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.lastItemView = nil;
    self.itemList = nil;
    self.lbl_TapColorToSelect = nil;
    self.useThisColorButton = nil;
    self.editColorTable = nil;
}


@end
