//
//  CMProductLandingViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/5/13.
//  Modified on 04/22/13.
//

#import "CMProductLandingViewController.h"
#import "CMConstants.h"

#import "CMProductMap.h"
#import "CMUserModel.h"
#import "CMApplicationModel.h"
#import "CMProductModel.h"
#import "CMFilterModel.h"
#import "CMProductsServerCallSetup.h"

#import "CMProductDetailsViewController.h"

#import "CMCustomTheme.h"
#import "SBJson.h"
#import "ColorUtility.h"
#import "UIImageView+WebCache.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "QuartzCore/QuartzCore.h"
#import "ViewEnsembleViewController.h"
#import "Logging.h"
#import "SVProgressHUD.h"

#import "ShareFunctionalityView.h"
#import "CMProductFilterViewController.h"

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define NUMBER_OF_LOOKS 4

#define BLUSH_SIMPLE @"40"
#define BLUSH_GLAM @"41"
#define BLUSH_OFFICE @"42"
#define lookIDForFace @"43"

@interface CMProductLandingViewController()

// Face products...
@property (strong, nonatomic) NSArray *arrayOfFaceProducts;
@property int currentlyDisplayedFaceProductArrayPosition;
@property (strong, nonatomic) NSArray *arrayOfOtherFaceProducts;

// Lip products...
@property (strong,nonatomic) NSArray *arrayOfLipsProducts;
@property int currentlyDisplayedLipProductArrayPosition;
@property (strong, nonatomic) NSArray *arrayOfOtherLipsProducts;

// Eye products...
@property (strong,nonatomic) NSArray *arrayOfEyeProducts;
@property int currentlyDisplayedEyeProductArrayPosition;
@property (strong, nonatomic) NSArray *arrayOfOtherEyeProducts;

// Blush products...
@property (strong,nonatomic) NSArray *arrayOfBlushProducts;
@property int currentlyDisplayedBlushProductArrayPosition;
@property (strong,nonatomic) NSArray *arrayOfOtherBlushProducts;

// view container for ensemble detail, wishlist, share buttons...
@property (strong, nonatomic) IBOutlet UIView *controlBox;
@property (strong, nonatomic) IBOutlet UIButton *wishlistButton;
@property (strong, nonatomic) IBOutlet UIImageView *wishlistImage;

// The profile section
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UIView *hairColorView;
@property (strong, nonatomic) IBOutlet UIImageView *hairColorError;
@property (weak, nonatomic) IBOutlet UIView *faceColorView;
@property (strong, nonatomic) IBOutlet UIImageView *faceColorError;
@property (weak, nonatomic) IBOutlet UIView *eyesColorView;
@property (strong, nonatomic) IBOutlet UIImageView *eyeColorError;
@property (weak, nonatomic) IBOutlet UIView *lipsColorView;
@property (strong, nonatomic) IBOutlet UIImageView *lipsColorError;

// Look Buttons
@property (strong, nonatomic) IBOutlet UIButton *buttonGlam;
@property (strong, nonatomic) IBOutlet UIButton *buttonOffice;
@property (strong, nonatomic) IBOutlet UIButton *buttonEdgy;
@property (strong, nonatomic) IBOutlet UIButton *buttonNaturalLook;
@property (weak, nonatomic) IBOutlet UIButton *buttonSpinLook;

// The background view
@property (weak, nonatomic) IBOutlet UIView *lipsProductContainerView;
@property (weak, nonatomic) IBOutlet UIView *faceProductContainerView;
@property (weak, nonatomic) IBOutlet UIView *eyesProductContainerView;
@property (strong, nonatomic) IBOutlet UIView *blushProductContainerView;

// The product images
@property (weak, nonatomic) IBOutlet UIImageView *lipsProductImage;
@property (weak, nonatomic) IBOutlet UIImageView *faceProductImage;
@property (weak, nonatomic) IBOutlet UIImageView *eyesProductImage;
@property (strong, nonatomic) IBOutlet UIImageView *blushProductImage;

// The swatch
@property (weak, nonatomic) IBOutlet UIView *lipsProductColorSwatchView;
@property (weak, nonatomic) IBOutlet UIView *faceProductColorSwatchView;
@property (weak, nonatomic) IBOutlet UIView *eyesProductColorSwatchView;
@property (strong, nonatomic) IBOutlet UIView *blushProductColorSwatchView;

// p buttons
@property (strong, nonatomic) IBOutlet UIButton *pButtonForLips;
@property (strong, nonatomic) IBOutlet UIButton *pButtonForEyes;
@property (strong, nonatomic) IBOutlet UIButton *pButtonForFace;
@property (strong, nonatomic) IBOutlet UIButton *pButtonForBlush;

// NoProduct Error message views
@property (weak, nonatomic) IBOutlet UILabel *noLipsProductErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *noFaceProductErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *noEyeProductErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *noBlushProductErrorLabel;

// arrow down image
@property (weak, nonatomic) IBOutlet UIImageView *arrowDownImage;

// guide image view
@property (weak, nonatomic) IBOutlet UIView *guideView;

// Other details...
@property (strong,nonatomic) NSNumber *profileID;
@property (nonatomic) int selected_index;
@property (nonatomic) float screenWidth;
@property (nonatomic) float screenHeight;

// scroll
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewOfLooks;
@property (weak, nonatomic) IBOutlet UIView *productContainerView;
@property (strong, nonatomic) UIPageControl *pageControl;

// P function view
@property (weak, nonatomic) IBOutlet UILabel *labelWhyThisProduct;
@property (strong, nonatomic) IBOutlet UIView *pView;
@property (weak, nonatomic) IBOutlet UIImageView *pImageView;

// Color signature text label
@property (weak, nonatomic) IBOutlet UILabel *hairColorSignatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *eyeColorSignatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *lipColorSignatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *skinColorSignatureLabel;

// Blush...
@property (strong, nonatomic) NSString *currentBlushLookID;

@end



