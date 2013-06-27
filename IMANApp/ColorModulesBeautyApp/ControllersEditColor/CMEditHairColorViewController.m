//
//  CMEditHairColorViewController.m
//  ColorModulesBeautyApp
//
//  Created by Abhijit Sarkar on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMEditHairColorViewController.h"
#import "CMEditColorCell.h"
#import "ColorUtility.h"
#import "CMUserModel.h"
#import "AFHTTPClient.h"
#import "CMConstants.h"
#import "AFJSONRequestOperation.h"
#import "Logging.h"
#import "SVProgressHUD.h"

@interface CMEditHairColorViewController ()
@property int selected_index;
@property (strong, nonatomic) IBOutlet UIImageView *colorSelectedImage;
@end


@implementation CMEditHairColorViewController
@synthesize itemList = _itemList;
@synthesize lbl_TapColorToSelect = _lbl_TapColorToSelect;
@synthesize useThisColorButton = _useThisColorButton;
@synthesize lastItemView = _lastItemView;
@synthesize mHairColorCode = _mHairColorCode;
@synthesize editColorTable = _editColorTable;
@synthesize selected_index = _selected_index;
@synthesize colorSelectedImage = _colorSelectedImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    NSDictionary *row1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"h_white.png", @"LeftImage",
                          @"h_platinum.png", @"MidImage",
                          @"h_dirtyblond.png", @"RightImage",
                          nil];
    
    NSDictionary *row2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"h_golden.png", @"LeftImage",
                          @"h_goldenbrown.png", @"MidImage",
                          @"h_lightauburn.png", @"RightImage",
                          nil];
    
    NSDictionary *row3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"h_lightbrown.png", @"LeftImage",
                          @"h_darkred.png", @"MidImage",
                          @"h_auburn.png", @"RightImage",
                          nil];
    
    NSDictionary *row4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"h_chestnut.png", @"LeftImage",
                          @"h_brown.png", @"MidImage",
                          @"h_darkbrown.png", @"RightImage",
                          nil];
    
    NSDictionary *row5 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"h_blackbrown.png", @"LeftImage",
                          @"h_black.png", @"MidImage",
                          @"h_orange.png", @"RightImage",
                          nil];
    
    NSDictionary *row6 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"h_red.png", @"LeftImage",
                          nil];
    
    NSArray *array = [[NSArray alloc] initWithObjects: row1, row2, row3, row4, row5, row6, nil];
    self.itemList = array;
    self.selected_index = -1;
    
}


// dataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows = [self.itemList count];
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
    cell.leftEditColorView.image = leftImage;
    cell.leftEditColorView.highlightedImage = leftImage;
    cell.leftEditColorView.tag=indexPath.row * 3;
    UITapGestureRecognizer *tapGuesture_left=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [cell.leftEditColorView addGestureRecognizer:tapGuesture_left];
    [cell.leftEditColorView setUserInteractionEnabled:YES];
    
    
    UIImage *midImage = [UIImage imageNamed: [rowData objectForKey:@"MidImage"]];
    cell.midEditColorView.image = midImage;
    cell.midEditColorView.highlightedImage = midImage;
    cell.midEditColorView.tag=indexPath.row * 3 + 1;
    UITapGestureRecognizer *tapGuesture_mid=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [cell.midEditColorView addGestureRecognizer:tapGuesture_mid];
    [cell.midEditColorView setUserInteractionEnabled:YES];
    
    
    UIImage *rightImage = [UIImage imageNamed: [rowData objectForKey:@"RightImage"]];
    cell.rightEditColorView.image = rightImage;
    cell.rightEditColorView.highlightedImage = rightImage;
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
        UIImage *selectedImage =  [UIImage imageNamed: selectedImageName];
        [self.colorSelectedImage setImage:selectedImage];
        [self.colorSelectedImage setHidden:NO];
    }
}


