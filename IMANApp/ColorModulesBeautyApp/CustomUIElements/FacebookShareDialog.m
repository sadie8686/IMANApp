//
//  FacebookShareDialog.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 1/29/13.
//
//

#import "FacebookShareDialog.h"
#import "QuartzCore/QuartzCore.h"
#import "Logging.h"
#import "FacebookSDK/FacebookSDK.h"
#import "UIImageView+AFNetworking.h"
#import "CMConstants.h"
#import "CMUserModel.h"

@interface FacebookShareDialog()
@property (nonatomic, strong) UITextView *messageBox;
@property (nonatomic, strong) NSMutableDictionary *postParams;


@end

@implementation FacebookShareDialog
@synthesize messageBox = _messageBox;
@synthesize postParams = _postParams;

- (id) initWithImageURL:(NSString *) imageURL
        WithProductName:(NSString *) productName
         WithProductURL:(NSString *) productURL
          WithColorName:(NSString *) colorName
        withProductType:(NSNumber *) productType
 WithProductDescription: (NSString *) productDescription
{
    
    // Setting post parameters...
    self.postParams =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     productURL, @"link",
     imageURL, @"picture",
     productName, @"name",
     colorName, @"caption",
     productDescription, @"description",
     nil];
    
    // Getting screen dimentions...
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float screenWidth = screenBounds.size.width;
    float screenHeight = screenBounds.size.height;
        
    self = [super initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    if (self) {
        
        // Setting default margins...
        float marginX = 10;
        float marginY = 20;
        float boxHeight = 235;
        float boxY = 5;

        
        // Adding background...
        UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        [backgroundLabel setAlpha:0.8];
        [backgroundLabel setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:backgroundLabel];
        
        
        // Adding box view...
        UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(0, boxY, screenWidth, boxHeight)];
        [boxView setBackgroundColor:[UIColor whiteColor]];
        [boxView.layer setBorderColor:[UIColor blackColor].CGColor];
        [boxView.layer setBorderWidth:1.5f];
        [boxView.layer setShadowColor:[UIColor blackColor].CGColor];
        [boxView.layer setShadowOpacity:0.8];
        [boxView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        [self addSubview:boxView];
        
        
        // Adding cancel button...
        float x = self.frame.size.width-30;
        float y = 5;
        float thisWidth = 20;
        float thisHeight = thisWidth;
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:[UIImage imageNamed:@"Cross_Button.png"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(x, y, thisWidth, thisHeight)];
        [cancelButton setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:cancelButton];
        
        
        // Adding text view for message to post...
        x = marginX;
        y = cancelButton.frame.origin.y + cancelButton.frame.size.height + 5;
        thisWidth = screenWidth - marginY;
        thisHeight = 60;
        
        UITextView *messageBox = [[UITextView alloc] initWithFrame:CGRectMake(x, y, thisWidth, thisHeight)];
        [messageBox.layer setBorderWidth:1];
        [messageBox.layer setBorderColor:[UIColor blackColor].CGColor];
        [messageBox becomeFirstResponder];
        
        CMUserModel *userModel = [[CMUserModel alloc] initForUserProfile];
        CMUserProfileMap *userData = [userModel getUserProfileMapObject];
        
        NSString *userFeature = @"lips";
        NSString *featureDesc;
        
        if ([productType intValue] == 1) {
            userFeature = @"lips";
            featureDesc = [NSString stringWithFormat:@"%@, %@, %@",userData.lipsChroma, userData.lipsTemp, userData.lipsColorName];
        }else if([productType intValue] == 2)
        {
            userFeature = @"skin";
            featureDesc = [NSString stringWithFormat:@"%@, %@",userData.skinValue, userData.skinTemp];

        }else if ([productType intValue] == 3)
        {
            userFeature = @"eyes";
            featureDesc = [NSString stringWithFormat:@"%@, %@, %@", userData.eyesChroma, userData.eyesTemp, userData.eyesColorName];
        }
        
        messageBox.text =[NSString stringWithFormat:@"Plum Perfect recommended a %@ %@ based on my %@ %@.  Download the Plum Perfect iPhone app and discover perfect looks personalized for your face. https://itunes.apple.com/us/app/plum-perfect/id544889292?mt=8", colorName, productName, featureDesc, userFeature];
        
        messageBox.dataDetectorTypes = UIDataDetectorTypeLink;

        self.messageBox = messageBox;
        [boxView addSubview:self.messageBox];
        
        
        // Adding image of the product...
        y = self.messageBox.bounds.origin.y + self.messageBox.bounds.size.height + (marginY * 2);
        thisWidth = 80;
        thisHeight = 80;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, thisWidth, thisHeight)];
        [imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMG]];
        [boxView addSubview:imageView];
        
        
        // Adding product name...
        x = imageView.bounds.origin.x + imageView.bounds.size.width + (2 * marginX);
        thisWidth = self.bounds.size.width - x - marginX;
        thisHeight = 80;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, thisWidth, thisHeight)];
        [titleLabel setText:productName];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [titleLabel setNumberOfLines:0];
        [titleLabel sizeToFit];
        [boxView addSubview:titleLabel];
        
        
        // Adding color name...
        y = y + titleLabel.bounds.size.height + 5;
        UILabel *colorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, thisWidth, thisHeight)];
        [colorNameLabel setText:colorName];
        [colorNameLabel setTextColor:[UIColor darkGrayColor]];
        [colorNameLabel setFont:[UIFont systemFontOfSize:10]];
        [colorNameLabel setNumberOfLines:1];
        [colorNameLabel sizeToFit];
        [boxView addSubview:colorNameLabel];
        
        
        // Adding description...
        y = y + colorNameLabel.bounds.size.height + 5;
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, thisWidth, thisHeight)];
        [descriptionLabel setText:productDescription];
        [descriptionLabel setTextColor:[UIColor darkGrayColor]];
        [descriptionLabel setFont:[UIFont systemFontOfSize:10]];
        [descriptionLabel setNumberOfLines:2];
        [descriptionLabel sizeToFit];
        [boxView addSubview:descriptionLabel];
        
        
        // Adding post button...
        x = (marginX * 2);
        thisHeight = 35;
        y = boxView.frame.size.height - thisHeight - 20;
        thisWidth = self.frame.size.width - (x * 2);
        UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [publishButton setFrame:CGRectMake(x, y, thisWidth, thisHeight)];
        [publishButton setTitle: @"Publish" forState: UIControlStateNormal];
        [self buttonLayout:publishButton];
        [publishButton addTarget:self
                          action:@selector(publishButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
        [boxView addSubview:publishButton];
        
    }
    return self;
}



- (void) buttonLayout: (UIButton *) button
{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button.layer setBorderColor:[UIColor blackColor].CGColor];
    [button.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [button.layer setBorderWidth:1.5f];
    [button.layer setShadowColor:[UIColor blackColor].CGColor];
    [button.layer setShadowOpacity:0.8];
    [button.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [button setBackgroundColor:[UIColor blueColor]];
}

-(void) publishButtonPressed:(id) sender{
    
    // To set the text user entered to be posted to facebook...
    [self.postParams setObject:self.messageBox.text forKey:@"message"];
    
    // To publish the story...
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:self.postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error) {
             alertText = @"Could not post the story on your wall. :(";
             LogError(@"Facebook story publish error: %@", error.description);
         } else {
             alertText = @"Story posted successfully on your wall.";
             LogInfo(@"Facebook story published successfully.");
         }
         // Show the result in an alert
         [[[UIAlertView alloc] initWithTitle:@"Facebook"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]
          show];
     }];
    
    [self removeFromSuperview];
}


- (void)cancelButtonPressed
{
    [self removeFromSuperview];
}


@end