@implementation CMProductLandingViewController
@synthesize arrayOfFaceProducts = _arrayOfFaceProducts;
@synthesize currentlyDisplayedFaceProductArrayPosition = _currentlyDisplayedFaceProductArrayPosition;
@synthesize arrayOfOtherFaceProducts = _arrayOfOtherFaceProducts;
@synthesize arrayOfLipsProducts = _arrayOfLipsProducts;
@synthesize currentlyDisplayedLipProductArrayPosition = _currentlyDisplayedLipProductArrayPosition;
@synthesize arrayOfOtherLipsProducts = _arrayOfOtherLipsProducts;
@synthesize arrayOfEyeProducts = _arrayOfEyeProducts;
@synthesize currentlyDisplayedEyeProductArrayPosition = _currentlyDisplayedEyeProductArrayPosition;
@synthesize arrayOfOtherEyeProducts = _arrayOfOtherEyeProducts;
@synthesize arrayOfBlushProducts = _arrayOfBlushProducts;
@synthesize currentlyDisplayedBlushProductArrayPosition = _currentlyDisplayedBlushProductArrayPosition;
@synthesize arrayOfOtherBlushProducts = _arrayOfOtherBlushProducts;
@synthesize profileID = _profileID;
@synthesize selected_index = _selected_index;
@synthesize userProfileImage = _userProfileImage;
@synthesize hairColorView = _hairColorView;
@synthesize faceColorView = _faceColorView;
@synthesize eyesColorView = _eyesColorView;
@synthesize lipsColorView = _lipsColorView;
@synthesize faceProductImage = _faceProductImage;
@synthesize eyesProductImage = _eyesProductImage;
@synthesize lipsProductImage = _lipsProductImage;
@synthesize lipsProductColorSwatchView = _lipsProductColorSwatchView;
@synthesize eyesProductColorSwatchView = _eyesProductColorSwatchView;
@synthesize faceProductColorSwatchView = _faceProductColorSwatchView;
@synthesize faceProductContainerView = _faceProductContainerView;
@synthesize eyesProductContainerView = _EyesProductContainerView;
@synthesize lipsProductContainerView = _LipsProductContainerView;
@synthesize noLipsProductErrorLabel = _noLipsProductErrorLabel;
@synthesize noFaceProductErrorLabel = _noFaceProductErrorLabel;
@synthesize noEyeProductErrorLabel = _noEyeProductErrorLabel;
@synthesize buttonGlam = _buttonGlam;
@synthesize buttonOffice = _buttonOffice;
@synthesize buttonEdgy = _buttonEdgy;
@synthesize buttonNaturalLook = _buttonNaturalLook;
@synthesize scrollViewOfLooks = _lookPointerView;
@synthesize wishlistButton = _wishlistButton;
@synthesize wishlistImage = _wishlistImage;
@synthesize arrowDownImage = _arrowDownImage;
@synthesize productContainerView = _productContainerView;
@synthesize controlBox = _controlBox;
@synthesize labelWhyThisProduct = _labelWhyThisProduct;
@synthesize pView = _pView;
@synthesize pImageView = _pImageView;
@synthesize hairColorSignatureLabel = _hairColorSignatureLabel;
@synthesize eyeColorSignatureLabel = _eyeColorSignatureLabel;
@synthesize lipColorSignatureLabel = _lipColorSignatureLabel;
@synthesize skinColorSignatureLabel = _skinColorSignatureLabel;
@synthesize screenHeight = _screenHeight;
@synthesize screenWidth = _screenWidth;
@synthesize guideView = _guideView;


#pragma mark-
#pragma mark LIFECYCLE
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstStart"] isEqualToString:@"YES"])
    {
        [self.guideView setHidden:NO];
        UITapGestureRecognizer *tapGesture;
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeGuideView)];
        [self.guideView addGestureRecognizer:tapGesture];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isFirstStart"];
    }
    
    // Setting highlighted/normal button properties for looks.
    UIColor *highlightColor = [UIColor blackColor];
    UIColor *normalColor = [UIColor grayColor];
    
    [self.buttonEdgy setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.buttonEdgy setTitleColor:normalColor forState:UIControlStateNormal];
    
    [self.buttonGlam setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.buttonGlam setTitleColor:normalColor forState:UIControlStateNormal];
    
    [self.buttonNaturalLook setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.buttonNaturalLook setTitleColor:normalColor forState:UIControlStateNormal];
    
    [self.buttonOffice setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.buttonOffice setTitleColor:normalColor forState:UIControlStateNormal];
    
    
    // To get user model...
    CMUserProfileMap *userProfileData = (CMUserProfileMap *) [[[CMUserModel alloc]initForUserProfile]getUserProfileMapObject];
    
    // To get user's profile id...
    self.profileID = [NSString stringWithFormat:@"%@", userProfileData.profileID];
    NSLog(@"profileID: %@", self.profileID);
    
    // To display user's profile...
    CMApplicationModel *applicationModel = [[CMApplicationModel alloc] init];
    NSData* imageData = [applicationModel getOriginalImage];
    UIImage* originImage = [UIImage imageWithData:imageData];
    
    if (originImage)
    {
        [self.userProfileImage setImage:originImage];
    }
    else
    {
        [self.userProfileImage setImageWithURL:userProfileData.imageURL];
    }
    
    //[self.userProfileImage setImageWithURL:userProfileData.imageURL];
    
    self.hairColorView.backgroundColor = userProfileData.hairColor;
    self.eyesColorView.backgroundColor = userProfileData.eyesColor;
    self.faceColorView.backgroundColor = userProfileData.skinColor;
    self.lipsColorView.backgroundColor = userProfileData.lipsColor;
    
    
    // To set user's color signature...
    NSString *errorMsg = @"extraction failed";
    UIColor *failColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    
    if (![userProfileData.hairColor isEqual:failColor])
    {
        self.hairColorSignatureLabel.text = [NSString stringWithFormat:@"%@, %@ hair",userProfileData.hairValue, userProfileData.hairTemp];
        self.hairColorError.hidden = YES;
    }
    else
    {
        self.hairColorSignatureLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
        self.hairColorView.backgroundColor = [UIColor clearColor];
        self.hairColorError.hidden = NO;
    }
    
    if (![userProfileData.eyesColor isEqual:failColor])
    {
        self.eyeColorSignatureLabel.text = [NSString stringWithFormat:@"%@, %@, %@ eyes", userProfileData.eyesChroma, userProfileData.eyesTemp, userProfileData.eyesColorName];
        self.eyeColorError.hidden = YES;
    }
    else
    {
        self.eyeColorSignatureLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
        self.eyesColorView.backgroundColor = [UIColor clearColor];
        self.eyeColorError.hidden = NO;
    }
    
    if (![userProfileData.skinColor isEqual:failColor])
    {
        self.skinColorSignatureLabel.text = [NSString stringWithFormat:@"%@, %@ skin ",userProfileData.skinValue, userProfileData.skinTemp];
        self.faceColorError.hidden = YES;
    }
    else
    {
        self.skinColorSignatureLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
        self.faceColorView.backgroundColor = [UIColor clearColor];
        self.faceColorError.hidden = NO;
    }
    if (![userProfileData.lipsColor isEqual:failColor])
    {
        self.lipColorSignatureLabel.text = [NSString stringWithFormat:@"%@, %@, %@ lips", userProfileData.lipsChroma,userProfileData.lipsTemp, userProfileData.lipsColorName];
        self.lipsColorError.hidden = YES;
    }
    else
    {
        self.lipColorSignatureLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
        self.lipsColorView.backgroundColor = [UIColor clearColor];
        self.lipsColorError.hidden = NO;
    }
    
    
    // To set the scroll view...
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenBounds.size.width;
    self.screenHeight = screenBounds.size.height;
    
    float scrollViewHeight = self.scrollViewOfLooks.frame.size.height;
    [self.scrollViewOfLooks setContentSize:CGSizeMake((self.screenWidth * NUMBER_OF_LOOKS), scrollViewHeight)];
    [self.scrollViewOfLooks setUserInteractionEnabled:YES];
    [self.scrollViewOfLooks setScrollEnabled:YES];
    
    // Page control...
    [self.pageControl setNumberOfPages:NUMBER_OF_LOOKS];
    
    // Hide the Error Labels...
    [self.noLipsProductErrorLabel setHidden:YES];
    [self.noFaceProductErrorLabel setHidden:YES];
    [self.noEyeProductErrorLabel setHidden:YES];
    [self.noBlushProductErrorLabel setHidden:YES];
    
    // To set the currently set list index values to -1 so that we can test and set new random number...
    self.currentlyDisplayedEyeProductArrayPosition =
    self.currentlyDisplayedFaceProductArrayPosition =
    self.currentlyDisplayedLipProductArrayPosition =
    self.currentlyDisplayedBlushProductArrayPosition = -1;
    
    
    // To request the products from server if the lists are empty...
    if ([self.arrayOfLipsProducts count]== 0 || [self.arrayOfFaceProducts count]== 0 ||
        [self.arrayOfEyeProducts count]== 0 || [self.arrayOfBlushProducts count] == 0)
    {
        [self buttonGlamPushed:self.buttonGlam];
        [self requestProductsFromServerForProductType:@"Face"];
    }
    
    
    [self.wishlistButton setSelected:NO];
    self.pView.hidden=YES;
}

