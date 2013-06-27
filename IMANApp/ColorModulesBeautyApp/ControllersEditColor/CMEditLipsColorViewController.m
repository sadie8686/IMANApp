//
//  CMEditLipsColorViewController.m
//  ColorModulesBeautyApp
//
//  Created by Abhijit Sarkar on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMEditLipsColorViewController.h"
#import "CMEditColorCell.h"
#import "ColorUtility.h"
#import "CMUserModel.h"
#import "AFHTTPClient.h"
#import "CMConstants.h"
#import "AFJSONRequestOperation.h"
#import "Logging.h"
#import "SVProgressHUD.h"


@interface CMEditLipsColorViewController ()
@property int selected_index;
@property (strong, nonatomic) IBOutlet UIImageView *colorSelectedImage;
@end

@implementation CMEditLipsColorViewController
@synthesize itemList = _itemList;
@synthesize lbl_TapColorToSelect = _lbl_TapColorToSelect;
@synthesize useThisColorButton = _useThisColorButton;
@synthesize lastItemView = _lastItemView;
@synthesize mLipsColorCode = _mLipsColorCode;
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
                red = 255.0f/255.0f; green = 198.0f/255.0f; blue = 199.0f/255.0f;
                break;
            }
            case 1:
            {
                red = 253.0f/255.0f; green = 165.0f/255.0f; blue = 176.0f/255.0f;
                break;
            }
            case 2:
            {
                red = 236.0f/255.0f; green = 158.0f/255.0f; blue = 149.0f/255.0f;
                break;
            }
            case 3:
            {
                red = 214.0f/255.0f; green = 167.0f/255.0f; blue = 169.0f/255.0f;
                break;
            }
            case 4:
            {
                red = 227.0f/255.0f; green = 153.0f/255.0f; blue = 160.0f/255.0f;
                break;
            }
            case 5:
            {
                red = 228.0f/255.0f; green = 152.0f/255.0f; blue = 147.0f/255.0f;
                break;
            }
            case 6:
            {
                red = 179.0f/255.0f; green = 125.0f/255.0f; blue = 124.0f/255.0f;
                break;
            }
            case 7:
            {
                red = 145.0f/255.0f; green = 56.0f/255.0f; blue = 55.0f/255.0f;
                break;
            }
            case 8:
            {
                red = 138.0f/255.0f; green = 58.0f/255.0f; blue = 51.0f/255.0f;
                break;
            }
            case 9:
            {
                red = 88.0f/255.0f; green = 49.0f/255.0f; blue = 43.0f/255.0f;
                break;
            }
            case 10:
            {
                red = 80.0f/255.0f; green = 57.0f/255.0f; blue = 55.0f/255.0f;
                break;
            }
            case 11:
            {
                red = 41.0f/255.0f; green = 18.0f/255.0f; blue = 22.0f/255.0f;
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
                          @"Lips1", @"LeftName", @"lips_new1.png", @"LeftImage", @"lips_new1.png",@"LeftImageSelected",
                          @"Lips2", @"MidName", @"lips_new2.png", @"MidImage", @"lips_new2.png", @"MidImageSelected",
                          @"Lips3", @"RightName", @"lips_new3.png", @"RightImage", @"lips_new3.png", @"RightImageSelected",
                          nil];
    
    NSDictionary *row2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Lips4", @"LeftName", @"lips_new4.png", @"LeftImage", @"lips_new4.png", @"LeftImageSelected",
                          @"Lips5", @"MidName", @"lips_new5.png", @"MidImage", @"lips_new5.png",@"MidImageSelected",
                          @"Lips6", @"RightName", @"lips_new6.png", @"RightImage", @"lips_new6.png", @"RightImageSelected",
                          nil];
    
    NSDictionary *row3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Lips7", @"LeftName", @"lips_new7.png", @"LeftImage", @"lips_new7.png", @"LeftImageSelected",
                          @"Lips8", @"MidName", @"lips_new8.png", @"MidImage", @"lips_new8.png",@"MidImageSelected",
                          @"Lips9", @"RightName", @"lips_new9.png", @"RightImage", @"lips_new9.png", @"RightImageSelected",
                          nil];
    
    NSDictionary *row4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Lips10", @"LeftName", @"lips_new10.png", @"LeftImage", @"lips_new10.png", @"LeftImageSelected",
                          @"Lips11", @"MidName", @"lips_new11.png", @"MidImage", @"lips_new11.png",@"MidImageSelected",
                          @"Lips12", @"RightName", @"lips_new12.png", @"RightImage", @"lips_new12.png", @"RightImageSelected",
                          nil];
    
    /*
     NSDictionary *row5 = [[NSDictionary alloc] initWithObjectsAndKeys:
     @"Lips13", @"LeftName", @"Lips13@2x.png", @"LeftImage", @"Lips13@2x.png", @"LeftImageSelected",
     @"Lips14", @"MidName", @"Lips14@2x.png", @"MidImage", @"Lips14@2x.png", @"MidImageSelected",
     @"Lips15", @"RightName", @"Lips15@2x.png", @"RightImage", @"Lips15@2x.png",@"RightImageSelected",
     nil];
     
     NSDictionary *row6 = [[NSDictionary alloc] initWithObjectsAndKeys:
     @"Lips16", @"LeftName", @"Lips16@2x.png", @"LeftImage", @"Lips16@2x.png", @"LeftImageSelected",
     nil];
     
     NSArray *array = [[NSArray alloc] initWithObjects: row1, row2, row3, row4, row5, row6, nil];
     */
    NSArray *array = [[NSArray alloc] initWithObjects: row1, row2, row3, row4, nil];
    self.itemList = array;
    self.selected_index = -1;
}

