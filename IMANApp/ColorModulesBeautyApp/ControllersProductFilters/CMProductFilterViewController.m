//
//  CMProductFilterViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 10/24/12.
//
//

#import "CMProductFilterViewController.h"
#import "CMProductFilterDetailsViewController.h"
#import "AFJSONRequestOperation.h"
#import "CMConstants.h"
#import "Logging.h"
#import "LightBox2.h"

#import "ProductFilterCellView.h"
#import "ProductFilterPriceView.h"
#import "ProductFilterMatchView.h"

#import "CMFilterModel.h"
#import "FilterProductTypeMap.h"
#import "FilterNameMap.h"
#import "NMRangeSlider.h"

@interface CMProductFilterViewController ()

// Navigation tab...
@property (strong, nonatomic) IBOutlet UIButton *lipButton;
@property (strong, nonatomic) IBOutlet UIButton *eyeButton;
@property (strong, nonatomic) IBOutlet UIButton *faceButton;
@property (strong, nonatomic) IBOutlet UIImageView *categoryPointerImage;

// Lip Scroll View...

@property (strong, nonatomic) IBOutlet UIScrollView *lipScrollView;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *lipBrands;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *lipCategories;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *lipFormulation;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *lipLook;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *lipSeller;
@property (strong, nonatomic) IBOutlet ProductFilterPriceView *lipPrice;

// Eye scroll View...
@property (strong, nonatomic) IBOutlet UIScrollView *eyeScrollView;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *eyeBrands;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *eyeCategories;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *eyeCoverage;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *eyeFormulation;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *eyeLook;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *eyeTexture;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *eyeSellers;
@property (strong, nonatomic) IBOutlet ProductFilterPriceView *eyePrice;

// Face Scroll View...
@property (strong, nonatomic) IBOutlet UIScrollView *faceScrollView;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *faceBrands;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *faceCategories;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *faceFormulation;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *faceCoverage;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *faceSkinType;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *faceTexture;
@property (strong, nonatomic) IBOutlet ProductFilterCellView *faceSellers;
@property (strong, nonatomic) IBOutlet ProductFilterPriceView *facePrice;
@property (strong, nonatomic) IBOutlet ProductFilterMatchView *faceMatch;

// Other properties...
@property (strong, nonatomic) CMFilterModel *filterModel;
@property (strong, nonatomic) NSString *filterNameSelected;

@end



@implementation CMProductFilterViewController
@synthesize lipButton = _lipButton;
@synthesize eyeButton = _eyeButton;
@synthesize faceButton = _faceButton;
@synthesize categoryPointerImage = _categoryPointerImage;
@synthesize filterModel = _filterModel;


#pragma mark-
#pragma mark INITIALIZATION
-(void) initializeFilters
{
    _filterModel = [[CMFilterModel alloc] init];
}
#pragma mark-

#pragma mark LIFECYCLE
-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // Setting tap gestures...
    [self setGestures];
    
    // Setting scroll views..
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    [self.lipScrollView setHidden:YES];
    [self.lipScrollView setUserInteractionEnabled:YES];
    [self.lipScrollView setScrollEnabled:YES];
    [self.lipScrollView setContentSize:CGSizeMake(screenWidth, 460)];
    
    [self.eyeScrollView setHidden:YES];
    [self.eyeScrollView setUserInteractionEnabled:YES];
    [self.eyeScrollView setScrollEnabled:YES];
    [self.eyeScrollView setContentSize:CGSizeMake(screenWidth, 460)];
    
    [self.faceScrollView setHidden:YES];
    [self.faceScrollView setUserInteractionEnabled:YES];
    [self.faceScrollView setScrollEnabled:YES];
    [self.faceScrollView setContentSize:CGSizeMake(screenWidth, 460)];
    
    // Setting price filters...
    FilterProductTypeMap *productFilter = [self.filterModel getProductTypeMapForProductTypeID:productTypeIdForLips];
    [self.lipPrice configureWithMinimumValue:productFilter.minPrice
                            WithMaximumValue:productFilter.maxPrice
                              WithLowerValue:productFilter.currentMinPrice
                              WithUpperValue:productFilter.currentMaxPrice];
    
    productFilter = [self.filterModel getProductTypeMapForProductTypeID:productTypeIdForEyes];
    [self.eyePrice configureWithMinimumValue:productFilter.minPrice
                            WithMaximumValue:productFilter.maxPrice
                              WithLowerValue:productFilter.currentMinPrice
                              WithUpperValue:productFilter.currentMaxPrice];
    
    productFilter = [self.filterModel getProductTypeMapForProductTypeID:productTypeIdForFace];
    [self.facePrice configureWithMinimumValue:productFilter.minPrice
                             WithMaximumValue:productFilter.maxPrice
                               WithLowerValue:productFilter.currentMinPrice
                               WithUpperValue:productFilter.currentMaxPrice];
    
    // Setting face match filters...
    [self.faceMatch configureWithMinimumVariance:productFilter.minVariance
                             WithMaximumVariance:productFilter.maxVariance
                                WithCurrentValue:productFilter.currentVariance];
    
    // To free the memory...
    productFilter = nil;
    
    // To configure the view...
    [self  configureView];
    [self.lipButton setSelected:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([self.lipButton isSelected])
    {
        [self lipButtonPressed];
    }
    
    if([self.eyeButton isSelected])
    {
        [self eyeButtonPressed:self];
    }
    
    if([self.faceButton isSelected])
    {
        [self faceButtonPressed:self];
    }
}

