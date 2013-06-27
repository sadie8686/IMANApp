//
//  ViewEnsembleViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 3/27/13.
//
//

#import "ViewEnsembleViewController.h"
#import "CMProductMap.h"
#import "QuartzCore/QuartzCore.h"
#import "CMConstants.h"
#import "SVProgressHUD.h"
#import "ShareFunctionalityView.h"
#import "Logging.h"
#import "CMProductDetailsViewController.h"
#import "ProductBoxView.h"
#import "CMApplicationModel.h"

@interface ViewEnsembleViewController ()

// To store the product array...
@property (nonatomic, strong) NSArray *eyeProductArray;
@property (nonatomic, strong) NSArray *lipsProductArray;
@property (nonatomic, strong) NSArray *blushProductArray;
@property (nonatomic, strong) NSArray *faceProductArray;

@property int currentEyeProductPositionInArray;
@property int currentLipProductPositionInArray;
@property int currentBlushProductPositionInArray;
@property int currentFaceProductPositionInArray;


// top view
@property (strong, nonatomic) IBOutlet UIView *controlBox;
@property (strong, nonatomic) IBOutlet UIButton *wishlistButton;

// top view lip
@property (strong, nonatomic) IBOutlet UIView *lipProductContainer;
@property (strong, nonatomic) IBOutlet UIImageView *lipProductImage;
@property (strong, nonatomic) IBOutlet UIView *lipProductColorSwatch;

// top view eye
@property (strong, nonatomic) IBOutlet UIView *eyeProductContainer;
@property (strong, nonatomic) IBOutlet UIImageView *eyeProductImage;
@property (strong, nonatomic) IBOutlet UIView *eyeProductColorSwatch;

// top view blush
@property (strong, nonatomic) IBOutlet UIView *blushProductContainer;
@property (strong, nonatomic) IBOutlet UIImageView *blushProductImage;
@property (strong, nonatomic) IBOutlet UIView *blushProductColorSwatch;

// top view face
@property (strong, nonatomic) IBOutlet UIView *faceProductContainer;
@property (strong, nonatomic) IBOutlet UIImageView *faceProductImage;
@property (strong, nonatomic) IBOutlet UIView *faceProductColorSwatch;

// scroll view
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

// scroll view lip
@property (strong, nonatomic) IBOutlet UIView *scrollLipsContainer;
@property (strong, nonatomic) IBOutlet UILabel *scrollLipsBrand;
@property (strong, nonatomic) IBOutlet UIView *scrollLipsProductBox;
@property (strong, nonatomic) IBOutlet UILabel *scrollLipsDescription;
@property (strong, nonatomic) IBOutlet UIButton *scrollLipsButtonLeft;
@property (strong, nonatomic) IBOutlet UIButton *scrollLipsButtonRight;

// scroll view eye
@property (strong, nonatomic) IBOutlet UIView *scrollEyesContainer;
@property (strong, nonatomic) IBOutlet UILabel *scrollEyeBrand;
@property (strong, nonatomic) IBOutlet UIView *scrollEyesProductBox;
@property (strong, nonatomic) IBOutlet UILabel *scrollEyeDescription;
@property (strong, nonatomic) IBOutlet UIButton *scrollEyesButtonLeft;
@property (strong, nonatomic) IBOutlet UIButton *scrollEyesButtonRight;

// scroll view blush
@property (strong, nonatomic) IBOutlet UIView *scrollBlushContainer;
@property (strong, nonatomic) IBOutlet UILabel *scrollBlushBrand;
@property (strong, nonatomic) IBOutlet UIView *scrollBlushProductBox;
@property (strong, nonatomic) IBOutlet UILabel *scrollBlushDescription;
@property (strong, nonatomic) IBOutlet UIButton *scrollBlushButtonLeft;
@property (strong, nonatomic) IBOutlet UIButton *scrollBlushButtonRight;

// scroll view face
@property (strong, nonatomic) IBOutlet UIView *scrollFaceContainer;
@property (strong, nonatomic) IBOutlet UILabel *scrollFaceBrand;
@property (strong, nonatomic) IBOutlet UIView *scrollFaceProductBox;
@property (strong, nonatomic) IBOutlet UILabel *scrollFaceDescription;
@property (strong, nonatomic) IBOutlet UIButton *scrollFaceButtonLeft;
@property (strong, nonatomic) IBOutlet UIButton *scrollFaceButtonRight;

@property int selectedTag;
@end