- (void)removeGuideView
{
    [self.guideView removeFromSuperview];
}

#pragma mark REDRAW PRODUCT CONTAINERS
/*
 To redraw the containers...
 */
- (void) redrawLipProductContainer: (BOOL) hidden
{
    if(!hidden)
    {
        // To unhide the container...
        [self.noLipsProductErrorLabel setHidden:YES];
        [self.lipsProductContainerView setHidden:NO];
        
        // To display the random product from the list everytime...
        int currentProductIndexNumber = self.currentlyDisplayedLipProductArrayPosition;
        
        do
        {
            currentProductIndexNumber = arc4random() % (self.arrayOfLipsProducts.count);
        }
        while(self.currentlyDisplayedLipProductArrayPosition == currentProductIndexNumber && self.arrayOfLipsProducts.count > 2);
        
        self.currentlyDisplayedLipProductArrayPosition = currentProductIndexNumber;
        CMProductMap *currentProduct = [self.arrayOfLipsProducts objectAtIndex:currentProductIndexNumber];
        
        // setting image...
        // setting image...
        [self.lipsProductImage setImageWithURL:currentProduct.imageURL];
        
        // setting swatch color...
        self.lipsProductColorSwatchView.backgroundColor = currentProduct.color;
        
        // setting tap gesture...
        UITapGestureRecognizer *tapGuesture_lips=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        self.lipsProductContainerView.tag=3;
        [self.lipsProductContainerView setUserInteractionEnabled:YES];
        [self.lipsProductContainerView addGestureRecognizer:tapGuesture_lips];
    }
    else
    {
        // To display the error of no products...
        [self.lipsProductContainerView setHidden:YES];
        [self.noLipsProductErrorLabel setHidden:NO];
    }
}


- (void) redrawEyeProductContainer: (BOOL) hidden
{
    if(!hidden)
    {
        // To unhide the container...
        [self.noEyeProductErrorLabel setHidden:YES];
        [self.eyesProductContainerView setHidden:NO];
        
        // To display the random product from the list everytime...
        int currentProductIndexNumber = self.currentlyDisplayedEyeProductArrayPosition;
        do{
            currentProductIndexNumber = arc4random() % (self.arrayOfEyeProducts.count);
        }while(self.currentlyDisplayedEyeProductArrayPosition == currentProductIndexNumber && self.arrayOfEyeProducts.count>2);
        
        self.currentlyDisplayedEyeProductArrayPosition = currentProductIndexNumber;
        CMProductMap *currentProduct = [self.arrayOfEyeProducts objectAtIndex:currentProductIndexNumber];
        
        
        // setting image...
        [self.eyesProductImage setImageWithURL:currentProduct.imageURL];
        
        // setting swatch color...
        self.eyesProductColorSwatchView.backgroundColor = currentProduct.color;
        
        // setting tap gesture...
        UITapGestureRecognizer *tapGuesture_eyes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        self.eyesProductContainerView.tag=2;
        [self.eyesProductContainerView setUserInteractionEnabled:YES];
        [self.eyesProductContainerView addGestureRecognizer:tapGuesture_eyes];
        
        
    }
    
    else
    {
        // To display the error of no products...
        [self.eyesProductContainerView setHidden:YES];
        [self.noEyeProductErrorLabel setHidden:NO];
        
    }
}