- (IBAction)useThisColor:(id)sender
{
    CGFloat red = 0, green = 0, blue = 0;
    
    if (self.selected_index < 0 || self.selected_index > 15)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Hair Color Selected"
                                                            message:[NSString stringWithFormat:@"Please first select an Hair color to proceed."]
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
             0 white:		R 207		G 208		B 210
             1 platinum:	R 222		G 196		B 148
             2 dirtyblond:  R 206		G 176		B 118
             */
        case 0:
        {
            // white
            red = 207.0f/255.0f; green = 208.0f/255.0f; blue = 210.0f/255.0f;
            break;
        }
        case 1:
        {
            // platinum
            red = 222.0f/255.0f; green = 196.0f/255.0f; blue = 148.0f/255.0f;
            break;
        }
        case 2:
        {
            // dirtyblond
            red = 206.0f/255.0f; green = 176.0f/255.0f; blue = 118.0f/255.0f;
            break;
        }
            /*
             3 golden:		R 217		G 180		B 105
             4 goldenbrown: R 100		G 78		B 32
             5 lightauburn: R 138		G 98		B 45
             */
        case 3:
        {
            // golden
            red = 217.0f/255.0f; green = 180.0f/255.0f; blue = 105.0f/255.0f;
            break;
        }
        case 4:
        {
            // goldenbrown
            red = 100.0f/255.0f; green = 78.0f/255.0f; blue = 32.0f/255.0f;
            break;
        }
        case 5:
        {
            // lightauburn
            red = 138.0f/255.0f; green = 98.0f/255.0f; blue = 45.0f/255.0f;
            break;
        }
            /*
             6 lightbrown	R 103		G 67		B 35
             7 darkred:     R 84		G 46		B 37
             8 auburn:      R 88 		G 62 		B 30
             */
        case 6:
        {
            //
            red = 103.0f/255.0f; green = 67.0f/255.0f; blue = 35.0f/255.0f;
            break;
        }
        case 7:
        {
            //
            red = 84.0f/255.0f; green = 46.0f/255.0f; blue = 37.0f/255.0f;
            break;
        }
        case 8:
        {
            //
            red = 88.0f/255.0f; green = 62.0f/255.0f; blue = 30.0f/255.0f;
            break;
        }
            /*
             9 chestnut: 	R 80		G 65 		B 48
             10 brown: 		R 77 		G 55 		B 33
             11 darkbrown:	R 52		G 43		B 30
             */
        case 9:
        {
            // chestnut
            red = 80.0f/255.0f; green = 65.0f/255.0f; blue = 48.0f/255.0f;
            break;
        }
        case 10:
        {
            // brown
            red = 77.0f/255.0f; green = 55.0f/255.0f; blue = 33.0f/255.0f;
            break;
        }
        case 11:
        {
            // darkbrown
            red = 52.0f/255.0f; green = 43.0f/255.0f; blue = 30.0f/255.0f;
            break;
        }
            /*
             12 blackbrown: R 40 		G 37 		B 30
             13 black: 		R 29 		G 30 		B 28
             14 orange:		R 152		G 57		B 31
             */
        case 12:
        {
            // blackbrown
            red = 40.0f/255.0f; green = 37.0f/255.0f; blue = 30.0f/255.0f;
            break;
        }
        case 13:
        {
            // black
            red = 29.0f/255.0f; green = 30.0f/255.0f; blue = 28.0f/255.0f;
            break;
        }
        case 14:
        {
            // orange
            red = 152.0f/255.0f; green = 57.0f/255.0f; blue = 31.0f/255.0f;
            break;
        }
            // 15 red:		R 111		G 40		B 24
        case 15:
        {
            // red
            red = 111.0f/255.0f; green = 40.0f/255.0f; blue = 24.0f/255.0f;
            break;
        }
        default:
        {
            break;
        }
    }
    
    self.mHairColorCode = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
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
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:self.mHairColorCode] forKey:@"hair"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.eyesColor] forKey:@"eyes"];
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
    // Release any retained subviews of the main view.
    self.lastItemView = nil;
    self.itemList = nil;
    self.lbl_TapColorToSelect = nil;
    self.useThisColorButton = nil;
    self.editColorTable = nil;
    [self setColorSelectedImage:nil];
    
    [super viewDidUnload];
    
}


@end
