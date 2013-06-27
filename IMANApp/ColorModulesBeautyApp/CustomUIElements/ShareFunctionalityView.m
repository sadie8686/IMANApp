//
//  ShareFunctionalityView.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 3/31/13.
//
//

#import "ShareFunctionalityView.h"
#import "FacebookShareDialog.h"
#import "FacebookSDK/FacebookSDK.h"
#import "QuartzCore/QuartzCore.h"
#import "CMProductMap.h"
#import "Logging.h"
#import "SA_OAuthTwitterEngine.h"
#import "SVProgressHUD.h"
#import "CMConstants.h"
#import "CMUserModel.h"
#import "IMANAppDelegate.h"

@interface ShareFunctionalityView()
@property (nonatomic) float screenWidth;
@property (nonatomic) float screenHeight;
@property (nonatomic, strong) NSArray *productArray;
@property (nonatomic, retain) SA_OAuthTwitterEngine *twitterEngine;
@property (nonatomic, retain) UIViewController * superViewController;
@property (nonatomic) int viewPosition;
@end

@implementation ShareFunctionalityView
@synthesize screenWidth = _screenWidth;
@synthesize screenHeight = _screenHeight;
@synthesize productArray = _productArray;
@synthesize twitterEngine = _twitterEngine;
@synthesize superViewController = _superViewController;

- (id)initWithProductArray: (NSArray *) productArray
   WithSuperViewController:(UIViewController *) superViewController
          WithViewPosition:(int)viewPosition
{
    _productArray = productArray;
    _superViewController = superViewController;
    _viewPosition = viewPosition;
    
    
    CGRect screenBounds = [UIScreen mainScreen].applicationFrame;
    _screenWidth = screenBounds.size.width;
    _screenHeight = screenBounds.size.height;
    float viewHeight = 80;
    
    if(viewPosition == VIEW_LOCATION_BOTTOM)
    {
        self = [super initWithFrame:CGRectMake(0, _screenHeight, _screenWidth, _screenHeight)];
    }
    else if(viewPosition == VIEW_LOCATION_TOP)
    {
        self = [super initWithFrame:CGRectMake(0, -_screenHeight, _screenWidth, _screenHeight)];
    }
    
    
    if(self)
    {
        // setting background color for the layer to clear color...
        [self setBackgroundColor:[UIColor clearColor]];
        
        
        // creating share view to contain share buttons...
        UIView *shareView;
        UITapGestureRecognizer *tapGesture;
        if(viewPosition == VIEW_LOCATION_BOTTOM)
        {
            shareView = [[UIView alloc] initWithFrame:CGRectMake(0, self.screenHeight - viewHeight,
                                                                 self.screenWidth,viewHeight)];
            
            
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateOut)];
        }
        else if(viewPosition == VIEW_LOCATION_TOP)
        {
            shareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                 self.screenWidth,viewHeight)];
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateOut)];
        }
        
        // Adding tap gesture to close the view...
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:tapGesture];
        
        
        // Setting view properties...
        [shareView.layer setBorderColor:[UIColor blackColor].CGColor];
        [shareView.layer setBorderWidth:2.0f];
        [shareView setBackgroundColor: [UIColor whiteColor]];
        
        // Adding facebook share button...
        float buttonSize = 50;
        float xCentre = self.screenWidth / 4;
        float yCentre = viewHeight / 2;
        
        UIButton *facebookShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize, buttonSize)];
        [facebookShare setImage:[UIImage imageNamed:@"fb.png"] forState:UIControlStateNormal];
        [facebookShare setCenter:CGPointMake(xCentre, yCentre)];
        [facebookShare addTarget:self action:@selector(facebookSharePressed:) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:facebookShare];
        
        // Adding twitter share button...
        UIButton *twitterShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize, buttonSize)];
        [twitterShare setImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
        [twitterShare setCenter:CGPointMake((xCentre *2), yCentre)];
        [twitterShare addTarget:self action:@selector(twitterSharePressed:) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:twitterShare];
        
        // Adding email share button...
        UIButton *emailShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize, buttonSize)];
        [emailShare setImage:[UIImage imageNamed:@"email.png"] forState:UIControlStateNormal];
        [emailShare setCenter:CGPointMake((xCentre * 3), yCentre)];
        [emailShare addTarget:self action:@selector(emailSharePressed:) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:emailShare];
        
        
        // Adding this shareView to the self...
        [self addSubview:shareView];
        
        [UIView animateWithDuration:0.4f
                         animations:^{
                             [self setFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight)];
                         }
         ];
    }
    return self;
}

/*
 Facebook share functionality...
 */

- (void)facebookSharePressed:(id)sender
{
    // To close the share view...
    //[self pushShareBtn:self];
    LogInfo(@"facebook share button pressed");
    
    if(FBSession.activeSession.isOpen)
    {
        [self shareOnFacebook];
    }
    
    else
    {
        
        IMANAppDelegate *appDelegate = (IMANAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(shareOnFacebook)
                                                     name:FBSessionStateChangedNotification
                                                   object:nil];
        appDelegate = nil;
    }
}


- (void) shareOnFacebook
{
    // Ask for publish_actions permissions in context
    if(FBSession.activeSession.isOpen)
    {
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
        {
            // No permissions found in session, ask for it
            [FBSession.activeSession
             reauthorizeWithPublishPermissions:
             [NSArray arrayWithObject:@"publish_actions"]
             defaultAudience:FBSessionDefaultAudienceFriends
             completionHandler:^(FBSession *session, NSError *error) {
                 if (!error)
                 {
                     // If permissions granted, publish the story
                     [self showFacebookShareDialog];
                 }
                 else
                 {
                     LogError(@"Facebook Share Permission Error: %@", error.description);
                 }
             }];
        }
        else
        {
            // If permissions present, publish the story
            [self showFacebookShareDialog];
        }
    }
}