- (void) redrawFaceProductContainer: (BOOL) hidden
{
    if(!hidden)
    {
        // To unhide the container...
        [self.noFaceProductErrorLabel setHidden:YES];
        [self.faceProductContainerView setHidden:NO];
        
        
        // To display the random product from the list everytime...
        int currentProductIndexNumber = self.currentlyDisplayedFaceProductArrayPosition;
        
        do{
            currentProductIndexNumber = arc4random() % (self.arrayOfFaceProducts.count);
        }while(self.currentlyDisplayedFaceProductArrayPosition == currentProductIndexNumber && self.arrayOfFaceProducts.count > 2);
        
        self.currentlyDisplayedFaceProductArrayPosition = currentProductIndexNumber;
        CMProductMap *currentProduct = [self.arrayOfFaceProducts objectAtIndex:currentProductIndexNumber];
        
        // setting face image...
        [self.faceProductImage setImageWithURL:currentProduct.imageURL];
        
        // setting swatch color...
        self.faceProductColorSwatchView.backgroundColor = currentProduct.color;
        
        // setting tab gesture...
        UITapGestureRecognizer *tapGuesture_face=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        self.faceProductContainerView.tag=1;
        [self.faceProductContainerView setUserInteractionEnabled:YES];
        [self.faceProductContainerView addGestureRecognizer:tapGuesture_face];
        
        
    }
    
    else
    {
        // To display the error of no products...
        [self.faceProductContainerView setHidden:YES];
        [self.noFaceProductErrorLabel setHidden:NO];
    }
}


- (void) redrawBlushProductContainer: (BOOL) hidden
{
    if(!hidden)
    {
        // To unhide the container...
        [self.noBlushProductErrorLabel setHidden:YES];
        [self.blushProductContainerView setHidden:NO];
        
        
        // To display the random product from the list everytime...
        int currentProductIndexNumber = self.currentlyDisplayedBlushProductArrayPosition;
        
        do{
            currentProductIndexNumber = arc4random() % (self.arrayOfBlushProducts.count);
        }while(self.currentlyDisplayedBlushProductArrayPosition == currentProductIndexNumber && self.arrayOfBlushProducts.count > 2);
        
        self.currentlyDisplayedBlushProductArrayPosition = currentProductIndexNumber;
        CMProductMap *currentProduct = [self.arrayOfBlushProducts objectAtIndex:currentProductIndexNumber];
        
        // setting face image...
        [self.blushProductImage setImageWithURL:currentProduct.imageURL];
        
        // setting swatch color...
        self.blushProductColorSwatchView.backgroundColor = currentProduct.color;
        
        // setting tab gesture...
        UITapGestureRecognizer *tapGuesture_face=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        self.blushProductContainerView.tag = 4;
        [self.blushProductContainerView setUserInteractionEnabled:YES];
        [self.blushProductContainerView addGestureRecognizer:tapGuesture_face];
        
        
    }
    
    else
    {
        // To display the error of no products...
        [self.blushProductContainerView setHidden:YES];
        [self.noBlushProductErrorLabel setHidden:NO];
    }
}