@implementation ViewEnsembleViewController
@synthesize eyeProductArray = _eyeProductArray;
@synthesize lipsProductArray = _lipsProductArray;
@synthesize blushProductArray = _blushProductArray;
@synthesize faceProductArray = _faceProductArray;
@synthesize controlBox = _controlBox;
@synthesize lipProductContainer = _lipProductContainer;
@synthesize lipProductImage = _lipProductImage;
@synthesize lipProductColorSwatch = _lipProductColorSwatch;
@synthesize eyeProductContainer = _eyeProductContainer;
@synthesize eyeProductImage = _eyeProductImage;
@synthesize eyeProductColorSwatch = _eyeProductColorSwatch;
@synthesize faceProductContainer = _faceProductContainer;
@synthesize faceProductImage = _faceProductImage;
@synthesize faceProductColorSwatch = _faceProductColorSwatch;
@synthesize currentEyeProductPositionInArray = _currentEyeProductPositionInArray;
@synthesize currentLipProductPositionInArray = _currentLipProductPositionInArray;
@synthesize currentFaceProductPositionInArray = _currentFaceProductPositionInArray;
@synthesize scrollView = _scrollView;
@synthesize scrollLipsContainer = _scrollLipsContainer;
@synthesize scrollLipsBrand = _scrollLipsBrand;
@synthesize scrollLipsDescription = _scrollLipsDescription;
@synthesize scrollEyesContainer = _scrollEyesContainer;
@synthesize scrollEyeBrand = _scrollEyeBrand;
@synthesize scrollEyeDescription = _scrollEyeDescription;
@synthesize scrollFaceContainer = _scrollFaceContainer;
@synthesize scrollFaceBrand = _scrollFaceBrand;
@synthesize scrollFaceDescription = _scrollFaceDescription;
@synthesize selectedTag = _selectedTag;

#pragma mark-
#pragma mark INITIALIZE
- (void) setEyeProductList:(NSArray *) eyeProductsArray
WithCurrentEyeProductPosition: (int) currentEyePosition
        setLipsProductList: (NSArray *) lipsProductsArray
WithCurrentLipsProductPosition: (int) currentLipsPosition
       setBlushProductList:(NSArray *) blushProductsArray
WithCurrentBlushProductPoistion: (int) currentBlushPosition
        setFaceProductList:(NSArray *) faceProductsArray
WithCurrenFaceProductPosition: (int) currentFacePosition
{
    self.eyeProductArray = eyeProductsArray;
    self.currentEyeProductPositionInArray = currentEyePosition;
    
    self.lipsProductArray = lipsProductsArray;
    self.currentLipProductPositionInArray = currentLipsPosition;
    
    self.blushProductArray = blushProductsArray;
    self.currentBlushProductPositionInArray = currentBlushPosition;
    
    self.faceProductArray = faceProductsArray;
    self.currentFaceProductPositionInArray = currentFacePosition;
}
#pragma mark-




