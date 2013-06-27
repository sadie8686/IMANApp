/*--------------------------------------------------------------------------
 CMBeautyFirstViewController.m
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar
 
 Created by Abhijit Sarkar on 2012/01/24
 
 Description:
 This is the PROFILE view.
 Code for first tab view that returning users see.
 
 Revision history:
 2012/01/27 - by AS
 
 Existing Problems:
 (date) -
 
 (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/

#import "CMMyProfileViewController.h"
#import "ColorUtility.h"
#import "CMUserModel.h"
#import "UIImageView+AFNetworking.h"
#import "CMConstants.h"
#import "ColorUtility.h"
#import "Logging.h"
#import "QuartzCore/QuartzCore.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "CMApplicationModel.h"
#import "Logging.h"

// all delegate view controllers must be included here
@interface CMMyProfileViewController ()
@property (strong, nonatomic) CMUserModel *userModel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UIView *hairColorView;
@property (weak, nonatomic) IBOutlet UILabel *hairColorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *hairColorEditLabel;
@property (weak, nonatomic) IBOutlet UILabel *hairColorSignatureLabel;
@property (strong, nonatomic) IBOutlet UIImageView *hairColorErrorSign;

@property (weak, nonatomic) IBOutlet UIView *eyeColorView;
@property (weak, nonatomic) IBOutlet UILabel *eyeColorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *eyeColorEditLabel;
@property (weak, nonatomic) IBOutlet UILabel *eyeColorSignatureLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eyeColorErrorSign;

@property (weak, nonatomic) IBOutlet UIView *lipColorView;
@property (weak, nonatomic) IBOutlet UILabel *lipColorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *lipColorEditLabel;
@property (weak, nonatomic) IBOutlet UILabel *lipColorSignatureLabel;
@property (strong, nonatomic) IBOutlet UIImageView *lipColorErrorSign;

@property (weak, nonatomic) IBOutlet UIView *skinColorView;
@property (weak, nonatomic) IBOutlet UILabel *skinColorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *skinColorEditLabel;
@property (weak, nonatomic) IBOutlet UILabel *skinColorSignatureLabel;
@property (strong, nonatomic) IBOutlet UIImageView *skinColorErrorSign;

@property (weak, nonatomic) IBOutlet UIView *customSliderContainer;
@property (weak, nonatomic) IBOutlet UIView *customSlider;
@property (weak, nonatomic) UIView *customSliderPointer;
@property (weak, nonatomic) UIView *customSliderConnector;
@property (weak, nonatomic) UIColor *skinColor;
@property BOOL skinColorDidChange;


@property (weak, nonatomic) IBOutlet UILabel *colorCorrectLabel;
@property (weak, nonatomic) IBOutlet UISwitch *colorCorrectSwitch;
@property (strong, nonatomic) NSDictionary *colorCorrectedColors;

@property (strong, nonatomic) UIColor *swapEyeColor;
@property (strong, nonatomic) UIColor *swapSkinColor;
@property (strong, nonatomic) UIColor *swapLipsColor;
@property (strong, nonatomic) UIColor *swapHairColor;

@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UIView *floatingMessageView;

@property (weak, nonatomic) IBOutlet UIView *bottomFrameView;
@property (weak, nonatomic) IBOutlet UIButton *myTopPicksButton;
@property (strong, nonatomic) IBOutlet UIButton *browseProductsButton;


@end


@implementation CMMyProfileViewController

@synthesize profileImage = _profileImage;
@synthesize hairColorView = _hairColorView;
@synthesize hairColorTextLabel = _hairColorTextLabel;
@synthesize hairColorEditLabel = _hairColorEditLabel;
@synthesize hairColorSignatureLabel = _hairColorSignatureLabel;
@synthesize eyeColorView = _eyeColorView;
@synthesize eyeColorTextLabel = _eyeColorTextLabel;
@synthesize eyeColorEditLabel = _eyeColorEditLabel;
@synthesize eyeColorSignatureLabel = _eyeColorSignatureLabel;
@synthesize lipColorView = _lipColorView;
@synthesize lipColorTextLabel = _lipColorTextLabel;
@synthesize lipColorEditLabel = _lipColorEditLabel;
@synthesize lipColorSignatureLabel = _lipColorSignatureLabel;
@synthesize skinColorView = _skinColorView;
@synthesize skinColorTextLabel = _skinColorTextLabel;
@synthesize skinColorEditLabel = _skinColorEditLabel;
@synthesize skinColorSignatureLabel = _skinColorSignatureLabel;
@synthesize customSliderContainer = _customSliderContainer;
@synthesize customSlider = _customSlider;
@synthesize customSliderPointer = _customSliderPointer;
@synthesize customSliderConnector = _customSliderConnector;
@synthesize skinColor = _skinColor;
@synthesize skinColorDidChange = _skinColorDidChange;
@synthesize colorCorrectSwitch = _colorCorrectSwitch;
@synthesize swapEyeColor = _swapEyeColor;
@synthesize swapHairColor = _swapHairColor;
@synthesize swapLipsColor = _swapLipsColor;
@synthesize swapSkinColor = _swapSkinColor;
@synthesize userModel = _userModel;
@synthesize textLabel,floatingMessageView,bottomFrameView,myTopPicksButton;

float r, g, b, a, rLow, gLow, bLow, rHigh, gHigh, bHigh;


-(void) viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBadLightingMessage) name:@"lightingBad" object:nil];
    
    self.userModel = [[CMUserModel alloc] initForUserProfile];
    CMUserProfileMap *userData = [self.userModel getUserProfileMapObject];
    
    
    CMApplicationModel *applicationModel = [[CMApplicationModel alloc] init];
    NSData* imageData = [applicationModel getOriginalImage];
    UIImage* originImage = [UIImage imageWithData:imageData];
    
    if (originImage)
    {
        [self.profileImage setImage:originImage];
    }
    else
    {
        [self.profileImage setImageWithURL:userData.imageURL];
    }
    
    self.skinColorDidChange = NO;
    if([applicationModel toColorCorrect])
    {
        self.swapSkinColor = [applicationModel colorCorrectedSkinColor];
        self.swapEyeColor = [applicationModel colorCorrectedEyeColor];
        self.swapHairColor = [applicationModel colorCorrectedHairColor];
        self.swapLipsColor = [applicationModel colorCorrectedLipColor];
        
        // To set the color correct switch on or off...
        if([applicationModel isColorCorrectSwitchOn])
        {
            [self.colorCorrectSwitch setOn:YES];
        }
        else
        {
            [self.colorCorrectSwitch setOn:NO];
        }
        [self.colorCorrectLabel setHidden:NO];
        [self.colorCorrectSwitch setHidden:NO];
    }
    
    else
    {
        [self.colorCorrectLabel setHidden:YES];
        [self.colorCorrectSwitch setHidden:YES];
        
        [self.myTopPicksButton setFrame:CGRectMake(10, 13, 145, 40)];
        [self.browseProductsButton setFrame:CGRectMake(165, 13, 145, 40)];
    }
    applicationModel = nil;
    
    //NSLog(@"userModel.image: %@", [self.userModel getUserProfileMapObject].imageURL);
    
    NSLog(@"userModel.image: %@", [self.userModel getUserProfileMapObject].originalImageURL);
    
    // update colors...
    [self updateColors];
    
    // To Add the custom slider...
    [self addCustomSliderSkinColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.userModel = [[CMUserModel alloc] initForUserProfile];
    [self updateColors];
    [self addCustomSliderSkinColor];
}

- (IBAction)colorCorrectSwitchToggled
{
    
     LogInfo(@"Color correction toggled");
    // To update the user colors...
    CMUserProfileMap *userData = [self.userModel getUserProfileMapObject];
    userData.eyesColor = self.swapEyeColor;
    userData.hairColor = self.swapHairColor;
    userData.lipsColor = self.swapLipsColor;
    userData.skinColor = self.swapSkinColor;
    
    // To save the old colors...
    self.swapEyeColor = self.eyeColorView.backgroundColor;
    self.swapHairColor = self.hairColorView.backgroundColor;
    self.swapLipsColor = self.lipColorView.backgroundColor;
    self.swapSkinColor = self.skinColorView.backgroundColor;
    
    [self updateServerForEditColors];
    [self updateColors];
}


-(void) updateColors
{
    CMUserProfileMap *userData = [self.userModel getUserProfileMapObject];
    NSString *errorMsg = @"extraction\nfailed";
    
    UIColor *failColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys: userData.hairColor,@"hairColor",userData.eyesColor,@"eyesColor",userData.lipsColor,@"lipsColor",userData.skinColor,@"skinColor", nil];
    
    LogInfo(@"Color signature get color from back end: %@", userDict);
    
    if (![userData.hairColor isEqual:failColor])
    {
        self.hairColorSignatureLabel.text = [NSString stringWithFormat:@"%@, %@ hair",userData.hairValue, userData.hairTemp];
        [self.hairColorErrorSign setHidden:YES];
    }
    else
    {
        self.hairColorSignatureLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
        [self.hairColorErrorSign setHidden:NO];
    }
    
    if (![userData.eyesColor isEqual:failColor] )
    {
        self.eyeColorSignatureLabel.text = [NSString stringWithFormat:@"%@, %@", userData.eyesChroma, userData.eyesColorName];
        [self.eyeColorErrorSign setHidden:YES];
    }
    else
    {
        self.eyeColorSignatureLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
        [self.eyeColorErrorSign setHidden:NO];
    }
    
    if (![userData.skinColor isEqual:failColor])
    {
        self.skinColorSignatureLabel.text = [NSString stringWithFormat:@"%@ with %@, %@ undertones",userData.skinValue, userData.skinChroma, userData.skinTemp];
        [self.skinColorErrorSign setHidden:YES];
    }
    else
    {
        self.skinColorSignatureLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
        [self.skinColorErrorSign setHidden:NO];
    }
    
    if (![userData.lipsColor isEqual:failColor])
    {
        self.lipColorSignatureLabel.text = [NSString stringWithFormat:@"%@, %@", userData.lipsChroma, userData.lipsColorName];
        [self.lipColorErrorSign setHidden:YES];
    }
    else
    {
        self.lipColorSignatureLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
        [self.lipColorErrorSign setHidden:NO];
    }
    
    self.hairColorView.backgroundColor = userData.hairColor;
    self.eyeColorView.backgroundColor = userData.eyesColor;
    self.lipColorView.backgroundColor = userData.lipsColor;
    self.skinColorView.backgroundColor = self.skinColor = userData.skinColor;
    
    
    [self setTextColorForColor:userData.hairColor ForType:@"hair"];
    [self setTextColorForColor:userData.eyesColor ForType:@"eye"];
    [self setTextColorForColor:userData.lipsColor ForType:@"lip"];
    [self setTextColorForColor:userData.skinColor ForType:@"skin"];
}

- (void) setTextColorForColor: (UIColor *) thisColor
                      ForType: (NSString *) colorType
{
    // Setting Label Text Color. White for darker swatch and Black for lighter swatch.
    CGFloat backgroundRed, backgroundGreen, backgroundBlue;
    [thisColor getRed:&backgroundRed
                green:&backgroundGreen
                 blue:&backgroundBlue
                alpha:nil];
    //R*0.299 + G*0.587 + B*0.114 -- light is higher than 0.5
    CGFloat colorGray = (backgroundRed*0.299) + (backgroundGreen*0.587) + (backgroundBlue*0.144);
    UIColor *textColor;
    
    if(colorGray > 0.45f)
    {
        textColor = [UIColor blackColor];
    }
    else
    {
        textColor = [UIColor whiteColor];
    }
    
    
    if([colorType isEqualToString:@"hair"])
    {
        self.hairColorTextLabel.textColor =
        self.hairColorEditLabel.textColor =
        self.hairColorSignatureLabel.textColor = textColor;
    }
    else if([colorType isEqualToString:@"eye"])
    {
        self.eyeColorTextLabel.textColor =
        self.eyeColorEditLabel.textColor =
        self.eyeColorSignatureLabel.textColor = textColor;
    }
    
    else if([colorType isEqualToString:@"lip"])
    {
        self.lipColorTextLabel.textColor =
        self.lipColorEditLabel.textColor =
        self.lipColorSignatureLabel.textColor = textColor;
    }
    
    else
    {
        self.skinColorTextLabel.textColor =
        self.skinColorEditLabel.textColor =
        self.skinColorSignatureLabel.textColor = textColor;
    }
}


- (void) addCustomSliderSkinColor
{
    // Creating the gradient layer...
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.customSlider.frame;
    [gradient setFrame:CGRectMake(0, self.customSlider.frame.origin.y,
                                  self.customSlider.frame.size.width,
                                  self.customSlider.frame.size.height)];
    
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint = CGPointMake(1, 0.5);
    
    // Getting the color range of skin...
    UIColor *skinColor = self.skinColorView.backgroundColor;
    
    [skinColor getRed:&r green:&g blue:&b alpha:&a];
    UIColor *skinColorLow = [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                                            green:MIN(g + 0.2, 1.0)
                                             blue:MIN(b + 0.2, 1.0)
                                            alpha:a];
    
    UIColor *skinColorHigh = [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                                             green:MAX(g - 0.2, 0.0)
                                              blue:MAX(b - 0.2, 0.0)
                                             alpha:a];
    
    
    [skinColorLow getRed:&rLow green:&gLow blue:&bLow alpha:&a];
    [skinColorHigh getRed:&rHigh green:&gHigh blue:&bHigh alpha:&a];
    
    // Setting the colors on the gradient layer and adding it to the slider...
    gradient.colors = [NSArray arrayWithObjects:(id)[skinColorLow CGColor], (id)[skinColorHigh CGColor], nil];
    [self.customSlider.layer insertSublayer:gradient atIndex:(self.customSlider.layer.sublayers.count)];
    
    // creating pointer above the slider to display the color selected...
    float height = self.customSliderContainer.frame.size.height + 4;
    float width = 8;
    float x = self.customSliderContainer.frame.origin.x + (self.customSliderContainer.frame.size.width / 2) - (width / 2);
    float y = self.customSliderContainer.frame.origin.y - 2;
    
    UIView *pointer = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [pointer setBackgroundColor:skinColor];
    [pointer.layer setBorderWidth:0.6f];
    [pointer.layer setBorderColor:[UIColor blackColor].CGColor];
    self.customSliderPointer = pointer;
    [self.view addSubview:pointer];
    
    
    // Creating a connector to connect the slider to the swatch...
    x = x + (width / 2) - 1 ;
    width = 2;
    y = y - height;
    UIView *connector = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [connector setBackgroundColor:skinColor];
    self.customSliderConnector = connector;
    [self.view addSubview:connector];
}


- (IBAction)handleSliderPan:(UIPanGestureRecognizer *)sender
{
    float prevTranslationX = 0.0;
    CGPoint translation = [(UIPanGestureRecognizer *)sender translationInView:self.customSlider];
    
    float netTranslationX;
    netTranslationX = prevTranslationX + translation.x;
    
    float currentX = self.customSlider.frame.origin.x;
    float newX = currentX + netTranslationX;
    float minX = -self.customSlider.frame.size.width/2;
    float maxX = self.customSliderContainer.frame.size.width - (self.customSlider.frame.size.width /2);
    
    if(newX > minX && newX < maxX)
    {
        sender.view.transform = CGAffineTransformMakeTranslation(netTranslationX, 0);
        [self updateSkinColorSwatch: netTranslationX];
    }
}

- (void) updateSkinColorSwatch: (float) netTranslationX
{
    float lineWidth = self.customSlider.frame.size.width;
    float change = netTranslationX / lineWidth;
    
    // change relationship is reverse
    float rRange, gRange, bRange;
    rRange = rLow - rHigh;
    gRange = gLow - gHigh;
    bRange = bLow - bHigh;
    
    float rChange, gChange, bChange;
    rChange = rRange * change;
    gChange = gRange * change;
    bChange = bRange * change;
    
    float rNew, gNew, bNew;
    rNew = rChange + r;
    gNew = gChange + g;
    bNew = bChange + b;
    
    self.customSliderPointer.backgroundColor =
    self.customSliderConnector.backgroundColor =
    self.skinColorView.backgroundColor = [UIColor colorWithRed:rNew green:gNew blue:bNew alpha:1];
    [self setTextColorForColor:self.skinColorView.backgroundColor ForType:@"skin"];
    self.skinColorDidChange = YES;
    
}


- (IBAction)buttonMyTopPicksPressed {
    
    LogInfo(@"Color signature screen top pick button pressed");
    
    if(self.skinColorDidChange)
    {
        [self.userModel getUserProfileMapObject].skinColor = self.customSliderPointer.backgroundColor;
        [self updateServerForEditColors];
    }
    
    CMApplicationModel *applicationModel = [[CMApplicationModel alloc] init];
    if([applicationModel toColorCorrect])
    {
        [applicationModel setIsColorCorrectSwitchOn:self.colorCorrectSwitch.isOn];
        [applicationModel setColorCorrectedValueWithEyeColor:self.swapEyeColor
                                               WithSkinColor:self.swapSkinColor
                                                WithLipColor:self.swapLipsColor
                                               WithHairColor:self.swapHairColor];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void) updateServerForEditColors
{
    NSURL *url = [NSURL URLWithString:server];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    
    CMUserProfileMap *userData = [self.userModel getUserProfileMapObject];
    [parameter setObject:userData.profileID forKey:@"profile_id"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.hairColor] forKey:@"hair"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.eyesColor] forKey:@"eyes"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.skinColor] forKey:@"skin"];
    [parameter setObject:[ColorUtility hexadecimalValueOfAUIColor:userData.lipsColor] forKey:@"lips"];
    
    NSMutableURLRequest *request = [httpClient
                                    requestWithMethod:@"POST"
                                    path:pathToAPICallForUpdatingUserColorSignature
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
             [self.userModel updateUserColorsWithJSON: JSON];
         }
         else
         {
             LogInfo(@"ERROR: %@ %@", response, JSON);
         }
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
     {
         NSLog(@"error:%i, desc: %@", response.statusCode,response.description);
         [self showAlertWithTitle:@"Network Error"
                      WithMessage:@"It appears you have lost internet connectivity. Please check your network settings."];
     }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation: operation];
    [operation waitUntilFinished];
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



- (void) showMessage: (NSString *) message
          completion: (void (^) (void)) completion;
{
    // add text padding
    CGFloat padding=10.0f;
    [textLabel setFrame:CGRectMake(padding, padding, floatingMessageView.frame.size.width-2*padding, floatingMessageView.frame.size.height-20)];
    
    // set text alignment and color, it's done in xib file as well
    [textLabel setTextAlignment:UITextAlignmentLeft];
    [textLabel setTextColor:[UIColor blackColor]];
    
    // set textLable text
    [textLabel setText:message];
    textLabel.adjustsFontSizeToFitWidth=YES;
    
    // set minimum font size, Minimum Font Size deprecated on ios version 6.0
    textLabel.minimumFontSize=12;
    
    // initial floatingMessageView
    [floatingMessageView setAlpha:0.0f];
    [floatingMessageView setBackgroundColor:[UIColor whiteColor]];
    [floatingMessageView setUserInteractionEnabled:NO];
    [[floatingMessageView layer]setCornerRadius:6.0f];
    
    // add textLabel view to floatingMessageView
    [floatingMessageView addSubview:textLabel];
    [floatingMessageView sizeToFit];
    
    // add floatingMessageView to view
    [[self view]addSubview:floatingMessageView];
    
    // here call the animation and delay 3 sec to fade out
    [UIView animateWithDuration:0.5f delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [floatingMessageView setAlpha:1.0f];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5f delay:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [floatingMessageView setAlpha:0.0f];
        } completion:^(BOOL finished){
            [floatingMessageView removeFromSuperview];
        }];
    }];
    
    
}

- (void) showBadLightingMessage
{
    [self showMessage:@"The lighting appears to be slightly off. Please consider taking another picture." completion:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setUserModel: nil];
}


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [self setProfileImage:nil];
    [self setProfileImage:nil];
    [self setCustomSlider:nil];
    [self setHairColorSignatureLabel:nil];
    [self setEyeColorSignatureLabel:nil];
    [self setSkinColorSignatureLabel:nil];
    [self setEyeColorSignatureLabel:nil];
    [self setLipColorSignatureLabel:nil];
    [self setCustomSliderContainer:nil];
    [self setColorCorrectSwitch:nil];
    [self setColorCorrectLabel:nil];
    [self setUserModel: nil];
    [self setEyeColorView:nil];
    [self setHairColorView:nil];
    [self setHairColorTextLabel:nil];
    [self setHairColorEditLabel:nil];
    [self setEyeColorEditLabel:nil];
    [self setEyeColorTextLabel:nil];
    [self setLipColorView:nil];
    [self setLipColorTextLabel:nil];
    [self setLipColorEditLabel:nil];
    [self setSkinColorView:nil];
    [self setSkinColorTextLabel:nil];
    [self setSkinColorEditLabel:nil];
    [self setHairColorErrorSign:nil];
    [self setEyeColorErrorSign:nil];
    [self setLipColorErrorSign:nil];
    [self setSkinColorErrorSign:nil];
    [self setBrowseProductsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
@end