- (void) showFacebookShareDialog
{
    CMProductMap *product = [self.productArray objectAtIndex:0];
    FacebookShareDialog *facebookShareView = [[FacebookShareDialog alloc]
                                              initWithImageURL:[NSString stringWithFormat:@"%@", product.imageURL]
                                              WithProductName:[NSString stringWithFormat:@"%@", product.title]
                                              WithProductURL:[NSString stringWithFormat:@"%@", product.url]
                                              WithColorName:product.colorName
                                              withProductType:product.typeID
                                              WithProductDescription:product.description];
    [self.superViewController.view addSubview:facebookShareView];
        
    [self animateOut];
}



/*
 Twitter functionality...
 */

- (void)twitterSharePressed:(id)sender
{
    
    LogInfo(@"twitter share button pressed");

    
    if(!self.twitterEngine){
        self.twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
        self.twitterEngine.consumerKey    = twitterConsumerKey;
        self.twitterEngine.consumerSecret = twitterConsumerSecret;
    }
    
    if(![self.twitterEngine isAuthorized]){
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:self.twitterEngine delegate:self];
        
        if (controller){
            [self.superViewController presentViewController: controller animated: YES completion:nil];
        }
    } else {
        // POST TO TWITTER
        
        //"The Plum Perfect iPhone app just recommended a (product_color_name) (product_name) for my (value_alt), (temp_alt) (eyes, face, lips). [Bitly App Link]"

        CMUserModel *userModel = [[CMUserModel alloc] initForUserProfile];
        CMUserProfileMap *userData = [userModel getUserProfileMapObject];
        CMProductMap *product = [self.productArray objectAtIndex:0];

        NSString *userFeature = @"lips";
        NSString *featureDesc;
        
        if ([product.typeID intValue] == 1) {
            userFeature = @"lips";
            featureDesc = [NSString stringWithFormat:@"%@, %@, %@",userData.lipsChroma, userData.lipsTemp, userData.lipsColorName];
        }else if([product.typeID intValue] == 2)
        {
            userFeature = @"skin";
            featureDesc = [NSString stringWithFormat:@"%@, %@",userData.skinValue, userData.skinTemp];
            
        }else if ([product.typeID intValue] == 3)
        {
            userFeature = @"eyes";
            featureDesc = [NSString stringWithFormat:@"%@, %@, %@", userData.eyesChroma, userData.eyesTemp, userData.eyesColorName];
        }
        
        [self.twitterEngine sendUpdate:[NSString stringWithFormat:@"The Plum Perfect iPhone app just recommended a %@ %@ for my %@ %@. %@", product.colorName, product.title, featureDesc, userFeature, product.url]];
        
    }
}

/*
 Email functionality
 
 */

- (void)emailSharePressed:(id)sender
{
    
    LogInfo(@"email share button pressed");

    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setMailComposeDelegate:self];
    
    if ([MFMailComposeViewController canSendMail]) {
        
        NSMutableString *body = [NSMutableString string];
        // add HTML before the link here with line breaks (\n)
        [body appendString:@"<h3>I found the products you may like!</h3>\n"];
        
        for(int i=0; i<self.productArray.count; i++)
        {
            CMProductMap *product = [self.productArray objectAtIndex:i];
            [body appendString:@"<br>"];
            [body appendString:@"<a href=\""];
            [body appendString:[NSString stringWithFormat:@"%@", product.url]];
            [body appendString:@"\">"];
            [body appendString:product.title];
            [body appendString:@"</a>\n<br/><br/>"];
            [body appendString:@"<img src=\""];
            [body appendString:[NSString stringWithFormat:@"%@", product.imageURL]];
            [body appendString:@"\"</img>"];
        }
        [mailComposer setSubject:@"Plum Perfect recommends"];
        [mailComposer setMessageBody:body isHTML:YES];
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self.superViewController presentViewController:mailComposer animated:NO completion:nil];
    }
}

/*
 MFMailComposeViewControllerDelegate Methods...
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error)
    {
        [SVProgressHUD showErrorWithStatus:@"Failed to send the email. Please try again later."];
    }
    [controller resignFirstResponder];
    [self.superViewController becomeFirstResponder];
    [self.superViewController dismissModalViewControllerAnimated:YES];
    [self animateOut];
}

/*
 SA_OAuthTwitterEngineDelegate Methods...
 */

- (void) storeCachedTwitterOAuthData: (NSString *) data
                         forUsername: (NSString *) username
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: data forKey:@"authData"];
    [defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username
{
    return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier
{
    NSLog(@"Request %@ succeeded", requestIdentifier);
    [SVProgressHUD showSuccessWithStatus:@"Tweet succeeded."];
    [self animateOut];
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error
{
    LogError(@"Twitter Request %@ for product share failed with error: %@", requestIdentifier, error);
    [SVProgressHUD showErrorWithStatus:@"Failed to send updates. Please try again later."];
}



/*
 Animate out...
 */

- (void) animateOut
{
    
    if(self.viewPosition == VIEW_LOCATION_BOTTOM)
    {
        [UIView animateWithDuration:0.4f
                         animations:^{
                             [self setFrame:CGRectMake(0, self.screenHeight, self.screenWidth, self.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             [self removeFromSuperview];
                         }];
    }
    
    else if(self.viewPosition == VIEW_LOCATION_TOP)
    {
        [UIView animateWithDuration:0.4f
                         animations:^{
                             [self setFrame:CGRectMake(0, -self.screenHeight, self.screenWidth, self.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             [self removeFromSuperview];
                         }];
    }
}
@end