#pragma mark-


#pragma mark VIEW CONFIGURATIONS
- (void) configureView
{
    //register color
    //UIColor *highlightColor = [UIColor colorWithRed:132/255.0f green:20/255.0f blue:60/255.0f alpha:1.0f];
    UIColor *highlightColor = [UIColor blackColor];
    UIColor *normalColor = [UIColor grayColor];
    
    [self.lipButton setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.lipButton setTitleColor:normalColor forState:UIControlStateNormal];
    [self.lipButton setSelected:YES];
    
    [self.eyeButton setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.eyeButton setTitleColor:normalColor forState:UIControlStateNormal];
    [self.eyeButton setSelected:NO];
    
    [self.faceButton setTitleColor:highlightColor forState:UIControlStateSelected];
    [self.faceButton setTitleColor:normalColor forState:UIControlStateNormal];
    [self.faceButton setSelected:NO];
}

- (void) setGestures
{
    // Setting Tap gestures for Lip filters...
    UITapGestureRecognizer *tapGestureRecognizer;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.lipBrands addGestureRecognizer:tapGestureRecognizer];
    [self.lipBrands setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.lipCategories addGestureRecognizer:tapGestureRecognizer];
    [self.lipCategories setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.lipFormulation addGestureRecognizer:tapGestureRecognizer];
    [self.lipFormulation setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.lipLook addGestureRecognizer:tapGestureRecognizer];
    [self.lipLook setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.lipSeller addGestureRecognizer:tapGestureRecognizer];
    [self.lipSeller setUserInteractionEnabled:YES];
    
    
    // Setting tap gestures for eye filters...
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.eyeBrands addGestureRecognizer:tapGestureRecognizer];
    [self.eyeBrands setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.eyeCategories addGestureRecognizer:tapGestureRecognizer];
    [self.eyeCategories setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.eyeCoverage addGestureRecognizer:tapGestureRecognizer];
    [self.eyeCoverage setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.eyeFormulation addGestureRecognizer:tapGestureRecognizer];
    [self.eyeFormulation setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.eyeLook addGestureRecognizer:tapGestureRecognizer];
    [self.eyeLook setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.eyeSellers addGestureRecognizer:tapGestureRecognizer];
    [self.eyeSellers setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.eyeTexture addGestureRecognizer:tapGestureRecognizer];
    [self.eyeTexture setUserInteractionEnabled:YES];
    
    
    // Setting tap gestures for Face filters...
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.faceBrands addGestureRecognizer:tapGestureRecognizer];
    [self.faceBrands setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.faceCategories addGestureRecognizer:tapGestureRecognizer];
    [self.faceCategories setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.faceCoverage addGestureRecognizer:tapGestureRecognizer];
    [self.faceCoverage setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.faceFormulation addGestureRecognizer:tapGestureRecognizer];
    [self.faceFormulation setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.faceSellers addGestureRecognizer:tapGestureRecognizer];
    [self.faceSellers setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.faceSkinType addGestureRecognizer:tapGestureRecognizer];
    [self.faceSkinType setUserInteractionEnabled:YES];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterNamePressed:)];
    [self.faceTexture addGestureRecognizer:tapGestureRecognizer];
    [self.faceTexture setUserInteractionEnabled:YES];
}
#pragma mark-


