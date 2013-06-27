//
//  LightBox2.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 12/11/12.
//
//

#import "LightBox2.h"
#import "QuartzCore/QuartzCore.h"
#import "CMCustomTheme.h"

@interface LightBox2()
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@property (nonatomic) UIColor *titleColor;
@property (nonatomic) UIColor *textColor;

@property (nonatomic) NSInteger lightboxY;
@property (nonatomic, strong) UIView *lightBoxView;

@property (nonatomic, strong) UITextField *minPriceTextField;
@property (nonatomic, strong) UITextField *maxPriceTextField;
@property (nonatomic, strong) UILabel *errorLabelForPriceLightBox;
@property (nonatomic) UITableView *tableView;
@end


@implementation LightBox2
@synthesize screenHeight = _screenHeight;
@synthesize screenWidth = _screenWidth;
@synthesize titleColor = _titleColor;
@synthesize textColor = _textColor;
@synthesize lightboxY = _lightboxY;
@synthesize lightBoxView = _lightBoxView;
@synthesize minPriceTextField = _minPriceTextField;
@synthesize maxPriceTextField = _maxPriceTextField;
@synthesize errorLabelForPriceLightBox = _errorLabelForPriceLightBox;
int standardMinPrice;
int standardMaxPrice;

-(id) initWithTitle: (NSString *) title
         forMessage:(NSString *) message
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenBounds.size.width;
    self.screenHeight = screenBounds.size.height;
    
    self = [super initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight)];
    if(self)
    {
        // To create lightbox.
        UIView *lightBox = [self createLightBoxOfHeight:(self.screenHeight * 0.45)];
        self.lightBoxView = lightBox;
        
        // To add subviews to this lightbox.
        [lightBox addSubview:[self createTitleLabelFor:title]];
        [lightBox addSubview:[self createCloseButton]];
        [lightBox addSubview:[self createMessageLabelFor: message]];
        
        
        // Adding lightbox as a subview of background shadow.
        [self addSubview:lightBox];
        
        // To animate the lightbox.
        [self animateIn];
    }
    return self;
}

- (void) setBackgroundLayout
{
    self.titleColor = [UIColor blackColor];
    self.textColor = [UIColor blackColor];
}

- (UIView *) createLightBoxOfHeight:(float) boxHeight
{
    // To determine lightbox frame attributes.
    NSString *deviceType = [UIDevice currentDevice].model;
    
    int boxWidth = self.screenWidth;
    self.lightboxY = (self.screenHeight - boxHeight) / 3;
    int boxX = 0;
    
    if([deviceType isEqualToString:@"iPad"] || [deviceType isEqualToString:@"iPad Simulator"])
    {
        boxHeight = (self.screenHeight * 0.22);
        boxWidth = self.screenWidth;
        self.lightboxY = (self.screenHeight - boxHeight) / 3;
        boxX = 0;
    }
    
    if(self.screenHeight == 568)
    {
        boxHeight = (self.screenHeight) * 0.4;
    }
    
    UIView *lightBox =  [[UIView alloc] initWithFrame:CGRectMake(boxX, -self.screenHeight, boxWidth, boxHeight)];
    lightBox.backgroundColor = [UIColor whiteColor];
    [lightBox.layer setBorderColor:[UIColor blackColor].CGColor];
    [lightBox.layer setBorderWidth:1.5f];
    [lightBox setAlpha:1];
    return lightBox;
}



- (UILabel *) createTitleLabelFor: (NSString *) title
{
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.lightBoxView.frame.size.width - 30, 30)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:self.titleColor];
    [titleLabel setFont:[UIFont fontWithName:[CMCustomTheme getFontNameForBold:YES] size:18]];
    [titleLabel setNumberOfLines:1];
    [titleLabel setText:title];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    return titleLabel;
}



- (UILabel *) createMessageLabelFor: (NSString *) message
{
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextColor:self.textColor];
    [messageLabel setFont:[UIFont fontWithName:[CMCustomTheme getFontNameForBold:NO] size:14]];
    [messageLabel setNumberOfLines:0];
    [messageLabel setText:message];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    
    int positionX = 35;
    messageLabel.frame = CGRectMake(positionX, 0, self.lightBoxView.frame.size.width - 70, self.lightBoxView.frame.size.height);
    return messageLabel;
}



- (UIButton *) createCloseButton
{
    int buttonHeight = 20;
    int buttonWidth = 20;
    int buttonX = (self.lightBoxView.frame.size.width) - (buttonWidth) - 10;
    int buttonY = 8;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
    [closeButton setImage:[UIImage imageNamed:@"Cross_Button.png"]forState:UIControlStateNormal];
    
    [closeButton addTarget:self
                    action:@selector(closeNoticeDropDown:)
          forControlEvents:UIControlEventTouchUpInside];
    
    return closeButton;
    
}


-(void) animateIn
{
    //Animate In
    [UIView animateWithDuration:1
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.lightBoxView.frame = CGRectMake(self.lightBoxView.frame.origin.x, self.lightboxY,
                                                              self.lightBoxView.frame.size.width, self.lightBoxView.frame.size.height);
                     }
                     completion:nil
     ];
}


