//
//  CMProductDetailsViewController.m
//  ColorModulesBeautyApp
//
//  Created by Nicky Liu on 2/14/12.

//Revision history:
//March 22 - Add swipe function, click two arrows to switch products and rising up detail view
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMProductDetailsViewController.h"
#import "CMProductWebViewController.h"
#import "CMProductMap.h"
#import "SA_OAuthTwitterEngine.h"
#import "UIImageView+WebCache.h"
#import "CMUserModel.h"
#import "CMConstants.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "Logging.h"
#import "CMProductsServerCallSetup.h"
#import "FacebookShareDialog.h"
#import "FacebookSDK/FacebookSDK.h"
#import "UIImageView+AFNetworking.h"
#import "CMCustomTheme.h"
#import "ShareFunctionalityView.h"
#import "SVProgressHUD.h"
#import "CMApplicationModel.h"

// TO DO:  COMMENT THE FOLLOWING LINE BEFORE RELEASE
//#define BETATESTING 1


@interface CMProductDetailsViewController()


@property (weak, nonatomic) IBOutlet UILabel *indexSummary;
@property (weak, nonatomic) IBOutlet UIButton *buttonLeftArrow;
@property (weak, nonatomic) IBOutlet UIButton *buttonRightArrow;
@property (weak, nonatomic) IBOutlet UIImageView *imageOfProduct;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (strong, nonatomic) IBOutlet UIView *viewColorSwatch;
@property (weak, nonatomic) IBOutlet UILabel *labelWhyThisProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelProductColor;
@property (weak, nonatomic) IBOutlet UILabel *labelProductPrice;
@property (weak, nonatomic) IBOutlet UIButton *save_button;


@property (retain,nonatomic) UIView *detailView;
@property (retain,nonatomic) UILabel *detailViewTitle;
@property (retain,nonatomic) UILabel *detailViewPrice;
@property (retain,nonatomic) UIButton *detailViewBuyNowButton;
@property (retain,nonatomic) UILabel *detailViewSellerName;
@property (retain,nonatomic) IBOutlet UITextView *detailViewDescriptionTextView;
@property (retain,nonatomic) UIView *shareView;

@property (nonatomic, strong) CMUserModel *userModel;

@property int current_index;
@property int screenWidth;
@property int screenHeight;
@property int subViewHeight;
@property int subViewY;

@property (strong, nonatomic) IBOutlet UIView *pView;
@property (weak, nonatomic) IBOutlet UIImageView *pImageView;

@end

@implementation CMProductDetailsViewController
@synthesize shareView = _shareView;
@synthesize detailViewDescriptionTextView = _detailViewDescriptionTextView;
@synthesize detailViewSellerName = _detailViewSellerName;
@synthesize detailViewTitle = _detailViewTitle;
@synthesize detailView = _detailView;
@synthesize detailViewPrice = _detailViewPrice;
@synthesize detailViewBuyNowButton = _detailViewBuyNowButton;
@synthesize imageOfProduct = _imageOfProduct;
@synthesize labelProductColor = _labelProductColor;
@synthesize labelProductPrice = _labelProductPrice;
@synthesize product_list = _product_list;
@synthesize starting_index = _starting_index;
@synthesize save_button = _save_button;
@synthesize indexSummary = _indexSummary;
@synthesize productTitle = _productTitle;
@synthesize current_index=_current_index;
@synthesize labelWhyThisProduct = _labelWhyThisProduct;
@synthesize currentProductCategory = _currentProductCategory;
@synthesize viewColorSwatch = _viewColorSwatch;
@synthesize buttonLeftArrow = _buttonLeftArrow;
@synthesize buttonRightArrow = _buttonRightArrow;
@synthesize screenWidth = _screenWidth;
@synthesize screenHeight = _screenHeight;
@synthesize userModel = _userModel;
@synthesize pView = _pView;
@synthesize pImageView = _pImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.current_index = self.starting_index;
    [self setupProductContent];
    self.pView.hidden=YES;
}

