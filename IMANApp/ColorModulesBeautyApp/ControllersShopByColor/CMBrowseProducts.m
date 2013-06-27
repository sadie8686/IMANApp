//
//  CMShopByColorViewController.m
//  ColorModulesBeautyApp
//
//  Created by Nicky Liu on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMBrowseProducts.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMConstants.h"
#import "BrowseProductsCell.h"
#import "CMProductMap.h"
#import "CMProductModel.h"
#import "CMProductDetailsViewController.h"
#import "CMUserModel.h"
#import "Logging.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "ProductBoxView.h"
#import "CMCustomTheme.h"

#define NUMBER_OF_CONTAINERS_IN_ROW 2

@interface CMBrowseProducts ()
@property (strong,nonatomic) NSArray *productsArray;
@property int selectedProductIndex;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSString *currentProductTypeID;
@property (strong, nonatomic) IBOutlet UILabel *scrollSeperator;
@property (nonatomic) BOOL limitProductsToOne;
@end



@implementation CMBrowseProducts

@synthesize tableView = _shopByColorTable;
@synthesize Lips = _Lips;
@synthesize Eyes = _Eyes;
@synthesize Face = _Face;
@synthesize productsArray = _productsArray;
@synthesize selectedProductIndex = _selectedProductIndex;

#pragma mark-
#pragma mark LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    [self clickLips:self];
    [self.tableView setHidden:YES];
    self.limitProductsToOne = NO;
}