-(void) animateOut
{
    //Animate Out
    [UIView animateWithDuration:1
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.lightBoxView.frame = CGRectMake(self.lightBoxView.frame.origin.x, -self.screenHeight,
                                                              self.lightBoxView.frame.size.width, self.lightBoxView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardDidShowNotification];
                         [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillHideNotification];
                     }
     ];
}



-(void)closeNoticeDropDown: (id) sender
{
    [self animateOut];
}

- (void) buttonLayout: (UIButton *) button
{
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:[CMCustomTheme getFontNameForBold:NO] size:14]];
    [button.layer setBorderColor:[UIColor blackColor].CGColor];
    [button.layer setBorderWidth:1.5f];
    [button.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [button.layer setShadowOpacity:0.8];
    [button.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    
    //[button setBackgroundImage:[UIImage imageNamed:@"btn_thin_up.png"] forState:UIControlStateNormal];
    // [button setBackgroundColor:[UIColor redColor]];
    
}



/*
 *  To handle scrolling screen when user starts or stops typing.
 */
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGPoint scrollPoint = CGPointMake(0.0, self.lightBoxView.frame.origin.y - 40);
    [self setContentOffset:scrollPoint animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    [self setContentOffset:scrollPoint animated:YES];
}





/****************************************************************************************************
 Helpful Tips.
 ****************************************************************************************************/

- (id) initForHelpfulTipsWithTitle: (NSString *) title
                       WithMessage: (NSString *) message
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenBounds.size.width;
    self.screenHeight = screenBounds.size.height;
    
    
    self = [super initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight)];
    if(self)
    {
        UIView *lightBox;
        self.titleColor = [UIColor blackColor];
        self.textColor = [UIColor blackColor];
        lightBox = [self createLightBoxOfHeight:(self.screenHeight * 0.40)];
        
        
        // To create lightbox.
        self.lightBoxView = lightBox;
        
        // To add subviews to this lightbox.
        UILabel *titleLabel = [self createTitleLabelFor:title];
        [lightBox addSubview: titleLabel];
        [lightBox addSubview:[self createCloseButton]];
        [lightBox addSubview:[self helpfulTipsMessageBoxUsingTitleFrame: titleLabel.frame
                                                            WithMessage: message]];
        
        // Adding lightbox as a subview of background shadow.
        [self addSubview:lightBox];
        
        // To animate the lightbox.
        [self animateIn];
    }
    
    return self;
    
}


- (UIView *) helpfulTipsMessageBoxUsingTitleFrame:(CGRect) titleFrame
                                      WithMessage: (NSString *) message
{
    int frameX = 12;
    int frameY = titleFrame.size.height + 10;
    float frameHeight = self.lightBoxView.frame.size.height - frameY - 5;
    int frameWidth = self.lightBoxView.frame.size.width - (frameX*2);
    UIView *helpfultipsMessageBox =  [[UIView alloc] initWithFrame:CGRectMake(frameX, frameY, frameWidth, frameHeight)];
    
    // Adding message...
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [messageLabel setNumberOfLines:0];
    [messageLabel setText:message];
    [messageLabel setTextColor:self.textColor];
    [messageLabel setFont:[UIFont fontWithName:[CMCustomTheme getFontNameForBold:YES] size:14]];
    CGSize labelSize = [message sizeWithFont:messageLabel.font
                           constrainedToSize:CGSizeMake(frameWidth, frameHeight)
                               lineBreakMode:NSLineBreakByWordWrapping];
    [messageLabel setFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    [helpfultipsMessageBox addSubview:messageLabel];
    
    // Adding image...
    frameY = messageLabel.frame.origin.y + messageLabel.frame.size.height + 5;
    UIImageView *sampleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sampleimage.png"]];
    [sampleImage setFrame:CGRectMake(0, frameY, 88, 133)];
    [helpfultipsMessageBox addSubview:sampleImage];
    
    // Adding subtitle...
    frameX = sampleImage.frame.size.width + 10;
    frameY = sampleImage.frame.origin.y;
    
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameX, frameY, 0, 0)];
    [subTitleLabel setNumberOfLines:1];
    [subTitleLabel setText:@"Helpful Tips:"];
    [subTitleLabel setTextColor:[UIColor blackColor]];
    [subTitleLabel setFont:[UIFont fontWithName:[CMCustomTheme getFontNameForBold:YES] size:16]];
    [subTitleLabel sizeToFit];
    [helpfultipsMessageBox addSubview:subTitleLabel];
    
    // Adding tips...
    frameX = sampleImage.frame.size.width + 20;
    frameY = frameY + subTitleLabel.frame.size.height + 4;
    frameHeight = sampleImage.frame.size.height - subTitleLabel.frame.size.height;
    frameWidth = helpfultipsMessageBox.frame.size.width - frameY;
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameX, frameY, frameWidth, frameHeight)];
    [tipsLabel setNumberOfLines:4];
    [tipsLabel setText:@"√ Front facing \n√ No glasses \n√ Clean background \n√ Soft indirect daylight"];
    [tipsLabel setTextColor:[UIColor blackColor]];
    [tipsLabel setFont:[UIFont fontWithName:[CMCustomTheme getFontNameForBold:NO] size:14]];
    [tipsLabel sizeToFit];
    [helpfultipsMessageBox addSubview:tipsLabel];
    
    
    return helpfultipsMessageBox;
}



@end