#pragma mark BUTTON PRESS
- (IBAction)lipButtonPressed {
    // Setting category pointer...
    float x = self.lipButton.center.x;
    float y = self.categoryPointerImage.center.y;
    [self.categoryPointerImage setCenter:CGPointMake(x, y)];
    
    // setting button selected...
    [self.lipButton setSelected:YES];
    [self.eyeButton setSelected:NO];
    [self.faceButton setSelected:NO];
    
    // setting scroll views...
    [self.lipScrollView setHidden:NO];
    [self.eyeScrollView setHidden:YES];
    [self.faceScrollView setHidden:YES];
    
    // scroll to top...
    [self.lipScrollView scrollRectToVisible:CGRectMake(0, 0,
                                                       self.lipScrollView.frame.size.width,
                                                       self.lipScrollView.frame.size.height)
                                   animated:YES];
    
    // Getting and Setting selected filters...
    NSDictionary *selectedValuesWithFilterNames = [self.filterModel
                                                   getSelectedValuesWithFilterNamesForProductTypeID:productTypeIdForLips];
    
    self.lipBrands.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                valueForKey:self.lipBrands.labelFilterName.text];
    self.lipCategories.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                    valueForKey:self.lipCategories.labelFilterName.text];
    self.lipFormulation.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                     valueForKey:self.lipFormulation.labelFilterName.text];
    self.lipLook.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                              valueForKey:self.lipLook.labelFilterName.text];
    self.lipSeller.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                valueForKey:self.lipSeller.labelFilterName.text];
    
    // setting button sizes...
    [self.lipButton.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:16.0]];
    [self.eyeButton.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:15.0]];
    [self.faceButton.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
}


- (IBAction)eyeButtonPressed:(id)sender {
    // Setting category pointer...
    float x = self.eyeButton.center.x;
    float y = self.categoryPointerImage.center.y;
    [self.categoryPointerImage setCenter:CGPointMake(x, y)];
    
    // setting button selected...
    [self.lipButton setSelected:NO];
    [self.eyeButton setSelected:YES];
    [self.faceButton setSelected:NO];
    
    // setting scroll views...
    [self.lipScrollView setHidden:YES];
    [self.eyeScrollView setHidden:NO];
    [self.faceScrollView setHidden:YES];
    
    // scroll to top...
    [self.eyeScrollView scrollRectToVisible:CGRectMake(0, 0,
                                                       self.eyeScrollView.frame.size.width,
                                                       self.eyeScrollView.frame.size.height)
                                   animated:YES];
    
    // Getting and Setting selected filters...
    NSDictionary *selectedValuesWithFilterNames = [self.filterModel getSelectedValuesWithFilterNamesForProductTypeID:productTypeIdForEyes];
    
    self.eyeBrands.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                valueForKey:self.eyeBrands.labelFilterName.text];
    self.eyeCategories.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                    valueForKey:self.eyeCategories.labelFilterName.text];
    self.eyeCoverage.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                  valueForKey:self.eyeCoverage.labelFilterName.text];
    self.eyeFormulation.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                     valueForKey:self.eyeFormulation.labelFilterName.text];
    self.eyeLook.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                              valueForKey:self.eyeLook.labelFilterName.text];
    self.eyeSellers.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                 valueForKey:self.eyeSellers.labelFilterName.text];
    self.eyeTexture.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                 valueForKey:self.eyeTexture.labelFilterName.text];
    
    // setting button sizes...
    [self.lipButton.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
    [self.eyeButton.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:16.0]];
    [self.faceButton.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
    
}


- (IBAction)faceButtonPressed:(id)sender {
    // Setting category pointer...
    float x = self.faceButton.center.x;
    float y = self.categoryPointerImage.center.y;
    [self.categoryPointerImage setCenter:CGPointMake(x, y)];
    
    // setting button selected...
    [self.lipButton setSelected:NO];
    [self.eyeButton setSelected:NO];
    [self.faceButton setSelected:YES];
    
    // setting scroll views...
    [self.lipScrollView setHidden:YES];
    [self.eyeScrollView setHidden:YES];
    [self.faceScrollView setHidden:NO];
    
    // scroll to top...
    [self.faceScrollView scrollRectToVisible:CGRectMake(0, 0,
                                                        self.faceScrollView.frame.size.width,
                                                        self.faceScrollView.frame.size.height)
                                    animated:YES];
    
    // Getting and Setting selected filters...
    NSDictionary *selectedValuesWithFilterNames = [self.filterModel getSelectedValuesWithFilterNamesForProductTypeID:productTypeIdForFace];
    
    self.faceBrands.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                 valueForKey:self.faceBrands.labelFilterName.text];
    self.faceCategories.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                     valueForKey:self.faceCategories.labelFilterName.text];
    self.faceFormulation.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                      valueForKey:self.faceFormulation.labelFilterName.text];
    self.faceCoverage.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                   valueForKey:self.faceCoverage.labelFilterName.text];
    self.faceSkinType.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                   valueForKey:self.faceSkinType.labelFilterName.text];
    self.faceTexture.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                  valueForKey:self.faceTexture.labelFilterName.text];
    self.faceSellers.labelSelectedFilters.text = [selectedValuesWithFilterNames
                                                  valueForKey:self.faceSellers.labelFilterName.text];
    
    // setting button sizes...
    [self.lipButton.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
    [self.eyeButton.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:15.0]];
    [self.faceButton.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:16.0]];
}


