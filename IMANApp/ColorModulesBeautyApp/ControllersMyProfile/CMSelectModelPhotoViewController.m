/*--------------------------------------------------------------------------
 CMSelectModelPhotoViewController.m
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar
 
 Created by Abhijit Sarkar on 2012/01/24
 
 Description:
 Code for Select Model Photo view that appears when users press the button with
 same name under Take Photo View (CMBeautyTakePhotoViewController).
 
 
 Revision history:
 2012/01/27 - by AS
 2012/02/08 - by NL (add detailed objects and functions)
 
 Existing Problems:
 (date) -
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/


#import "CMSelectModelPhotoViewController.h"
#import "CMConstants.h"
#import "CMPreColorProcessing.h"
#import "SVProgressHUD.h"
#import "CMFacebookPhotoCell.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMUserModel.h"
#import "Logging.h"
#import "CMApplicationModel.h"
#import "ColorUtility.h"

#define NUMBER_OF_CONTAINERS_IN_ROW 2

@interface CMSelectModelPhotoViewController ()
@property (nonatomic, strong) NSArray *modelImageNames;
@end



@implementation CMSelectModelPhotoViewController
@synthesize modelImageNames = _modelImageNames;

- (void) configure
{
    self.modelImageNames=[[NSArray alloc] initWithObjects:
                          @"IMC-FindYourShade-Sand23-A.jpg",
                          @"IMC-FindYourShade-Sand23-B.jpg",
                          @"IMC-FindYourShade-Sand23-C.jpg",
                          
                          @"IMC-FindYourShade-Sand34-A.jpg",
                          @"IMC-FindYourShade-Sand34-B.jpg",
                          @"IMC-FindYourShade-Sand34-C.jpg",
                          
                          @"IMC-FindYourShade-Sand45-A.jpg",
                          @"IMC-FindYourShade-Sand45-B.jpg",
                          @"IMC-FindYourShade-Sand45-C.jpg",
                                                    
                          @"IMC-FindYourShade-Clay12-A.jpg",
                          @"IMC-FindYourShade-Clay12-B.jpg",
                          @"IMC-FindYourShade-Clay12-C.jpg",
                          
                          @"IMC-FindYourShade-Clay23-A.jpg",
                          @"IMC-FindYourShade-Clay23-B.jpg",
                          @"IMC-FindYourShade-Clay23-C.jpg",
                          
                          @"IMC-FindYourShade-Clay34-A.jpg",
                          @"IMC-FindYourShade-Clay34-B.jpg",
                          @"IMC-FindYourShade-Clay34-C.jpg",
                          
                          @"IMC-FindYourShade-Clay5Earth1-A.jpg",
                          @"IMC-FindYourShade-Clay5Earth1-B.jpg",
                          @"IMC-FindYourShade-Clay5Earth1-C.jpg",
                          
                          @"IMC-FindYourShade-Earth12-A.jpg",
                          @"IMC-FindYourShade-Earth12-B.jpg",
                          @"IMC-FindYourShade-Earth12-C.jpg",
                          
                          @"IMC-FindYourShade-Earth23-A.jpg",
                          @"IMC-FindYourShade-Earth23-B.jpg",
                          @"IMC-FindYourShade-Earth23-C.jpg",
                          
                          @"IMC-FindYourShade-Earth34-A.jpg",
                          @"IMC-FindYourShade-Earth34-B.jpg",
                          @"IMC-FindYourShade-Earth34-C.jpg",
                          
                          @"IMC-FindYourShade-Earth45-A.jpg",
                          @"IMC-FindYourShade-Earth45-B.jpg",
                          @"IMC-FindYourShade-Earth45-C.jpg",
                          
                          @"IMC-FindYourShade-Earth67-A.jpg",
                          @"IMC-FindYourShade-Earth67-B.jpg",
                          @"IMC-FindYourShade-Earth67-C.jpg",
                          
                          nil];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows = 1;
    int totalNumberOfContainers = self.modelImageNames.count;
    
    if (totalNumberOfContainers > NUMBER_OF_CONTAINERS_IN_ROW)
    {
        numberOfRows = totalNumberOfContainers / NUMBER_OF_CONTAINERS_IN_ROW;
        if((totalNumberOfContainers % NUMBER_OF_CONTAINERS_IN_ROW) > 0)
        {
            numberOfRows = numberOfRows + 1;
        }
    }
    
    return numberOfRows;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // To create the cell...
    NSString *cellIdentifier = @"cell";
    CMFacebookPhotoCell *cell = (CMFacebookPhotoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[CMFacebookPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // To configure the cell...
    int i=indexPath.row;
    [cell.photoA setTag:i+i];
    [cell.photoA addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(tapAction:)]];
    [cell.photoA setUserInteractionEnabled:YES];
    [cell.photoA setImage:[UIImage imageNamed:[self.modelImageNames objectAtIndex:i+i]]];
    
    [cell.photoB setHidden:YES];
    if (i+i+1 < self.modelImageNames.count)
    {
        [cell.photoB setHidden:NO];
        [cell.photoB setTag:i+i+1];
        [cell.photoB addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tapAction:)]];
        [cell.photoB setUserInteractionEnabled:YES];
        [cell.photoB setImage:[UIImage imageNamed:[self.modelImageNames objectAtIndex:i+i+1]]];
    }
    
    return cell;
    
}


- (void)tapAction: (UIGestureRecognizer *) gestureRecognizer
{
    // uploading images...
    [SVProgressHUD showWithStatus:@"Extracting colors from your image" maskType:SVProgressHUDMaskTypeGradient];
    NSString *selectedImage = [self.modelImageNames objectAtIndex:gestureRecognizer.view.tag];
    NSLog(@"Selected Image: %@", selectedImage);
    NSArray *pathComponents=[selectedImage componentsSeparatedByString:@"."];
    NSString *filePath=[[NSBundle mainBundle]
                        pathForResource:[pathComponents objectAtIndex:0]
                        ofType:[pathComponents objectAtIndex:1]];
    
    
    // To get the colors from the model image...
    NSDictionary *profileColors = [self getFacialColorsFromModelPhoto:gestureRecognizer.view.tag];
    
    // To upload the model image and colors to the server...
    [self updateServerNowWithPhotoPath: filePath
                     WithProfileColors: profileColors];
}


- (NSDictionary *) getFacialColorsFromModelPhoto: (int) modelPhotoTag
{
    UIColor *hairColor, *skinColor, *eyeColor, *lipColor;
    
    switch (modelPhotoTag) {
        // sand 2-3
        case 0:
        {
            skinColor = [UIColor colorWithRed: 230.0f/255.0f green: 183.0f/255.0f blue: 160.0f/255.0f    alpha:1.0];
            lipColor = [UIColor colorWithRed:  200.0f/255.0f green: 135.0f/255.0f blue: 111.0f/255.0f    alpha:1.0];
            hairColor = [UIColor colorWithRed: 31.0f/255.0f green: 24.0f/255.0f blue: 27.0f/255.0f    alpha:1.0];
            eyeColor = [UIColor colorWithRed:  50.0f/255.0f green: 33.0f/255.0f blue: 31.0f/255.0f    alpha:1.0];
            break;
        }
        case 1:
        {
            skinColor = [UIColor colorWithRed: 222.0f/255.0f green: 170.0f/255.0f blue: 132.0f/255.0f    alpha:1.0];
            lipColor = [UIColor colorWithRed:  205.0f/255.0f green: 116.0f/255.0f blue: 94.0f/255.0f    alpha:1.0];
            hairColor = [UIColor colorWithRed: 14.0f/255.0f green: 4.0f/255.0f blue: 4.0f/255.0f    alpha:1.0];
            eyeColor = [UIColor colorWithRed:  51.0f/255.0f green: 27.0f/255.0f blue: 19.0f/255.0f    alpha:1.0];
            break;
        }
        case 2:
        {
            skinColor = [UIColor colorWithRed: 201.0f/255.0f green: 151.0f/255.0f blue: 116.0f/255.0f    alpha:1.0];
            lipColor = [UIColor colorWithRed:  181.0f/255.0f green: 110.0f/255.0f blue: 91.0f/255.0f    alpha:1.0];
            hairColor = [UIColor colorWithRed: 17.0f/255.0f green: 11.0f/255.0f blue: 9.0f/255.0f    alpha:1.0];
            eyeColor = [UIColor colorWithRed:  49.0f/255.0f green: 25.0f/255.0f blue: 16.0f/255.0f    alpha:1.0];
            break;
        }
        // sand 3-4
        case 3:
        {
            skinColor = [UIColor colorWithRed: 210.0f/255.0f green: 153.0f/255.0f blue: 114.0f/255.0f    alpha:1.0];
            lipColor = [UIColor colorWithRed:  203.0f/255.0f green: 128.0f/255.0f blue: 109.0f/255.0f    alpha:1.0];
            hairColor = [UIColor colorWithRed: 161.0f/255.0f green: 110.0f/255.0f blue: 71.0f/255.0f    alpha:1.0];
            eyeColor = [UIColor colorWithRed:  69.0f/255.0f green: 47.0f/255.0f blue: 30.0f/255.0f    alpha:1.0];
            break;
        }
        case 4:
        {
            skinColor = [UIColor colorWithRed: 218.0f/255.0f green: 157.0f/255.0f blue: 121.0f/255.0f    alpha:1.0];
            lipColor = [UIColor colorWithRed:  192.0f/255.0f green: 112.0f/255.0f blue: 89.0f/255.0f    alpha:1.0];
            hairColor = [UIColor colorWithRed: 23.0f/255.0f green: 16.0f/255.0f blue: 13.0f/255.0f    alpha:1.0];
            eyeColor = [UIColor colorWithRed:  78.0f/255.0f green: 47.0f/255.0f blue: 33.0f/255.0f    alpha:1.0];
            break;
        }
        case 5:
        {
            skinColor = [UIColor colorWithRed: 216.0f/255.0f green: 165.0f/255.0f blue: 131.0f/255.0f    alpha:1.0];
            lipColor = [UIColor colorWithRed:  197.0f/255.0f green: 112.0f/255.0f blue: 93.0f/255.0f    alpha:1.0];
            hairColor = [UIColor colorWithRed: 18.0f/255.0f green: 12.0f/255.0f blue: 9.0f/255.0f    alpha:1.0];
            eyeColor = [UIColor colorWithRed:  44.0f/255.0f green: 23.0f/255.0f blue: 18.0f/255.0f    alpha:1.0];
            break;
        }
        // sand 4-5
        case 6:
        {
            skinColor = [UIColor colorWithRed: 208.0f/255.0f green: 149.0f/255.0f blue: 112.0f/255.0f    alpha:1.0];
            lipColor = [UIColor colorWithRed:  190.0f/255.0f green: 134.0f/255.0f blue: 114.0f/255.0f    alpha:1.0];
            hairColor = [UIColor colorWithRed: 25.0f/255.0f green: 19.0f/255.0f blue: 24.0f/255.0f    alpha:1.0];
            eyeColor = [UIColor colorWithRed:  42.0f/255.0f green: 27.0f/255.0f blue: 29.0f/255.0f    alpha:1.0];
            break;
        }
        case 7:
        {
            skinColor = [UIColor colorWithRed: 216.0f/255.0f green: 155.0f/255.0f blue: 118.0f/255.0f    alpha:1.0];
            lipColor = [UIColor colorWithRed: 196.0f/255.0f green: 125.0f/255.0f blue: 107.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 56.0f/255.0f  green: 33.0f/255.0f  blue: 19.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 47.0f/255.0f  green: 27.0f/255.0f  blue: 21.0f/255.0f  alpha:1.0];

            break;
        }
        case 8:
        {
            skinColor = [UIColor colorWithRed: 213.0f/255.0f green: 153.0f/255.0f blue: 115.0f/255.0f    alpha:1.0];
            lipColor = [UIColor colorWithRed: 200.0f/255.0f  green: 121.0f/255.0f  blue: 97.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 12.0f/255.0f  green: 8.0f/255.0f  blue: 7.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 62.0f/255.0f  green: 33.0f/255.0f  blue: 25.0f/255.0f  alpha:1.0];

            break;
        }
        // clay 1-2
        case 9:
        {
            skinColor = [UIColor colorWithRed: 209.0f/255.0f  green: 145.0f/255.0f  blue: 102.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 192.0f/255.0f  green: 122.0f/255.0f  blue: 84.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 26.0f/255.0f  green: 17.0f/255.0f  blue: 12.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 53.0f/255.0f  green: 35.0f/255.0f  blue: 23.0f/255.0f  alpha:1.0];
            break;
        }
        case 10:
        {
            skinColor = [UIColor colorWithRed: 218.0f/255.0f  green: 150.0f/255.0f  blue: 99.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 204.0f/255.0f  green: 119.0f/255.0f  blue: 91.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 42.0f/255.0f  green: 31.0f/255.0f  blue: 26.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 40.0f/255.0f  green: 21.0f/255.0f  blue: 15.0f/255.0f  alpha:1.0];
            break;
        }
        case 11:
        {
            skinColor = [UIColor colorWithRed: 214.0f/255.0f  green: 160.0f/255.0f  blue: 123.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 186.0f/255.0f  green: 103.0f/255.0f  blue: 85.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 20.0f/255.0f  green: 14.0f/255.0f  blue: 12.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 39.0f/255.0f  green: 23.0f/255.0f  blue: 19.0f/255.0f  alpha:1.0];
            break;
        }
        // clay 2-3
        case 12:
        {
            skinColor = [UIColor colorWithRed: 195.0f/255.0f  green: 127.0f/255.0f  blue: 81.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 175.0f/255.0f  green: 115.0f/255.0f  blue: 88.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 16.0f/255.0f  green: 9.0f/255.0f  blue: 4.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 23.0f/255.0f  green: 7.0f/255.0f  blue: 2.0f/255.0f  alpha:1.0];
            break;
        }
        case 13:
        {
            skinColor = [UIColor colorWithRed: 191.0f/255.0f  green: 119.0f/255.0f  blue: 72.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 171.0f/255.0f  green: 99.0f/255.0f  blue: 79.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 14.0f/255.0f  green: 5.0f/255.0f  blue: 4.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 47.0f/255.0f  green: 26.0f/255.0f  blue: 19.0f/255.0f  alpha:1.0];
            break;
        }
        case 14:
        {
            skinColor = [UIColor colorWithRed: 213.0f/255.0f  green: 142.0f/255.0f  blue: 91.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 191.0f/255.0f  green: 114.0f/255.0f  blue: 82.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 8.0f/255.0f  green: 4.0f/255.0f  blue: 4.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 41.0f/255.0f  green: 23.0f/255.0f  blue: 18.0f/255.0f  alpha:1.0];
            break;
        }
        // clay 3-4 
        case 15:
        {
            skinColor = [UIColor colorWithRed: 176.0f/255.0f  green: 110.0f/255.0f  blue: 63.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 148.0f/255.0f  green: 88.0f/255.0f  blue: 75.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 40.0f/255.0f  green: 26.0f/255.0f  blue: 24.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 62.0f/255.0f  green: 42.0f/255.0f  blue: 36.0f/255.0f  alpha:1.0];
            break;
        }
        case 16:
        {
            skinColor = [UIColor colorWithRed: 195.0f/255.0f  green: 131.0f/255.0f  blue: 86.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 170.0f/255.0f  green: 105.0f/255.0f  blue: 81.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 7.0f/255.0f  green: 4.0f/255.0f  blue: 4.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 44.0f/255.0f  green: 29.0f/255.0f  blue: 23.0f/255.0f  alpha:1.0];
            break;
        }
        case 17:
        {
            skinColor = [UIColor colorWithRed: 196.0f/255.0f  green: 136.0f/255.0f  blue: 92.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 171.0f/255.0f  green: 100.0f/255.0f  blue: 71.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 26.0f/255.0f  green: 19.0f/255.0f  blue: 16.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 38.0f/255.0f  green: 24.0f/255.0f  blue: 17.0f/255.0f  alpha:1.0];
            break;
        }
        // clay 5 earth 1
        case 18:
        {
            skinColor = [UIColor colorWithRed: 176.0f/255.0f  green: 111.0f/255.0f  blue: 66.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 148.0f/255.0f  green: 84.0f/255.0f  blue: 51.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 20.0f/255.0f  green: 11.0f/255.0f  blue: 8.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 32.0f/255.0f  green: 18.0f/255.0f  blue: 14.0f/255.0f  alpha:1.0];
            break;
        }
        case 19:
        {
            skinColor = [UIColor colorWithRed: 179.0f/255.0f  green: 120.0f/255.0f  blue: 79.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 165.0f/255.0f  green: 102.0f/255.0f  blue: 76.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 7.0f/255.0f  green: 5.0f/255.0f  blue: 4.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 23.0f/255.0f  green: 15.0f/255.0f  blue: 13.0f/255.0f  alpha:1.0];
            break;
        }
        case 20:
        {
            skinColor = [UIColor colorWithRed: 176.0f/255.0f  green: 109.0f/255.0f  blue: 65.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 168.0f/255.0f  green: 98.0f/255.0f  blue: 73.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 11.0f/255.0f  green: 7.0f/255.0f  blue: 7.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 33.0f/255.0f  green: 18.0f/255.0f  blue: 14.0f/255.0f  alpha:1.0];
            break;
        }
        // earth 1-2
        case 21:
        {
            skinColor = [UIColor colorWithRed: 179.0f/255.0f  green: 113.0f/255.0f  blue: 68.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 174.0f/255.0f  green: 103.0f/255.0f  blue: 67.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 119.0f/255.0f  green: 72.0f/255.0f  blue: 41.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 31.0f/255.0f  green: 20.0f/255.0f  blue: 18.0f/255.0f  alpha:1.0];
            break;
        }
        case 22:
        {
            skinColor = [UIColor colorWithRed: 186.0f/255.0f  green: 115.0f/255.0f  blue: 66.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 163.0f/255.0f  green: 83.0f/255.0f  blue: 64.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 14.0f/255.0f  green: 9.0f/255.0f  blue: 8.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 55.0f/255.0f  green: 30.0f/255.0f  blue: 21.0f/255.0f  alpha:1.0];
            break;
        }
        case 23:
        {
            skinColor = [UIColor colorWithRed: 170.0f/255.0f  green: 97.0f/255.0f  blue: 53.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 170.0f/255.0f  green: 88.0f/255.0f  blue: 66.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 19.0f/255.0f  green: 13.0f/255.0f  blue: 11.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 21.0f/255.0f  green: 9.0f/255.0f  blue: 6.0f/255.0f  alpha:1.0];
            break;
        }
        // earth 2-3
        case 24:
        {
            skinColor = [UIColor colorWithRed: 163.0f/255.0f  green: 101.0f/255.0f  blue: 59.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 161.0f/255.0f  green: 99.0f/255.0f  blue: 67.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 20.0f/255.0f  green: 10.0f/255.0f  blue: 8.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 34.0f/255.0f  green: 18.0f/255.0f  blue: 13.0f/255.0f  alpha:1.0];
            break;
        }
        case 25:
        {
            skinColor = [UIColor colorWithRed: 161.0f/255.0f  green: 103.0f/255.0f  blue: 61.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 158.0f/255.0f  green: 89.0f/255.0f  blue: 59.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 12.0f/255.0f  green: 10.0f/255.0f  blue: 9.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 30.0f/255.0f  green: 17.0f/255.0f  blue: 14.0f/255.0f  alpha:1.0];
            break;
        }
        case 26:
        {
            skinColor = [UIColor colorWithRed: 163.0f/255.0f  green: 102.0f/255.0f  blue: 59.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 132.0f/255.0f  green: 83.0f/255.0f  blue: 62.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 14.0f/255.0f  green: 12.0f/255.0f  blue: 10.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 35.0f/255.0f  green: 22.0f/255.0f  blue: 16.0f/255.0f  alpha:1.0];
            break;
        }
        // earth 3-4
        case 27:
        {
            skinColor = [UIColor colorWithRed: 134.0f/255.0f  green: 79.0f/255.0f  blue: 46.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 111.0f/255.0f  green: 66.0f/255.0f  blue: 48.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 13.0f/255.0f  green: 4.0f/255.0f  blue: 2.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 2.0f/255.0f  green: 1.0f/255.0f  blue: 3.0f/255.0f  alpha:1.0];
            break;
        }
        case 28:
        {
            skinColor = [UIColor colorWithRed: 127.0f/255.0f  green: 72.0f/255.0f  blue: 44.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 159.0f/255.0f  green: 87.0f/255.0f  blue: 63.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 7.0f/255.0f  green: 7.0f/255.0f  blue: 6.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 6.0f/255.0f  green: 5.0f/255.0f  blue: 4.0f/255.0f  alpha:1.0];
            break;
        }
        case 29:
        {
            skinColor = [UIColor colorWithRed: 150.0f/255.0f  green: 96.0f/255.0f  blue: 69.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 157.0f/255.0f  green: 93.0f/255.0f  blue: 64.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 9.0f/255.0f  green: 4.0f/255.0f  blue: 3.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 31.0f/255.0f  green: 18.0f/255.0f  blue: 14.0f/255.0f  alpha:1.0];
            break;
        }
        // earth 4-5
        case 30:
        {
            skinColor = [UIColor colorWithRed: 139.0f/255.0f  green: 86.0f/255.0f  blue: 52.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 131.0f/255.0f  green: 78.0f/255.0f  blue: 50.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 6.0f/255.0f  green: 1.0f/255.0f  blue: 1.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 21.0f/255.0f  green: 9.0f/255.0f  blue: 6.0f/255.0f  alpha:1.0];
            break;
        }
        case 31:
        {
            skinColor = [UIColor colorWithRed: 132.0f/255.0f  green: 82.0f/255.0f  blue: 58.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 151.0f/255.0f  green: 101.0f/255.0f  blue: 83.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 20.0f/255.0f  green: 17.0f/255.0f  blue: 16.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 38.0f/255.0f  green: 24.0f/255.0f  blue: 20.0f/255.0f  alpha:1.0];
            break;
        }
        case 32:
        {
            skinColor = [UIColor colorWithRed: 92.0f/255.0f  green: 55.0f/255.0f  blue: 32.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 132.0f/255.0f  green: 87.0f/255.0f  blue: 69.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 18.0f/255.0f  green: 15.0f/255.0f  blue: 12.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 25.0f/255.0f  green: 18.0f/255.0f  blue: 13.0f/255.0f  alpha:1.0];
            break;
        }
        // earth 6-7
        case 33:
        {
            skinColor = [UIColor colorWithRed: 97.0f/255.0f  green: 58.0f/255.0f  blue: 34.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 99.0f/255.0f  green: 55.0f/255.0f  blue: 35.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 1.0f/255.0f  green: 1.0f/255.0f  blue: 1.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 21.0f/255.0f  green: 14.0f/255.0f  blue: 10.0f/255.0f  alpha:1.0];
            break;
        }
        case 34:
        {
            skinColor = [UIColor colorWithRed: 76.0f/255.0f  green: 43.0f/255.0f  blue: 28.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 83.0f/255.0f  green: 42.0f/255.0f  blue: 27.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 44.0f/255.0f  green: 26.0f/255.0f  blue: 18.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 57.0f/255.0f  green: 41.0f/255.0f  blue: 33.0f/255.0f  alpha:1.0];
            break;
        }
        case 35:
        {
            skinColor = [UIColor colorWithRed: 95.0f/255.0f  green: 64.0f/255.0f  blue: 53.0f/255.0f  alpha:1.0];
            lipColor = [UIColor colorWithRed: 108.0f/255.0f  green: 65.0f/255.0f  blue: 55.0f/255.0f  alpha:1.0];
            hairColor = [UIColor colorWithRed: 62.0f/255.0f  green: 37.0f/255.0f  blue: 29.0f/255.0f  alpha:1.0];
            eyeColor = [UIColor colorWithRed: 20.0f/255.0f  green: 9.0f/255.0f  blue: 9.0f/255.0f  alpha:1.0];
            break;
        }
        default:
            break;
    }

    NSDictionary *profileColors = [NSDictionary dictionaryWithObjectsAndKeys:
                                   hairColor, @"hairColor",
                                   skinColor, @"skinColor",
                                   eyeColor, @"eyeColor",
                                   lipColor, @"lipColor",
                                   nil];
    
    return profileColors;
}


- (void) updateServerNowWithPhotoPath: (NSString *) photoPath
                    WithProfileColors:(NSDictionary *) profileColors
{
    // To upload the photo & colors to the server and get a response with calculated values...
    NSURL *remoteUrl = [NSURL URLWithString:server];
    NSData *photoImageData = [NSData dataWithContentsOfFile:photoPath];
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[ColorUtility hexadecimalValueOfAUIColor:[profileColors objectForKey:@"hairColor"] ] forKey:@"hair"];
     [parameters setObject:[ColorUtility hexadecimalValueOfAUIColor:[profileColors objectForKey:@"eyeColor"] ] forKey:@"eyes"];
     [parameters setObject:[ColorUtility hexadecimalValueOfAUIColor:[profileColors objectForKey:@"skinColor"] ] forKey:@"skin"];
     [parameters setObject:[ColorUtility hexadecimalValueOfAUIColor:[profileColors objectForKey:@"lipColor"] ] forKey:@"lips"];
    
    NSLog(@" param = %@",parameters);
    
    // creating http client...
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:remoteUrl];
    NSMutableURLRequest *afRequest = [httpClient
                                      multipartFormRequestWithMethod:@"POST"
                                      path: pathToAPICAllForUploadingProfileImage
                                      parameters:parameters
                                      constructingBodyWithBlock:
                                      ^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:photoImageData
                                                                      name:@"u_photo"
                                                                  fileName:nil
                                                                  mimeType:@"image/JPG"];
                                          
                                      }];
    
    // if the server call is successful...
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:afRequest];
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON)
     {
         BOOL success=[[JSON objectForKey:@"success"] boolValue];
         if (success)
         {
             // To clear color correct data...
             CMApplicationModel *applicationModel = [[CMApplicationModel alloc] init];
             [applicationModel clearColorCorrectedData];
             
             // To update user model...
             CMUserModel *userModel = [[CMUserModel alloc]initForUserProfile];
             [userModel updateUserProfileDataWithJSONForUploadsImport:JSON];
             // LogInfo(@"Successfully updated user image. JSON: %@", JSON);
             
             // To print color data...
             CMUserProfileMap *userData = userModel.getUserProfileMapObject;
             NSString *skinColorComponents = [ColorUtility rgbValueOFUIColor: userData.skinColor];
             NSString *lipsColorComponents = [ColorUtility rgbValueOFUIColor: userData.lipsColor];
             NSString *hairColorComponents = [ColorUtility rgbValueOFUIColor: userData.hairColor];
             NSString *eyesColorComponents = [ColorUtility rgbValueOFUIColor: userData.eyesColor];
             
             NSLog(@"Colors: \nSkin: %@\nLip: %@ , \nHair: %@ , \nEye: %@",
                   skinColorComponents,
                   lipsColorComponents,
                   hairColorComponents,
                   eyesColorComponents);
             
             // To redirect to MyProfileVC...
             [self performSegueWithIdentifier:@"goMyProfile" sender:self];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:@"Some error occur could you please try again later."];
             LogError(@"There was an error uploading user image. JSON: %@", JSON);
         }
         
         [SVProgressHUD dismiss];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LogError(@"operaton:%@, error: %@", operation, error);
         [SVProgressHUD showErrorWithStatus:@"It appears you have lost internet connectivity. Please check your network settings."];
     }
     ];
    [operation start];
}


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