- (void)setupProductContent{
    
    // To get user's data from the model...
    self.userModel = [[CMUserModel alloc] initForUserProfile];
    
    //get the displayed product
    CMProductMap *product = [self.product_list objectAtIndex:self.current_index];
    
    // to display the product image...
    [self.imageOfProduct setImageWithURL:product.imageURL placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMG]];
    self.indexSummary.text = [NSString stringWithFormat:@"%i/%d",self.current_index+1,self.product_list.count];
    
    //display brand name on navigation title.
    self.title = product.brandName;
    
    // Setting swatch colors and name...
    CGFloat backgroundRed, backgroundGreen, backgroundBlue;
    [product.color getRed:&backgroundRed green:&backgroundGreen blue:&backgroundBlue alpha:nil];
    //R*0.299 + G*0.587 + B*0.114 -- light is higher than 0.5
    CGFloat colorGray = (backgroundRed*0.299) + (backgroundGreen*0.587) + (backgroundBlue*0.144);
    
    if(colorGray > 0.45f)
    {
        [self.labelProductColor setTextColor: [UIColor blackColor]];
    }
    else
    {
        [self.labelProductColor setTextColor: [UIColor whiteColor]];
    }
    
    self.labelProductColor.text = product.colorName;
    self.viewColorSwatch.backgroundColor = product.color;
    
    //set price
    self.labelProductPrice.text = [NSString stringWithFormat:@"$%0.02f",product.price];
    
    //set description
    self.detailViewDescriptionTextView.text = product.description;
    
    
    // To hide the arrows and index if only one product.
    if(self.product_list.count == 1)
    {
        [self.buttonLeftArrow setHidden:YES];
        [self.buttonRightArrow setHidden:YES];
        [self.indexSummary setHidden:YES];
    }
    
    [self adjustWishlistButton];
    [self checkForMatch];
    
    
}

- (void)isMatchContent{
    
    CMProductMap *product = [self.product_list objectAtIndex:self.current_index];
    
    //set product title
    NSString *titleString = [product.title stringByReplacingOccurrencesOfString:product.colorName withString:@""];
    titleString = [[titleString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    
    NSLog(@"product.title: %@ \ntitleString: %@ and \nproduct.colorName: %@, ", product.title, titleString, product.colorName);
    
    [self.labelWhyThisProduct setTextColor: [UIColor blackColor]];
    
    if(self.labelWhyThisProduct.text.length == 0) {
        [self.detailViewDescriptionTextView setHidden:NO];
        [self.labelWhyThisProduct setHidden:YES];
        self.productTitle.text = titleString;
        
    }
    else
    {
        [self.detailViewDescriptionTextView setHidden:YES];
        [self.labelWhyThisProduct setHidden:NO];
        self.productTitle.text = [NSString stringWithFormat:@"%@",titleString];
        
    }
    
    
    [SVProgressHUD dismiss];
    
}


- (IBAction)shareButtonPressed
{
    NSArray *productArray = [NSArray arrayWithObjects:
                             [self.product_list objectAtIndex:self.current_index],
                             nil];
    
    [self.view addSubview:[[ShareFunctionalityView alloc]
                           initWithProductArray:productArray
                           WithSuperViewController:self
                           WithViewPosition:VIEW_LOCATION_TOP]];
}


- (IBAction)pushWishlist:(UISwipeGestureRecognizer *)sender
{
    //This is the current product to save or unsave.
    CMProductMap *product = [self.product_list objectAtIndex:self.current_index];
    
    // if the product is not saved yet, then save the product.
    if([CMApplicationModel isWishlistItem:product])
    {
        // To remove the product from wishlist locally...
        [CMApplicationModel removeProductFromWishlist:product];
        product.isWishlist = NO;
        [self adjustWishlistButton];
        [SVProgressHUD showSuccessWithStatus:REMOVE_FROM_WISHLIST];
    }
    else
    {
        // To save the product locally first...
        [CMApplicationModel addProductToWishlist:product];
        [self adjustWishlistButton];
        [SVProgressHUD showSuccessWithStatus:ADDED_TO_WISHLIST];
    }
}


- (IBAction)pushBuy:(id)sender
{
    [self performSegueWithIdentifier:@"goWebsite" sender:self];
}

-(void)buy_now_btn_pressed:(id) sender {
    [self performSegueWithIdentifier:@"goWebsite" sender:self];
}

- (IBAction)swipeLeft:(id)sender {
    [self pushLeftArrow:sender];
}

- (IBAction)swipeRight:(id)sender {
    [self pushRightArrow:sender];
}

- (IBAction)pushLeftArrow:(id)sender {
    [self displayNextLeft];
}

- (IBAction)pushRightArrow:(id)sender {
    [self displayNextRight];
}

- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

/*********************************************************************************************************************
 Supporting Functions...
 *********************************************************************************************************************/

-(void) checkForMatch
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    CMProductMap *product = [self.product_list objectAtIndex:self.current_index];
    NSLog(@"original match product: %@", product.matchMessage);
    
    if(product.matchMessage.class != [NSNull null])
    {
        self.labelWhyThisProduct.text = product.matchMessage;
        [self isMatchContent];
    }
    else
    {
        [SVProgressHUD showWithStatus:STR_LOADING];
        int pt_id = [product.typeID integerValue];
        int look_id = 0;
        if(pt_id == 1)
        {
            look_id = 25;
        }
        if(pt_id == 3)
        {
            look_id = 36;
        }
        
        CMUserProfileMap *userData = [self.userModel getUserProfileMapObject];
        
        [params setValue:userData.profileID forKey:@"profile_id"];
        [params setValue:product.productID forKey:@"product_id"];
        [params setValue:userData.skinColor forKey:@"skin"];
        [params setValue:userData.eyesColor forKey:@"eyes"];
        [params setValue:userData.hairColor forKey:@"hair"];
        [params setValue:userData.lipsColor forKey:@"lips"];
        [params setValue:@"10" forKey:@"variance"];
        [params setValue:product.typeID forKey:@"pt_id"];
        [params setValue:[NSString stringWithFormat:@"%d",look_id] forKey:@"look_id"];
        
        if(pt_id == 2)
        {
            [params setValue:@"" forKey:@"look_id"];
        }
        
        NSURL *url = [NSURL URLWithString:server];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        
        NSMutableURLRequest *request = [httpClient
                                        requestWithMethod:@"POST"
                                        path:pathToAPICallForCheckingIfProductMatch
                                        parameters:params];
        
        [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
        
        AFJSONRequestOperation *operation =
        [AFJSONRequestOperation
         JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             BOOL success=[[JSON objectForKey:@"success"] boolValue];
             if (success)
             {
                 BOOL match = [[[JSON objectForKey:@"data"] objectForKey:@"match"] boolValue];
                 if(match)
                 {
                     self.labelWhyThisProduct.text = [[JSON objectForKey:@"data"] objectForKey:@"match_message"];
                     [self isMatchContent];
                 }
                 else
                 {
                     self.labelWhyThisProduct.text = @"";
                     [self isMatchContent];
                 }
             }
             else
             {
                 LogError(@"Error:%@", JSON);
             }
             [SVProgressHUD dismiss];
         }
         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
             LogError(@"Error:%@", JSON);
             [SVProgressHUD dismiss];
         }];
        [operation start];
    }
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goWebsite"]) {
        CMProductWebViewController *productWebViewController=(CMProductWebViewController *)[segue destinationViewController];
        [productWebViewController setProduct:[self.product_list objectAtIndex:self.current_index]];
    }
}