- (IBAction)clearButtonPressed:(id)sender
{
    [self.filterModel reset];
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (IBAction) backButtonPressed
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}
#pragma mark-



#pragma mark NAVIGATION METHODS
-(void) filterNamePressed: (id) sender
{
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *) sender;
    ProductFilterCellView *cellClickedOn = (ProductFilterCellView *) tapGestureRecognizer.view;
    self.filterNameSelected = cellClickedOn.labelFilterName.text;
    [self performSegueWithIdentifier:@"goFilterDetails" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"goFilterDetails"])
    {
        CMProductFilterDetailsViewController *productFilterDetailsViewController = (CMProductFilterDetailsViewController *)[segue destinationViewController];
        
        NSArray *filterValues;
        if(self.lipButton.isSelected)
        {
            filterValues = [self.filterModel getFilterValuesForFilterNameTitle:self.filterNameSelected
                                                              ForProductTypeID:productTypeIdForLips];
        }
        if(self.eyeButton.isSelected)
        {
            filterValues = [self.filterModel getFilterValuesForFilterNameTitle:self.filterNameSelected
                                                              ForProductTypeID:productTypeIdForEyes];
        }
        if(self.faceButton.isSelected)
        {
            filterValues = [self.filterModel getFilterValuesForFilterNameTitle:self.filterNameSelected
                                                              ForProductTypeID:productTypeIdForFace];
        }
        
        [productFilterDetailsViewController myInitializeWithThisViewName:self.filterNameSelected
                                                         withFilterModel:self.filterModel
                                            withDictionaryOfFilterArrays:filterValues];
    }
}
#pragma mark-



#pragma mark END OF LIFECYCLE
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.filterModel setCurrentMinPrice:(self.lipPrice.slider.lowerValue * 100)
                      AndCurrentMaxPrice:(self.lipPrice.slider.upperValue * 100)
                        ForProductTypeID:productTypeIdForLips];
    
    [self.filterModel setCurrentMinPrice:(self.eyePrice.slider.lowerValue * 100)
                      AndCurrentMaxPrice:(self.eyePrice.slider.upperValue * 100)
                        ForProductTypeID:productTypeIdForEyes];
    
    [self.filterModel setCurrentMinPrice:(self.facePrice.slider.lowerValue * 100)
                      AndCurrentMaxPrice:(self.facePrice.slider.upperValue * 100)
                        ForProductTypeID:productTypeIdForFace];
    
    [self.filterModel setCurrentVariance:self.faceMatch.slider.value];
    
    [self.filterModel synchronize];
}


- (void)didReceiveMemoryWarning
{
    [self setLipButton:nil];
    [self setEyeButton:nil];
    [self setFaceButton:nil];
    [self setCategoryPointerImage:nil];
    [self setLipScrollView:nil];
    [self setLipBrands:nil];
    [self setLipCategories:nil];
    [self setLipFormulation:nil];
    [self setLipLook:nil];
    [self setLipSeller:nil];
    [self setLipPrice:nil];
    [self setFaceScrollView:nil];
    [self setFaceBrands:nil];
    [self setFaceCategories:nil];
    [self setFaceFormulation:nil];
    [self setFaceCoverage:nil];
    [self setFaceSkinType:nil];
    [self setFaceTexture:nil];
    [self setFaceSellers:nil];
    [self setFacePrice:nil];
    [self setFaceMatch:nil];
    [self setEyeScrollView:nil];
    [self setEyeBrands:nil];
    [self setEyeCategories:nil];
    [self setEyeCoverage:nil];
    [self setEyeFormulation:nil];
    [self setEyeLook:nil];
    [self setEyeTexture:nil];
    [self setEyeSellers:nil];
    [self setEyePrice:nil];
    [self setLipButton:nil];
}
#pragma mark-

@end