#pragma mark LIFECYCLE
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // To set the TAP Gesture to the views...
    UITapGestureRecognizer *tapGuesture;
    
    // To add tap gestures to the top view product containers...
    tapGuesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.lipProductContainer setTag:1];
    [self.lipProductContainer setUserInteractionEnabled:YES];
    [self.lipProductContainer addGestureRecognizer:tapGuesture];
    
    tapGuesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.eyeProductContainer setTag:2];
    [self.eyeProductContainer setUserInteractionEnabled:YES];
    [self.eyeProductContainer addGestureRecognizer:tapGuesture];
    
    tapGuesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.blushProductContainer setTag:3];
    [self.blushProductContainer setUserInteractionEnabled:YES];
    [self.blushProductContainer addGestureRecognizer:tapGuesture];
    
    tapGuesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.faceProductContainer setTag:4];
    [self.faceProductContainer setUserInteractionEnabled:YES];
    [self.faceProductContainer addGestureRecognizer:tapGuesture];
    
    // To add tap gesture to the bottom scroll product boxes...
    tapGuesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.scrollLipsContainer setTag:1];
    [self.scrollLipsContainer setUserInteractionEnabled:YES];
    [self.scrollLipsContainer addGestureRecognizer:tapGuesture];
    
    tapGuesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.scrollEyesContainer setTag:2];
    [self.scrollEyesContainer setUserInteractionEnabled:YES];
    [self.scrollEyesContainer addGestureRecognizer:tapGuesture];
    
    tapGuesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.scrollBlushContainer setTag:3];
    [self.scrollBlushContainer setUserInteractionEnabled:YES];
    [self.scrollBlushContainer addGestureRecognizer:tapGuesture];
    
    tapGuesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.scrollFaceContainer setTag:4];
    [self.scrollFaceContainer setUserInteractionEnabled:YES];
    [self.scrollFaceContainer addGestureRecognizer:tapGuesture];
    
    // To set the swipe gestures to the scrolls...
    UISwipeGestureRecognizer *leftSwipe;
    UISwipeGestureRecognizer *rightSwipe;
    
    // swipe gesture to LIPS...
    leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(scrollLipProductsLeft)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.scrollLipsContainer addGestureRecognizer:leftSwipe];
    
    rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(scrollLipProductRight:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.scrollLipsContainer addGestureRecognizer:rightSwipe];
    
    // swipe gesture to EYES...
    leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(scrollEyeProductLeft:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.scrollEyesContainer addGestureRecognizer:leftSwipe];
    
    rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(scrollEyeProductRight:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.scrollEyesContainer addGestureRecognizer:rightSwipe];
    
    // swipe gesture to BLUSH...
        leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(scrollBlushProductLeft:)];
        [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.scrollBlushContainer addGestureRecognizer:leftSwipe];
    
        rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                               action:@selector(scrollBlushProductRight:)];
        [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.scrollBlushContainer addGestureRecognizer:rightSwipe];
    
    // swipe gesture to FACE...
    leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(scrollFaceProductLeft:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.scrollFaceContainer addGestureRecognizer:leftSwipe];
    
    rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(scrollFaceProductRight:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.scrollFaceContainer addGestureRecognizer:rightSwipe];
    
    // To set the normal and highlighted images for the buttons...
    [self.wishlistButton setImage:[UIImage imageNamed:IMAGE_WISHLIST] forState:UIControlStateNormal];
    [self.wishlistButton setImage:[UIImage imageNamed:IMAGE_WISHLIST_SELECTED] forState:UIControlStateSelected];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // To set the background
    // [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:backgroundImageName]]];
    
    // To set the scrollView...
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 630)];
    
    // to hide the scroll if there is only one product in array...
    if(self.lipsProductArray.count == 1)
    {
        [self.scrollLipsButtonLeft setHidden:YES];
        [self.scrollLipsButtonRight setHidden:YES];
    }
    if(self.eyeProductArray.count == 1)
    {
        [self.scrollEyesButtonLeft setHidden:YES];
        [self.scrollEyesButtonRight setHidden:YES];
    }
    if(self.blushProductArray.count == 1)
    {
        [self.scrollBlushButtonLeft setHidden:YES];
        [self.scrollBlushButtonRight setHidden:YES];
    }
    if(self.faceProductArray.count == 1)
    {
        [self.scrollFaceButtonLeft setHidden:YES];
        [self.scrollFaceButtonRight setHidden:YES];
    }
    
    
    // To set the views...
    [self refreshLipProductViews];
    [self refreshEyeProductViews];
    [self refreshFaceProductViews];
    [self refreshBlushProductViews];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-




#pragma mark REFRESH CONTAINERS
- (void) refreshLipProductViews
{
    if(self.lipsProductArray.count != 0)
    {
        [self.lipProductContainer setHidden:NO];
        [self.scrollLipsContainer setHidden:NO];
        
        // getting values...
        CMProductMap *product = [self.lipsProductArray objectAtIndex:self.currentLipProductPositionInArray];
        UIImage *productImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:product.imageURL]];
        NSString *text = [NSString stringWithFormat:@"%@\n\n%@", product.title, product.description];
        
        // setting values...
        [self.lipProductImage setImage:productImage];
        [self.lipProductColorSwatch setBackgroundColor:product.color];
        [self.scrollLipsBrand setText:product.brandName];
        [self.scrollLipsDescription setText:text];
        
        // removing any previous subviews...
        for(UIView *thisView in self.scrollLipsProductBox.subviews)
        {
            [thisView removeFromSuperview];
        }
        
        // Adding product Box...
        ProductBoxView *productBoxView = [[ProductBoxView alloc]
                                          initWithProduct:product
                                          withPosx:0
                                          withPosy:0
                                          withWidth:self.scrollLipsProductBox.frame.size.width
                                          withHeight:self.scrollLipsProductBox.frame.size.height
                                          withViewController:self];
        [self.scrollLipsProductBox addSubview:productBoxView];
    }
    
    else
    {
        [self.lipProductContainer setHidden:YES];
        [self.scrollLipsContainer setHidden:YES];
    }
}