- (IBAction)useThisColor:(id)sender
{
    CGFloat red = 0, green = 0, blue = 0;
    
    if (self.selected_index < 0 || self.selected_index > 15)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Lips Color Selected"
                                                            message:[NSString stringWithFormat:@"Please first select an Lips color to proceed."]
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
             1:  255, 198, 199
             2:  253, 165, 176
             3:  236, 158, 149
             */
        case 0:
        {
            red = 255.0f/255.0f; green = 198.0f/255.0f; blue = 199.0f/255.0f;
            break;
        }
        case 1:
        {
            red = 253.0f/255.0f; green = 165.0f/255.0f; blue = 176.0f/255.0f;
            break;
        }
        case 2:
        {
            red = 236.0f/255.0f; green = 158.0f/255.0f; blue = 149.0f/255.0f;
            break;
        }
            /*
             4:  214, 167, 169
             5:  227, 153, 160
             6:  228, 152, 147
             */
        case 3:
        {
            red = 214.0f/255.0f; green = 167.0f/255.0f; blue = 169.0f/255.0f;
            break;
        }
        case 4:
        {
            red = 227.0f/255.0f; green = 153.0f/255.0f; blue = 160.0f/255.0f;
            break;
        }
        case 5:
        {
            red = 228.0f/255.0f; green = 152.0f/255.0f; blue = 147.0f/255.0f;
            break;
        }
            /*
             7:  179, 125, 124
             8:  145, 56, 55
             9:  138, 58, 51
             */
        case 6:
        {
            red = 179.0f/255.0f; green = 125.0f/255.0f; blue = 124.0f/255.0f;
            break;
        }
        case 7:
        {
            red = 145.0f/255.0f; green = 56.0f/255.0f; blue = 55.0f/255.0f;
            break;
        }
        case 8:
        {
            red = 138.0f/255.0f; green = 58.0f/255.0f; blue = 51.0f/255.0f;
            break;
        }
            /*
             10:  88, 49, 43
             11:  80, 57, 55
             12:  41, 18, 22
             */
        case 9:
        {
            red = 88.0f/255.0f; green = 49.0f/255.0f; blue = 43.0f/255.0f;
            break;
        }
        case 10:
        {
            red = 80.0f/255.0f; green = 57.0f/255.0f; blue = 55.0f/255.0f;
            break;
        }
        case 11:
        {
            red = 41.0f/255.0f; green = 18.0f/255.0f; blue = 22.0f/255.0f;
            break;
        }
        default:
        {
            break;
        }
    }
    
    self.mLipsColorCode = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
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
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.skinColor] forKey:@"skin"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:self.mLipsColorCode] forKey:@"lips"];
    
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