#pragma mark-
#pragma mark ADDING SUBVIEWS
-(void) createSubCategoryFor: (NSString *) productTypeID
{
    for(UIView *thisView in self.scrollView.subviews)
    {
        if([thisView isKindOfClass:[UIButton class]])
        {
            UIButton *thisButton = (UIButton *) thisView;
            [thisButton removeFromSuperview];
        }
    }
    
    NSArray *lipsSubCategories = [CMConstants getLipSubCategoryOrderedKeys];
    NSArray *eyesSubCategories = [CMConstants getEyeSubCategoryOrderedKeys];
    NSArray *faceSubCategories = [CMConstants getFaceSubCategoryOrderedKeys];
    
    int x = 0, y = 0, width = 0, height = 35, previousWidth=0, previousX = 0;
    UIFont *font = [UIFont fontWithName:[CMCustomTheme getFontNameForBold:NO] size:13.0];
    
    if ([productTypeID isEqualToString:productTypeIdForLips])
    {
        for(NSString *key in lipsSubCategories)
        {
            x = previousX + previousWidth;
            CGSize stringsize = [key sizeWithFont:font];
            width = stringsize.width + 15;
            if(width < 60)
                width = 60;
            
            UIButton *subcatButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
            [subcatButton.titleLabel setFont:font];
            [subcatButton setTitle:key forState:UIControlStateNormal];
            [subcatButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [subcatButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [subcatButton addTarget:self action:@selector(subcatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            if ([key isEqualToString:@"all"])
            {
                [subcatButton setSelected:YES];
            }
            [self.scrollView addSubview:subcatButton];
            
            // for next button...
            previousWidth = subcatButton.frame.size.width;
            previousX = subcatButton.frame.origin.x;
        }
    }
    
    
    if ([productTypeID isEqualToString:productTypeIdForEyes])
    {
        for(NSString *key in eyesSubCategories)
        {
            x = previousX + previousWidth;
            CGSize stringsize = [key sizeWithFont:font];
            width = stringsize.width + 15;
            if(width < 60)
                width = 60;
            
            UIButton *subcatButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
            [subcatButton.titleLabel setFont:font];
            [subcatButton setTitle:key forState:UIControlStateNormal];
            [subcatButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [subcatButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [subcatButton addTarget:self action:@selector(subcatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([key isEqualToString:@"all"])
            {
                [subcatButton setSelected:YES];
            }
            
            [self.scrollView addSubview:subcatButton];
            
            // for next button...
            previousWidth = subcatButton.frame.size.width;
            previousX = subcatButton.frame.origin.x;
        }
    }
    
    
    if ([productTypeID isEqualToString:productTypeIdForFace])
    {
        for(NSString *key in faceSubCategories)
        {
            x = previousX + previousWidth;
            CGSize stringsize = [key sizeWithFont:font];
            width = stringsize.width + 15;
            if(width < 60)
                width = 60;
            
            UIButton *subcatButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
            [subcatButton.titleLabel setFont:font];
            [subcatButton setTitle:key forState:UIControlStateNormal];
            [subcatButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [subcatButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [subcatButton addTarget:self action:@selector(subcatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            if ([key isEqualToString:@"all"])
            {
                [subcatButton setSelected:YES];
            }
            [self.scrollView addSubview:subcatButton];
            
            // for next button...
            previousWidth = subcatButton.frame.size.width;
            previousX = subcatButton.frame.origin.x;
        }
    }
    
    
    [self.scrollView setContentSize:CGSizeMake(previousX+previousWidth, height)];
    [self.scrollSeperator setFrame:CGRectMake(self.scrollSeperator.frame.origin.x,
                                              self.scrollSeperator.frame.origin.y,
                                              previousX+previousWidth,
                                              self.scrollSeperator.frame.size.height)];
    [self.scrollView setNeedsDisplay];
    [self.scrollView reloadInputViews];
}

- (void) configureView
{
    //register color
    //UIColor *highlightColor = [UIColor colorWithRed:132/255.0f green:20/255.0f blue:60/255.0f alpha:1.0f];
    UIColor *highlightColor = [UIColor blackColor];
    UIColor *normalColor = [UIColor grayColor];
    
    [self.Lips setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.Lips setTitleColor:normalColor forState:UIControlStateNormal];
    [self.Lips.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:16.0]];
    [self.Lips setSelected:YES];
    
    [self.Eyes setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.Eyes setTitleColor:normalColor forState:UIControlStateNormal];
    [self.Eyes setSelected:NO];
    
    [self.Face setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.Face setTitleColor:normalColor forState:UIControlStateNormal];
    [self.Face setSelected:NO];
}


#pragma mark-
#pragma mark BUTTON CLICKS
- (IBAction)clickLips:(id)sender
{
    // To set the button selected...
    [self.Lips setSelected:YES];
    [self.Eyes setSelected:NO];
    [self.Face setSelected:NO];
    
    // To get sub categories...
    [self createSubCategoryFor:productTypeIdForLips];
    
    // To press "ALL" button...
    self.currentProductTypeID = productTypeIdForLips;
    UIButton *dummyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dummyButton setTitle:@"all" forState:UIControlStateNormal];
    [self subcatButtonPressed:dummyButton];
    
}

- (IBAction)clickEyes:(id)sender
{
    // To set the button selected...
    [self.Eyes setSelected:YES];
    [self.Lips setSelected:NO];
    [self.Face setSelected:NO];
    
    // To get sub categories...
    [self createSubCategoryFor:productTypeIdForEyes];
    
    // To press "ALL" button...
    self.currentProductTypeID = productTypeIdForEyes;
    UIButton *dummyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dummyButton setTitle:@"all" forState:UIControlStateNormal];
    [self subcatButtonPressed:dummyButton];
}

- (IBAction)clickFace:(id)sender
{
    //set default to all products
    [self.Face setSelected:YES];
    [self.Lips setSelected:NO];
    [self.Eyes setSelected:NO];
    
    // To get sub categories...
    [self createSubCategoryFor:productTypeIdForFace];
    
    // To press "ALL" button...
    self.currentProductTypeID = productTypeIdForFace;
    UIButton *dummyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dummyButton setTitle:@"all" forState:UIControlStateNormal];
    [self subcatButtonPressed:dummyButton];
    
    /*
     [self.Lips.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
     [self.Eyes.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
     [self.Face.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:16.0]];
     */
}


-(void) subcatButtonPressed: (UIButton *) selectedButton
{
    for(UIView *thisView in self.scrollView.subviews)
    {
        if([thisView isKindOfClass:[UIButton class]])
        {
            UIButton *thisButton = (UIButton *) thisView;
            [thisButton setSelected:NO];
            
            if([thisButton.titleLabel.text isEqualToString:selectedButton.titleLabel.text])
            {
                [thisButton setSelected:YES];
            }
        }
    }
    
    NSString *key = selectedButton.titleLabel.text;
    NSDictionary *lipsSubCategories = [CMConstants getLipSubCategories];
    NSDictionary *eyesSubCategories = [CMConstants getEyeSubCategories];
    NSDictionary *faceSubCategories = [CMConstants getFaceSubCategories];
    NSString *subcatID;
    
    if([lipsSubCategories objectForKey:key])
    {
        subcatID = [lipsSubCategories objectForKey:key];
    }
    
    else if ([eyesSubCategories objectForKey:key])
    {
        subcatID = [eyesSubCategories objectForKey:key];
    }
    else if ([faceSubCategories objectForKey:key])
    {
        subcatID = [faceSubCategories objectForKey:key];
        
        NSLog(@"SubCat: %@", key);
        
        if ([key isEqualToString:@"BB CREME"])
        {
            self.limitProductsToOne = YES;
        }
    }
    
    [self getProductsFromServerForSubcategory: subcatID];
}


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark-
#pragma mark TABLE VIEW METHODS
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // To create the cell...
    static NSString *CellIdentifier=@"shopColor";
    BrowseProductsCell *cell = (BrowseProductsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BrowseProductsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    CMProductMap *thisProduct = [self.productsArray objectAtIndex:indexPath.row];
    ProductBoxView *productBoxView = [[ProductBoxView alloc]
                                      initWithProduct:thisProduct
                                      withPosx:cell.viewContainerCell1.frame.origin.x
                                      withPosy:cell.viewContainerCell1.frame.origin.y
                                      withWidth:cell.viewContainerCell1.frame.size.width
                                      withHeight:cell.viewContainerCell1.frame.size.height
                                      withViewController:self];
    
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [cell setTag:indexPath.row];
    [cell setUserInteractionEnabled:YES];
    [cell addGestureRecognizer:tapGesture];
    [cell.productName setText:thisProduct.title];
    [cell.brandName setText:thisProduct.brandName];
    [cell.ColorName setText:thisProduct.colorName];
    [productBoxView.productBoxButton removeFromSuperview];
    [cell addSubview:productBoxView];
    
    return cell;
}
#pragma mark-



#pragma mark UTILITY METHODS
//Action when a color is selected. Go to product detail page
- (void)tapAction: (UIGestureRecognizer *)gestureRecognizer
{
    self.selectedProductIndex = gestureRecognizer.view.tag;
    [self performSegueWithIdentifier: @"viewProductDetails" sender: self];
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"viewProductDetails"])
    {
        CMProductDetailsViewController *productDetailsViewController = (CMProductDetailsViewController *) [segue destinationViewController];
        productDetailsViewController.product_list = self.productsArray;
        productDetailsViewController.starting_index = self.selectedProductIndex;
        [productDetailsViewController setCurrentProductCategory:nil];
    }
}


-(void) getProductsFromServerForSubcategory: (NSString *) subCategoryID
{
    [SVProgressHUD showWithStatus:STR_LOADING maskType:SVProgressHUDMaskTypeGradient];
    
    // Getting user details...
    CMUserModel *userModel = [[CMUserModel alloc] initForUserProfile];
    NSNumber *profileID = [userModel getUserProfileMapObject].profileID;
    
    // Setting values to parameters...
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setValue:profileID forKey:@"profile_id"];
    [params setValue:self.currentProductTypeID forKey:@"pt_id"];
    [params setValue:SOCKET_SELLER_ID forKey:@"seller_ids"];
    
    // To set the look ids...
    if ([self.currentProductTypeID isEqualToString:productTypeIdForLips])
    {
        NSArray *lookIDs = [NSArray arrayWithObjects:@"25",@"26",@"39", nil];
        [params setObject:lookIDs forKey:@"filter_values"];
    }
    else if ([self.currentProductTypeID isEqualToString:productTypeIdForEyes])
    {
        NSArray *lookIDs = [NSArray arrayWithObjects:@"36",@"37",@"38", nil];
        [params setObject:lookIDs forKey:@"filter_values"];
    }
    else if ([self.currentProductTypeID isEqualToString:productTypeIdForFace])
    {
        NSArray *lookIDs = [NSArray arrayWithObjects:@"40", @"41", @"42", @"43", nil];
        [params setObject:lookIDs forKey:@"filter_values"];
    }
    
    // To set the subcat ids...
    if (![subCategoryID isEqualToString:@"all"]) {
        [params setValue:subCategoryID forKey:@"subcat_ids"];
    }
    
    
    // To create the url to call...
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:server]];
    
    
    NSMutableURLRequest *request = [httpClient
                                    requestWithMethod:@"POST"
                                    path:pathToAPICallForRecommendationEngine
                                    parameters:params];
    
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setHTTPShouldHandleCookies:YES];
    
    if ([self.currentProductTypeID isEqualToString:productTypeIdForLips])
        NSLog(@"Lips Browse Request body: %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    // creating operation...
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         BOOL success=[[JSON objectForKey:@"success"] boolValue];
         if (success)
         {
             
             if ([self.currentProductTypeID isEqualToString:productTypeIdForLips])
             {
                 NSLog(@"Lips Browse JSON: %@", JSON);
             }
             
             
             NSLog(@"Browse Products: got the JSON response.");
             self.productsArray = [CMProductModel getProductsListFromJSON:JSON];
             
             if(self.limitProductsToOne && self.productsArray.count > 0)
             {
                 self.productsArray = [NSArray arrayWithObject:[self.productsArray objectAtIndex:0]];
                 self.limitProductsToOne = NO;
                 NSLog(@"self.productsArray.count: %d", self.productsArray.count);
             }
             if(self.limitProductsToOne)
             {
                 self.limitProductsToOne = NO;
             }
             
             [self.tableView setHidden:NO];
             [self.tableView reloadData];
             [SVProgressHUD dismiss];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:@"Some error occured please try again later."];
             LogError(@"JSON: %@", JSON);
         }
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         LogError(@"error: %i, desc: %@", response.statusCode,response.description);
         [SVProgressHUD showErrorWithStatus:@"It appears you have lost internet connectivity. Please check your network settings."];
     }];
    
    [operation start];
}

#pragma mark-
#pragma UNLOADING

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setLips:nil];
    [self setEyes:nil];
    [self setFace:nil];
    [self setScrollView:nil];
    [self setScrollSeperator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
#pragma mark-



@end