- (void) refreshEyeProductViews
{
    if(self.eyeProductArray.count != 0)
    {
        [self.eyeProductContainer setHidden:NO];
        [self.scrollEyesContainer setHidden:NO];
        
        // getting values...
        CMProductMap *product = [self.eyeProductArray objectAtIndex:self.currentEyeProductPositionInArray];
        UIImage *productImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:product.imageURL]];
        NSString *text = [NSString stringWithFormat:@"%@\n\n%@", product.title, product.description];
        
        // setting values...
        [self.eyeProductImage setImage:productImage];
        [self.eyeProductColorSwatch setBackgroundColor:product.color];
        [self.scrollEyeBrand setText:product.brandName];
        [self.scrollEyeDescription setText:text];
        
        
        // removing any previous subviews...
        for(UIView *thisView in self.scrollEyesProductBox.subviews)
        {
            [thisView removeFromSuperview];
        }
        
        // Adding product Box...
        ProductBoxView *productBoxView = [[ProductBoxView alloc]
                                          initWithProduct:product
                                          withPosx:0
                                          withPosy:0
                                          withWidth:self.scrollEyesProductBox.frame.size.width
                                          withHeight:self.scrollEyesProductBox.frame.size.height
                                          withViewController:self];
        [self.scrollEyesProductBox addSubview:productBoxView];
    }
    
    else
    {
        [self.eyeProductContainer setHidden:YES];
        [self.scrollEyesContainer setHidden:YES];
    }
}


- (void) refreshBlushProductViews
{
    if(self.blushProductArray.count != 0)
    {
        [self.blushProductContainer setHidden:NO];
        [self.scrollBlushContainer setHidden:NO];
        
        // getting values...
        CMProductMap *product = [self.blushProductArray objectAtIndex:self.currentBlushProductPositionInArray];
        UIImage *productImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:product.imageURL]];
        NSString *text = [NSString stringWithFormat:@"%@\n\n%@", product.title, product.description];
        
        // setting values...
        [self.blushProductImage setImage:productImage];
        [self.blushProductColorSwatch setBackgroundColor:product.color];
        [self.scrollBlushBrand setText:product.brandName];
        [self.scrollBlushDescription setText:text];
        
        // removing any previous subviews...
        for(UIView *thisView in self.scrollBlushProductBox.subviews)
        {
            [thisView removeFromSuperview];
        }
        
        // Adding product Box...
        ProductBoxView *productBoxView = [[ProductBoxView alloc]
                                          initWithProduct:product
                                          withPosx:0
                                          withPosy:0
                                          withWidth:self.scrollBlushProductBox.frame.size.width
                                          withHeight:self.scrollBlushProductBox.frame.size.height
                                          withViewController:self];
        [self.scrollBlushProductBox addSubview:productBoxView];
    }
    
    else
    {
        [self.blushProductContainer setHidden:YES];
        [self.scrollBlushContainer setHidden:YES];
    }
}


- (void) refreshFaceProductViews
{
    if(self.faceProductArray.count != 0)
    {
        [self.faceProductContainer setHidden:NO];
        [self.scrollFaceContainer setHidden:NO];
        
        // getting values...
        CMProductMap *product = [self.faceProductArray objectAtIndex:self.currentFaceProductPositionInArray];
        UIImage *productImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:product.imageURL]];
        NSString *text = [NSString stringWithFormat:@"%@\n\n%@", product.title, product.description];
        
        // setting values...
        [self.faceProductImage setImage:productImage];
        [self.faceProductColorSwatch setBackgroundColor:product.color];
        [self.scrollFaceBrand setText:product.brandName];
        [self.scrollFaceDescription setText:text];
        
        // removing any previous subviews...
        for(UIView *thisView in self.scrollFaceProductBox.subviews)
        {
            [thisView removeFromSuperview];
        }
        
        // Adding product Box...
        ProductBoxView *productBoxView = [[ProductBoxView alloc]
                                          initWithProduct:product
                                          withPosx:0
                                          withPosy:0
                                          withWidth:self.scrollFaceProductBox.frame.size.width
                                          withHeight:self.scrollFaceProductBox.frame.size.height
                                          withViewController:self];
        [self.scrollFaceProductBox addSubview:productBoxView];
    }
    
    else
    {
        [self.faceProductContainer setHidden:YES];
        [self.scrollFaceContainer setHidden:YES];
    }
}
#pragma mark-