-(void) displayNextLeft
{
    if (self.current_index == 0)
    {
        self.current_index = self.product_list.count - 1;
    }
    else
    {
        self.current_index = self.current_index - 1;
    }
    
    [self setupProductContent];
    
    // updating the index
    self.indexSummary.text = [NSString stringWithFormat:@"%i/%d",self.current_index+1,self.product_list.count];
    
}

-(void) displayNextRight
{
    
    if (self.current_index < self.product_list.count-1)
    {
        self.current_index = self.current_index + 1;
    }
    else
    {
        self.current_index = 0;
    }
    
    [self setupProductContent];
    
    // updating the index
    self.indexSummary.text=[NSString stringWithFormat:@"%i/%d",self.current_index+1,self.product_list.count];
}

/*
 p functionality
 */

- (IBAction)pViewCloseButtonPressed {
    self.pView.hidden=YES;
}

- (IBAction)pViewButtonPressed:(UIButton *)sender {
    
    self.pView.hidden=NO;
    
    CMProductMap *product = [self.product_list objectAtIndex:self.current_index];
    
    [self.pImageView setImageWithURL:product.imageURL placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMG]];
    
    if(product.matchMessage.length != 0) {
        self.labelWhyThisProduct.text=product.matchMessage;
    }
}

-(void) adjustWishlistButton
{
    //Check if the item is in saved list. If yes, disable the save button.
    CMProductMap *product = [self.product_list objectAtIndex:self.current_index];
    
    if ([CMApplicationModel isWishlistItem:product])
    {
        [self.save_button setImage:[UIImage imageNamed: @"HeartIcon_Pressed.png"] forState:UIControlStateNormal];
        self.save_button.enabled=YES;
    }
    else
    {
        [self.save_button setImage:[UIImage imageNamed: @"HeartIcon.png"] forState:UIControlStateNormal];
        self.save_button.enabled=YES;
    }
}

- (void) showAlertWithTitle: (NSString *) title
                WithMessage: (NSString *) message
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)viewDidUnload
{
    [self setImageOfProduct:nil];
    [self setLabelProductColor:nil];
    [self setLabelProductPrice:nil];
    [self setSave_button:nil];
    [self setIndexSummary:nil];
    [self setProductTitle:nil];
    [self setLabelWhyThisProduct:nil];
    [self setViewColorSwatch:nil];
    [self setButtonLeftArrow:nil];
    [self setButtonRightArrow:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