#pragma mark LOOK BUTTON PUSHED
// GLAM: Show either glam lips + office eyes or glam eyes + office lips
- (IBAction)buttonGlamPushed:(UIButton *)sender
{
    [SVProgressHUD showWithStatus:STR_LOADING maskType:SVProgressHUDMaskTypeGradient];
    NSLog(@"Glam Pushed...");
    
    // To set the default look values...
    CMFilterModel *filterModel = [[CMFilterModel alloc] init];
    [filterModel setLook:lookTypeGlam ForProductType:productTypeIdForLips];
    [filterModel setLook:lookTypeOffice ForProductType:productTypeIdForEyes];
    self.currentBlushLookID = BLUSH_GLAM;
    
    // To get the products from the server...
    [self requestProductsFromServerForProductType:@"Lips"];
    [self requestProductsFromServerForProductType:@"Eyes"];
    [self requestProductsFromServerForProductType:@"Blush"];
    
    if(self.arrayOfFaceProducts.count == 0)
    {
        [self requestProductsFromServerForProductType:@"Face"];
    }
    
    // To scroll to page...
    float containerHeight = self.productContainerView.frame.size.height;
    float positionX = self.screenWidth * 0;
    [self.productContainerView setFrame:CGRectMake(positionX, 0, self.screenWidth, containerHeight)];
    [self.productContainerView setBackgroundColor:[UIColor blackColor]];
    //[self.scrollViewOfLooks scrollRectToVisible:frame animated:YES];
    [self.scrollViewOfLooks setContentOffset:CGPointMake(positionX, 0)];
    [self.arrowDownImage setCenter:CGPointMake(self.buttonGlam.center.x, self.arrowDownImage.center.y)];
    
    // set button font bold
    [self.buttonNaturalLook.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    [self.buttonOffice.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    [self.buttonEdgy.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    [self.buttonGlam.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:13.0]];
    
    [self.buttonNaturalLook setSelected:NO];
    [self.buttonOffice setSelected:NO];
    [self.buttonEdgy setSelected:NO];
    [self.buttonGlam setSelected:YES];
    
}

// it's call office and show office product
- (IBAction)buttonOfficePressed:(UIButton *)sender
{
    [SVProgressHUD showWithStatus:STR_LOADING maskType:SVProgressHUDMaskTypeGradient];
    NSLog(@"Office Pushed...");
    
    // To set the default look values...
    CMFilterModel *filterModel = [[CMFilterModel alloc] init];
    [filterModel setLook:lookTypeOffice ForProductType:productTypeIdForEyes];
    [filterModel setLook:lookTypeOffice ForProductType:productTypeIdForLips];
    self.currentBlushLookID = BLUSH_OFFICE;
    
    // To get the products from the server...
    [self requestProductsFromServerForProductType:@"Lips"];
    [self requestProductsFromServerForProductType:@"Eyes"];
    [self requestProductsFromServerForProductType:@"Blush"];
    
    if(self.arrayOfFaceProducts.count == 0)
    {
        [self requestProductsFromServerForProductType:@"Face"];
    }
    
    // To scroll to page...
    float containerHeight = self.productContainerView.frame.size.height;
    float positionX = self.screenWidth * 1;
    [self.productContainerView setFrame:CGRectMake(positionX, 0, self.screenWidth, containerHeight)];
    [self.productContainerView setBackgroundColor:[UIColor blackColor]];
    [self.scrollViewOfLooks setContentOffset:CGPointMake(positionX, 0)];
    [self.arrowDownImage setCenter:CGPointMake(self.buttonOffice.center.x, self.arrowDownImage.center.y)];
    
    // set button font bold
    [self.buttonOffice.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:13.0]];
    [self.buttonNaturalLook.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    [self.buttonEdgy.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    [self.buttonGlam.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    
    [self.buttonNaturalLook setSelected:NO];
    [self.buttonOffice setSelected:YES];
    [self.buttonEdgy setSelected:NO];
    [self.buttonGlam setSelected:NO];
}


// it's call edgy now and show glam eyes (37) and glam lips (26)
- (IBAction)buttonEdgyPushed:(UIButton *)sender
{
    [SVProgressHUD showWithStatus:STR_LOADING maskType:SVProgressHUDMaskTypeGradient];
    NSLog(@"Edgy Pushed...");
    
    // To set the default look values...
    CMFilterModel *filterModel = [[CMFilterModel alloc] init];
    [filterModel setLook:lookTypeGlam ForProductType:productTypeIdForEyes];
    [filterModel setLook:lookTypeGlam ForProductType:productTypeIdForLips];
    self.currentBlushLookID = BLUSH_GLAM;

    
    // To get the products from the server...
    [self requestProductsFromServerForProductType:@"Lips"];
    [self requestProductsFromServerForProductType:@"Eyes"];
    [self requestProductsFromServerForProductType:@"Blush"];
    
    if(self.arrayOfFaceProducts.count == 0)
    {
        [self requestProductsFromServerForProductType:@"Face"];
    }
    
    // To scroll to page...
    float containerHeight = self.scrollViewOfLooks.frame.size.height;
    float positionX = self.screenWidth * 2;
    [self.productContainerView setFrame:CGRectMake(positionX, 0, self.screenWidth, containerHeight)];
    [self.scrollViewOfLooks setContentOffset:CGPointMake(positionX, 0)];
    [self.arrowDownImage setCenter:CGPointMake(self.buttonEdgy.center.x, self.arrowDownImage.center.y)];
    
    // set button font bold
    [self.buttonNaturalLook.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    [self.buttonOffice.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    [self.buttonEdgy.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:13.0]];
    [self.buttonGlam.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    
    [self.buttonNaturalLook setSelected:NO];
    [self.buttonOffice setSelected:NO];
    [self.buttonEdgy setSelected:YES];
    [self.buttonGlam setSelected:NO];
    
}

// Natural = Simple...
- (IBAction)buttonNaturalPressed:(UIButton *)sender
{
    [SVProgressHUD showWithStatus:STR_LOADING maskType:SVProgressHUDMaskTypeGradient];
    NSLog(@"Natural Pushed...");
    
    // To set the default look values...
    CMFilterModel *filterModel = [[CMFilterModel alloc] init];
    [filterModel setLook:lookTypeSimple ForProductType:productTypeIdForEyes];
    [filterModel setLook:lookTypeSimple ForProductType:productTypeIdForLips];
    self.currentBlushLookID = BLUSH_SIMPLE;
    
    // To get the products from the server...
    [self requestProductsFromServerForProductType:@"Lips"];
    [self requestProductsFromServerForProductType:@"Eyes"];
    [self requestProductsFromServerForProductType:@"Blush"];
    
    if(self.arrayOfFaceProducts.count == 0)
    {
        [self requestProductsFromServerForProductType:@"Face"];
    }
    
    // To scroll to page...
    float containerHeight = self.scrollViewOfLooks.frame.size.height;
    float positionX = self.screenWidth * 3;
    [self.productContainerView setFrame:CGRectMake(positionX, 0, self.screenWidth, containerHeight)];
    [self.scrollViewOfLooks setContentOffset:CGPointMake(positionX, 0)];
    [self.arrowDownImage setCenter:CGPointMake(self.buttonNaturalLook.center.x, self.arrowDownImage.center.y)];
    
    
    // set button font bold
    [self.buttonNaturalLook.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:13.0]];
    [self.buttonOffice.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    [self.buttonEdgy.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    [self.buttonGlam.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:13.0]];
    
    [self.buttonNaturalLook setSelected:YES];
    [self.buttonOffice setSelected:NO];
    [self.buttonEdgy setSelected:NO];
    [self.buttonGlam setSelected:NO];
}
#pragma mark -


#pragma mark SCROLL FUNCTION
- (void)scrollViewDidScroll:(UIScrollView *) scrollView
{
    // Update the page when more than 50% of the previous/next page is visible
    //int page = floor((scrollView.contentOffset.x - self.screenWidth / 2) / self.screenWidth) + 1;
    //    NSLog(@"scrollView.contentOffset.x: %f, page: %d", scrollView.contentOffset.x, page);
    //self.pageControl.currentPage = page;
    
    if (self.scrollViewOfLooks.contentOffset.x < self.scrollViewOfLooks.frame.size.width)
    {
        [self.productContainerView setFrame:CGRectMake(self.scrollViewOfLooks.frame.size.width * 0, 0, self.productContainerView.frame.size.width, self.productContainerView.frame.size.height)];
    }
    
    else if (self.scrollViewOfLooks.contentOffset.x < self.scrollViewOfLooks.frame.size.width * 2)
    {
        [self.productContainerView setFrame:CGRectMake(self.scrollViewOfLooks.frame.size.width * 1, 0, self.productContainerView.frame.size.width, self.productContainerView.frame.size.height)];
    }
    
    else if (self.scrollViewOfLooks.contentOffset.x < self.scrollViewOfLooks.frame.size.width * 3)
    {
        [self.productContainerView setFrame:CGRectMake(self.scrollViewOfLooks.frame.size.width * 2, 0, self.productContainerView.frame.size.width, self.productContainerView.frame.size.height)];
    }
    
    else if (self.scrollViewOfLooks.contentOffset.x < self.scrollViewOfLooks.frame.size.width * 4)
    {
        [self.productContainerView setFrame:CGRectMake(self.scrollViewOfLooks.frame.size.width * 3, 0, self.productContainerView.frame.size.width, self.productContainerView.frame.size.height)];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    int page = self.productContainerView.frame.origin.x/self.scrollViewOfLooks.frame.size.width;
    
    switch (page) {
        case 0:
            [self buttonGlamPushed:nil];
            break;
            
        case 1:
            [self buttonOfficePressed:nil];
            break;
            
        case 2:
            [self buttonEdgyPushed:nil];
            break;
            
        case 3:
            [self buttonNaturalPressed:nil];
            break;
            
        default:
            break;
    }
}
#pragma mark -


#pragma mark WISHLIST FUNCTION
- (IBAction)wishlistButtonPressed {
    
    LogInfo(@"Wishlist button in beauty screen pressed");
    
    if(self.wishlistButton.isSelected)
    {
        // Remove all the 3 products to wishlist...
        if(self.arrayOfFaceProducts.count != 0)
            [self toggleWishlistForProduct:[self.arrayOfFaceProducts objectAtIndex:self.currentlyDisplayedFaceProductArrayPosition]
                                performAdd: NO];
        
        if(self.arrayOfEyeProducts.count != 0)
            [self toggleWishlistForProduct:[self.arrayOfEyeProducts objectAtIndex:self.currentlyDisplayedEyeProductArrayPosition]
                                performAdd:NO];
        
        if(self.arrayOfLipsProducts.count != 0)
            [self toggleWishlistForProduct:[self.arrayOfLipsProducts objectAtIndex:self.currentlyDisplayedLipProductArrayPosition]
                                performAdd:NO];
        
        if(self.arrayOfBlushProducts.count != 0)
            [self toggleWishlistForProduct:[self.arrayOfBlushProducts objectAtIndex:self.currentlyDisplayedBlushProductArrayPosition]
                                performAdd:NO];
        
        [SVProgressHUD showSuccessWithStatus:REMOVE_FROM_WISHLIST];
    }
    else
    {
        // Add all the 3 products to wishlist...
        if(self.arrayOfFaceProducts.count != 0)
            [self toggleWishlistForProduct:[self.arrayOfFaceProducts objectAtIndex:self.currentlyDisplayedFaceProductArrayPosition]
                                performAdd: YES];
        
        if(self.arrayOfEyeProducts.count != 0)
            [self toggleWishlistForProduct:[self.arrayOfEyeProducts objectAtIndex:self.currentlyDisplayedEyeProductArrayPosition]
                                performAdd:YES];
        
        if(self.arrayOfLipsProducts.count != 0)
            [self toggleWishlistForProduct:[self.arrayOfLipsProducts objectAtIndex:self.currentlyDisplayedLipProductArrayPosition]
                                performAdd:YES];
        
        if(self.arrayOfBlushProducts.count != 0)
            [self toggleWishlistForProduct:[self.arrayOfBlushProducts objectAtIndex:self.currentlyDisplayedBlushProductArrayPosition]
                                performAdd:YES];
        
        [SVProgressHUD showSuccessWithStatus:ADDED_TO_WISHLIST];
    }
    
    
    [self toggleWishlistImage];
}

-(void) toggleWishlistForProduct: (CMProductMap *) product
                      performAdd: (BOOL) toAdd
{
    // if the product is not saved yet, then save the product.
    if (toAdd)
    {
        // To save the product locally first...
        [CMApplicationModel addProductToWishlist:product];
    }
    else
    {
        // To remove the product from wishlist locally...
        [CMApplicationModel removeProductFromWishlist:product];
        product.isWishlist = NO;
    }
    
}

- (void) toggleWishlistImage
{
    if(self.wishlistButton.isSelected)
    {
        [self.wishlistButton setSelected:NO];
        [self.wishlistImage setImage:[UIImage imageNamed:@"HeartIcon.png"]];
    }
    
    else
    {
        [self.wishlistButton setSelected:YES];
        [self.wishlistImage setImage:[UIImage imageNamed:@"HeartIcon_Pressed.png"]];
    }
}
#pragma mark-


#pragma mark VIEW ENSEMBLE FUNCTION
- (IBAction)viewEnsembleButtonPressed
{
    LogInfo(@"view ensemble button in beauty screen pressed");
    
    if(self.arrayOfLipsProducts.count != 0  && self.arrayOfEyeProducts.count != 0 &&
       self.arrayOfBlushProducts.count != 0 && self.arrayOfFaceProducts.count != 0)
    {
        [self performSegueWithIdentifier:@"viewEnsemble" sender:self];
    }
}
#pragma mark-


#pragma mark SHARE FUNCTION
- (IBAction)shareButtonPressed
{
    LogInfo(@"Share button in beauty screen pressed");
    
    NSMutableArray *productArray = [[NSMutableArray alloc] init];
    
    if(self.arrayOfEyeProducts.count != 0)
    {
        [productArray addObject:[self.arrayOfEyeProducts objectAtIndex:self.currentlyDisplayedEyeProductArrayPosition]];
    }
    
    if (self.arrayOfFaceProducts.count != 0)
    {
        [productArray addObject:[self.arrayOfFaceProducts objectAtIndex:self.currentlyDisplayedFaceProductArrayPosition]];
    }
    
    if(self.arrayOfLipsProducts.count != 0)
    {
        [productArray addObject:[self.arrayOfLipsProducts objectAtIndex:self.currentlyDisplayedLipProductArrayPosition]];
    }
    
    if(self.arrayOfBlushProducts.count != 0)
    {
        [productArray addObject:[self.arrayOfBlushProducts objectAtIndex:self.currentlyDisplayedBlushProductArrayPosition]];
    }
    
    [self.view addSubview:[[ShareFunctionalityView alloc]
                           initWithProductArray:productArray
                           WithSuperViewController:self
                           WithViewPosition:VIEW_LOCATION_BOTTOM]];
    
}
#pragma mark-


#pragma mark P FUNCTION
- (IBAction)pViewCloseButtonPressed {
    
    self.pView.hidden=YES;
}

- (IBAction)pViewButtonPressed:(UIButton *)sender
{
    LogInfo(@"P button in beauty screen pressed");
    
    self.pView.hidden=NO;
    
    self.labelWhyThisProduct.text = @"";    // To reset the message.
    
    CMProductMap *product = [self.arrayOfFaceProducts objectAtIndex:self.currentlyDisplayedFaceProductArrayPosition];
    
    if (sender.tag==1) {
        product = [self.arrayOfFaceProducts objectAtIndex:self.currentlyDisplayedFaceProductArrayPosition];
    }
    else if (sender.tag==2) {
        product = [self.arrayOfEyeProducts objectAtIndex:self.currentlyDisplayedEyeProductArrayPosition];
    }
    else if (sender.tag==3) {
        product = [self.arrayOfLipsProducts objectAtIndex:self.currentlyDisplayedLipProductArrayPosition];
    }
    else if (sender.tag==4) {
        product = [self.arrayOfBlushProducts objectAtIndex:self.currentlyDisplayedBlushProductArrayPosition];
    }
    
    [self.pImageView setImageWithURL:product.imageURL];
    
    if(product.matchMessage.length != 0) {
        self.labelWhyThisProduct.text=product.matchMessage;
    }
}
#pragma mark-


#pragma mark FILTER FUNCTION
- (IBAction)filterButtonPressed
{
    LogInfo("Filter button in beauty screen pressed");
    [self performSegueWithIdentifier:@"goFilter" sender:self];
}
#pragma mark-


#pragma mark SPIN FUNCTION
- (IBAction)buttonSpinLookPressed
{
    if(self.arrayOfEyeProducts.count != 0)
    {
        [self redrawEyeProductContainer: NO];
    }
    if (self.arrayOfFaceProducts.count != 0)
    {
        [self redrawFaceProductContainer: NO];
    }
    if(self.arrayOfLipsProducts.count != 0)
    {
        [self redrawLipProductContainer: NO];
    }
    if(self.arrayOfBlushProducts.count != 0)
    {
        [self redrawBlushProductContainer: NO];
    }
    
    // To deselect the wishlist button...
    if(self.wishlistButton.isSelected)
    {
        [self toggleWishlistImage];
    }
}
#pragma mark-


#pragma mark UTILITY METHODS
-(void) requestProductsFromServerForProductType: (NSString *) productType
{
    NSString *ptID;
    NSString *subCategoryID;
    
    if ([productType isEqualToString:@"Lips"])
    {
        ptID = productTypeIdForLips;        
        subCategoryID = @"";
    }
    else if ([productType isEqualToString:@"Eyes"])
    {
        ptID = productTypeIdForEyes;
        subCategoryID = @"";  
        
    }
    else if ([productType isEqualToString:@"Face"])
    {
        ptID = productTypeIdForFace;
        subCategoryID = @"";
    }
    
    else if([productType isEqualToString:@"Blush"])
    {
        ptID = productTypeIdForFace;
        subCategoryID = @"";
    }
    
    // To set the parameters...
    CMProductsServerCallSetup *serverCallSetupModel = [[CMProductsServerCallSetup alloc]
                                                       initWithProfileID:self.profileID
                                                       ForPtID:ptID
                                                       ForSubCategory:subCategoryID];
    
    [serverCallSetupModel setParametersForDefaultFilters];
    NSMutableDictionary *params = (NSMutableDictionary *)[serverCallSetupModel getParameters];
    
    // OverRidding Loop parameters for Face and Blush....
    if ([productType isEqualToString:@"Blush"])
    {
        [params setObject:self.currentBlushLookID forKey:@"filter_values"];
    }
    
    if ([productType isEqualToString:@"Face"])
    {
        [params setObject:lookIDForFace forKey:@"filter_values"];
    }
    
    // To create the url to call...
    NSURL *url = [NSURL URLWithString:server];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    
    NSMutableURLRequest *request = [httpClient
                                    requestWithMethod:@"POST"
                                    path:pathToAPICallForRecommendationEngine
                                    parameters:params];
    
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    // To make the server call...
    [self makeServerCallForRequest:request ForProductType:productType];
}


-(void) makeServerCallForRequest: (NSMutableURLRequest *) request
                  ForProductType: (NSString *) productType
{
    
    // NSLog(@"%@", [request allHTTPHeaderFields]);
    // NSLog(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    // NSLog(@"%@",[request valueForHTTPHeaderField:field]);
    
    if([productType isEqualToString:@"Lips"])
    {
        NSLog(@"Lips Request: %@", request);
        NSLog(@"Lips Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    }
    
    
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         BOOL success=[[JSON objectForKey:@"success"] boolValue];
         if (success)
         {
             if ([productType isEqualToString:@"Lips"])
             {
                 self.arrayOfLipsProducts = [CMProductModel getProductsListFromJSON:JSON];
                 self.arrayOfOtherLipsProducts = [CMProductModel getOtherProductsListFromJSON:JSON];
                 self.currentlyDisplayedLipProductArrayPosition = 0;
                  NSLog(@"Lips JSON: %@", JSON);
                 if(self.arrayOfLipsProducts.count == 0 && self.arrayOfOtherLipsProducts.count == 0)
                 {
                     NSLog(@"EMPTY LIPS PRODUCTS");
                     [self redrawLipProductContainer: YES];
                 }
                 else if(self.arrayOfLipsProducts.count == 0)
                 {
                     //self.arrayOfLipsProducts = self.arrayOfOtherLipsProducts;
                     //[self.pButtonForLips setHidden:YES];
                     [self redrawLipProductContainer: YES];
                 }
                 else
                 {
                     [self.pButtonForLips setHidden:NO];
                     [self redrawLipProductContainer: NO];
                 }
                 
             }
             
             else if ([productType isEqualToString:@"Eyes"])
             {
                 self.arrayOfEyeProducts = [CMProductModel getProductsListFromJSON:JSON];
                 self.arrayOfOtherEyeProducts = [CMProductModel getOtherProductsListFromJSON:JSON];
                 self.currentlyDisplayedEyeProductArrayPosition = 0;
                 
                 if(self.arrayOfEyeProducts.count == 0 && self.arrayOfOtherEyeProducts.count == 0)
                 {
                     NSLog(@"EMPTY EYE PRODUCTS...");
                     [self redrawEyeProductContainer: YES];
                 }
                 else if(self.arrayOfEyeProducts.count == 0)
                 {
                     //self.arrayOfEyeProducts = self.arrayOfOtherEyeProducts;
                     //[self.pButtonForEyes setHidden:YES];
                     [self redrawEyeProductContainer: YES];
                 }
                 else
                 {
                     [self.pButtonForEyes setHidden:NO];
                     [self redrawEyeProductContainer: NO];
                 }
                 
             }
             
             else if ([productType isEqualToString:@"Face"])
             {
                 self.arrayOfFaceProducts = (NSArray *)[CMProductModel getProductsListFromJSON:JSON];
                 self.arrayOfOtherFaceProducts = [CMProductModel getOtherProductsListFromJSON:JSON];
                 self.currentlyDisplayedFaceProductArrayPosition = 0;
                
                 if(self.arrayOfFaceProducts.count == 0 && self.arrayOfOtherFaceProducts.count == 0)
                 {
                     NSLog(@"EMPTY FACE PRODUCTS...");
                     [self redrawFaceProductContainer: YES];
                 }
                 else if(self.arrayOfFaceProducts.count == 0)
                 {
                     //self.arrayOfFaceProducts = self.arrayOfOtherFaceProducts;
                     //[self.pButtonForFace setHidden:YES];
                     [self redrawFaceProductContainer: YES];
                 }
                 else
                 {
                     [self.pButtonForFace setHidden:NO];
                     [self redrawFaceProductContainer: NO];
                 }
             }
             
             else if ([productType isEqualToString:@"Blush"])
             {   
                 self.arrayOfBlushProducts = (NSArray *)[CMProductModel getProductsListFromJSON:JSON];
                 self.arrayOfOtherBlushProducts = [CMProductModel getOtherProductsListFromJSON:JSON];
                 self.currentlyDisplayedBlushProductArrayPosition = 0;
                 
                 if(self.arrayOfBlushProducts.count == 0 && self.arrayOfOtherBlushProducts.count == 0)
                 {
                     NSLog(@"EMPTY BLUSH PRODUCTS...");
                     [self redrawBlushProductContainer: YES];
                 }
                 else if(self.arrayOfBlushProducts.count == 0)
                 {
                     //self.arrayOfBlushProducts = self.arrayOfOtherBlushProducts;
                     //[self.pButtonForBlush setHidden:YES];
                     [self redrawBlushProductContainer: YES];
                 }
                 else
                 {
                     [self.pButtonForBlush setHidden:NO];
                     [self redrawBlushProductContainer: NO];
                 }
             }
             
             [SVProgressHUD dismiss];
         }
         else
         {
             NSLog(@"Errored out: JSON: %@", JSON);
             NSString *errorMessage = [[JSON objectForKey:@"errors"] objectForKey:@"email"];
             errorMessage = [NSString stringWithFormat:@"%@. Please try again.", errorMessage];
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         LogError(@"error: %i", response.statusCode);
         [SVProgressHUD showErrorWithStatus:@"It appears you have lost internet connectivity. Please check your network settings."];
     }];
    [operation start];
}


-(void)tapAction: (UIGestureRecognizer *)gestureRecognizer
{
    UIView *view=[gestureRecognizer view];
    self.selected_index = view.tag;
    [self performSegueWithIdentifier: @"viewProductDetails" sender: self];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"viewProductDetails"]) {
        
        CMProductDetailsViewController *productDetailsViewController=(CMProductDetailsViewController *)[segue destinationViewController];
        
        if (self.selected_index==1) {
            [productDetailsViewController setProduct_list:[NSMutableArray arrayWithArray:self.arrayOfFaceProducts]];
            [productDetailsViewController setStarting_index:self.currentlyDisplayedFaceProductArrayPosition];
            [productDetailsViewController setCurrentProductCategory: @"Foundation"];
        }
        
        if (self.selected_index==2) {
            [productDetailsViewController setProduct_list:[NSMutableArray arrayWithArray:self.arrayOfEyeProducts]];
            [productDetailsViewController setStarting_index:self.currentlyDisplayedEyeProductArrayPosition];
            [productDetailsViewController setCurrentProductCategory: @"Eye Shadow"];
        }
        if (self.selected_index==3) {
            [productDetailsViewController setProduct_list:[NSMutableArray arrayWithArray:self.arrayOfLipsProducts]];
            [productDetailsViewController setStarting_index:self.currentlyDisplayedLipProductArrayPosition];
            [productDetailsViewController setCurrentProductCategory: @"Lipstick"];
        }
        if (self.selected_index==4) {
            [productDetailsViewController setProduct_list:[NSMutableArray arrayWithArray:self.arrayOfBlushProducts]];
            [productDetailsViewController setStarting_index:self.currentlyDisplayedBlushProductArrayPosition];
            [productDetailsViewController setCurrentProductCategory: @"Blush"];
        }
        
        //[productDetailsViewController setStarting_index:0];
    }
    
    if([segue.identifier isEqualToString:@"viewEnsemble"])
    {
        ViewEnsembleViewController *viewEnsembleViewController = (ViewEnsembleViewController *) [segue destinationViewController];
        [viewEnsembleViewController setEyeProductList:self.arrayOfEyeProducts
                        WithCurrentEyeProductPosition:self.currentlyDisplayedEyeProductArrayPosition
                                   setLipsProductList:self.arrayOfLipsProducts
                       WithCurrentLipsProductPosition:self.currentlyDisplayedLipProductArrayPosition
                                  setBlushProductList:self.arrayOfBlushProducts
                      WithCurrentBlushProductPoistion:self.currentlyDisplayedBlushProductArrayPosition
                                   setFaceProductList:self.arrayOfFaceProducts
                        WithCurrenFaceProductPosition:self.currentlyDisplayedFaceProductArrayPosition];
    }
    if([segue.identifier isEqualToString:@"goFilter"])
    {
        CMProductFilterViewController *productFilterViewController = (CMProductFilterViewController *) [segue destinationViewController];
        [productFilterViewController initializeFilters];
    }
}
#pragma mark-


- (IBAction)exitButtonPressed:(id)sender
{
    /*
    [CMApplicationModel logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
     */
}

- (void)viewDidUnload
{
    [self setHairColorView:nil];
    [self setFaceColorView:nil];
    [self setEyesColorView:nil];
    [self setLipsColorView:nil];
    [self setFaceProductImage:nil];
    [self setEyesProductImage:nil];
    [self setLipsProductImage:nil];
    [self setLipsProductColorSwatchView:nil];
    [self setEyesProductColorSwatchView:nil];
    [self setFaceProductColorSwatchView:nil];
    [self setFaceProductContainerView:nil];
    [self setEyesProductContainerView:nil];
    [self setLipsProductContainerView:nil];
    [self setNoLipsProductErrorLabel:nil];
    [self setNoFaceProductErrorLabel:nil];
    [self setNoEyeProductErrorLabel:nil];
    [self setButtonGlam:nil];
    [self setButtonOffice:nil];
    [self setButtonEdgy:nil];
    [self setButtonNaturalLook:nil];
    [self setButtonSpinLook:nil];
    [self setUserProfileImage:nil];
    [self setScrollViewOfLooks:nil];
    [self setScrollViewOfLooks:nil];
    [self setWishlistButton:nil];
    [self setWishlistImage:nil];
    [self setControlBox:nil];
    [self setPButtonForLips:nil];
    [self setPButtonForEyes:nil];
    [self setPButtonForFace:nil];
    [self setHairColorError:nil];
    [self setEyeColorError:nil];
    [self setFaceColorError:nil];
    [self setLipsColorError:nil];
    [self setBlushProductContainerView:nil];
    [self setBlushProductImage:nil];
    [self setBlushProductColorSwatchView:nil];
    [self setPButtonForBlush:nil];
    [super viewDidUnload];
}



@end