#pragma mark SCROLL LEFT & RIGHT
// Methods to scroll the products...
- (IBAction)scrollLipProductsLeft {
    [self scrollLipProductByCount:-1];
}
- (IBAction)scrollLipProductRight:(id)sender {
    [self scrollLipProductByCount:1];
}
- (void) scrollLipProductByCount: (int) count
{
    self.currentLipProductPositionInArray = [self getNewPositionFromCurrentPosition: self.currentLipProductPositionInArray
                                                                            WithMax:self.lipsProductArray.count
                                                                          AndMoveBy:count];
    [self refreshLipProductViews];
}


- (IBAction)scrollEyeProductLeft:(id)sender {
    [self scrollEyeProductByCount:-1];
}
- (IBAction)scrollEyeProductRight:(id)sender {
    [self scrollEyeProductByCount:1];
}
- (void) scrollEyeProductByCount:(int) count
{
    self.currentEyeProductPositionInArray =
    [self getNewPositionFromCurrentPosition: self.currentEyeProductPositionInArray
                                    WithMax: self.eyeProductArray.count
                                  AndMoveBy: count];
    [self refreshEyeProductViews];
}


- (IBAction)scrollBlushProductLeft:(id)sender
{
    [self scrollBlushProductByCount:-1];
}
- (IBAction)scrollBlushProductRight:(id)sender
{
    [self scrollBlushProductByCount:1];
}
- (void) scrollBlushProductByCount:(int) count
{
    self.currentBlushProductPositionInArray =
    [self getNewPositionFromCurrentPosition: self.currentBlushProductPositionInArray
                                    WithMax: self.blushProductArray.count
                                  AndMoveBy: count];
    [self refreshBlushProductViews];
}


- (IBAction)scrollFaceProductLeft:(id)sender {
    [self scrollFaceProductByCount:-1];
}
- (IBAction)scrollFaceProductRight:(id)sender {
    [self scrollFaceProductByCount:1];
}
-(void) scrollFaceProductByCount: (int) count
{
    self.currentFaceProductPositionInArray = [self getNewPositionFromCurrentPosition: self.currentFaceProductPositionInArray
                                                                             WithMax:self.faceProductArray.count
                                                                           AndMoveBy:count];
    [self refreshFaceProductViews];
}
#pragma mark-




#pragma mark BUTTON PRESS
- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark-




#pragma mark WISHLIST FUNCTIONALITY
/*
 Wishlist finctionality...
 */
- (IBAction)wishlistbuttonPressed:(id)sender
{
    if(self.wishlistButton.isSelected)
    {
        // Remove all the 3 products to wishlist...
        [self toggleWishlistForProduct:[self.faceProductArray objectAtIndex:self.currentFaceProductPositionInArray]
                            performAdd: NO];
        
        [self toggleWishlistForProduct:[self.eyeProductArray objectAtIndex:self.currentEyeProductPositionInArray]
                            performAdd:NO];
        
        [self toggleWishlistForProduct:[self.lipsProductArray objectAtIndex:self.currentLipProductPositionInArray]
                            performAdd:NO];
        [SVProgressHUD showSuccessWithStatus:REMOVE_FROM_WISHLIST];
        
        // To toggle the state...
        [self.wishlistButton setSelected:NO];
    }
    else
    {
        // Add all the 3 products to wishlist...
        // Remove all the 3 products to wishlist...
        [self toggleWishlistForProduct:[self.faceProductArray objectAtIndex:self.currentFaceProductPositionInArray]
                            performAdd: YES];
        
        [self toggleWishlistForProduct:[self.eyeProductArray objectAtIndex:self.currentEyeProductPositionInArray]
                            performAdd:YES];
        
        [self toggleWishlistForProduct:[self.lipsProductArray objectAtIndex:self.currentLipProductPositionInArray]
                            performAdd:YES];
        [SVProgressHUD showSuccessWithStatus:ADDED_TO_WISHLIST];
        
        // To toggle the state...
        [self.wishlistButton setSelected:YES];
    }
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
#pragma mark-




#pragma mark SHARE FUNCTIONALITY
/*
 Share functionality...
 */
- (void) shareProducts: (NSArray *) productArray
{
    
    [self.view addSubview:[[ShareFunctionalityView alloc]
                           initWithProductArray:productArray
                           WithSuperViewController:self
                           WithViewPosition:VIEW_LOCATION_BOTTOM]];
}


- (IBAction)shareButtonPressed:(id)sender {
    NSArray *productArray = [NSArray arrayWithObjects:
                             [self.eyeProductArray objectAtIndex:self.currentEyeProductPositionInArray],
                             [self.faceProductArray objectAtIndex:self.currentFaceProductPositionInArray],
                             [self.lipsProductArray objectAtIndex:self.currentLipProductPositionInArray], nil];
    
    [self shareProducts: productArray];
    
}


- (IBAction)scrollLipShareButtonPressed:(id)sender
{
    [self shareProducts:[NSArray arrayWithObject:[self.lipsProductArray objectAtIndex:self.currentLipProductPositionInArray]]];
}
- (IBAction)scrollEyeShareButtonPressed:(id)sender
{
    [self shareProducts:[NSArray arrayWithObject:[self.eyeProductArray objectAtIndex:self.currentEyeProductPositionInArray]]];
}
- (IBAction)scrollFaceShareButtonPressed:(id)sender
{
    [self shareProducts:[NSArray arrayWithObject:[self.faceProductArray objectAtIndex:self.currentFaceProductPositionInArray]]];
}
#pragma mark-




#pragma mark UTILITY METHODS
- (int) getNewPositionFromCurrentPosition: (int) current
                                  WithMax: (int) maxSize
                                AndMoveBy: (int) change
{
    int newPosition = current + change;
    
    if(newPosition < 0){
        newPosition = maxSize - 1;
    }
    
    if(newPosition == maxSize)
    {
        newPosition = 0;
    }
    
    return newPosition;
}


/*
 Methods to segue to product detail page...
 */
-(void)tapAction: (UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view];
    self.selectedTag = view.tag;
    [self performSegueWithIdentifier: @"viewProductDetails" sender: self];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"viewProductDetails"])
    {
        CMProductDetailsViewController *productDetailsViewController =
        (CMProductDetailsViewController *)[segue destinationViewController];
        
        if(self.selectedTag == 1)
        {
            [productDetailsViewController setProduct_list:
             [NSMutableArray arrayWithArray:self.lipsProductArray]];
            [productDetailsViewController setStarting_index:self.currentLipProductPositionInArray];
            [productDetailsViewController setCurrentProductCategory: @"Lipstick"];
        }
        
        if (self.selectedTag == 2)
        {
            [productDetailsViewController setProduct_list:[NSMutableArray arrayWithArray:self.eyeProductArray]];
            [productDetailsViewController setStarting_index:self.currentEyeProductPositionInArray];
            [productDetailsViewController setCurrentProductCategory:@"Eye Shadow"];
        }
        if (self.selectedTag == 3)
        {
            [productDetailsViewController setProduct_list:[NSMutableArray arrayWithArray:self.blushProductArray]];
            [productDetailsViewController setStarting_index:self.currentBlushProductPositionInArray];
            [productDetailsViewController setCurrentProductCategory:@"Blush"];
        }
        if (self.selectedTag == 4)
        {
            [productDetailsViewController setProduct_list:[NSMutableArray arrayWithArray:self.faceProductArray]];
            [productDetailsViewController setStarting_index:self.currentFaceProductPositionInArray];
            [productDetailsViewController setCurrentProductCategory:@"Foundation"];
        }
    }
}
#pragma mark-




- (void)viewDidUnload
{
    [self setControlBox:nil];
    [self setLipProductImage:nil];
    [self setLipProductColorSwatch:nil];
    [self setLipProductContainer:nil];
    [self setEyeProductContainer:nil];
    [self setEyeProductImage:nil];
    [self setEyeProductColorSwatch:nil];
    [self setFaceProductContainer:nil];
    [self setFaceProductImage:nil];
    [self setFaceProductColorSwatch:nil];
    [self setScrollView:nil];
    [self setScrollLipsBrand:nil];
    [self setScrollLipsDescription:nil];
    [self setScrollEyeBrand:nil];
    [self setScrollEyeDescription:nil];
    [self setWishlistButton:nil];
    [self setScrollLipsContainer:nil];
    [self setScrollEyesContainer:nil];
    [self setScrollFaceContainer:nil];
    [self setBlushProductContainer:nil];
    [self setBlushProductImage:nil];
    [self setBlushProductColorSwatch:nil];
    [self setScrollBlushContainer:nil];
    [self setScrollBlushBrand:nil];
    [self setScrollBlushProductBox:nil];
    [self setScrollBlushDescription:nil];
    [self setScrollLipsProductBox:nil];
    [self setScrollEyesProductBox:nil];
    [self setScrollFaceProductBox:nil];
    [self setScrollLipsButtonLeft:nil];
    [self setScrollLipsButtonRight:nil];
    [super viewDidUnload];
}


@end





