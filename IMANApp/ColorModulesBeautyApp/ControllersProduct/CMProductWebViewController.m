//
//  CMProductWebViewController.m
//  ColorModulesBeautyApp
//
//  Created by Nicky Liu on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMProductWebViewController.h"
#import "SVProgressHUD.h"
#import "CMConstants.h"

@implementation CMProductWebViewController
@synthesize product=_product;
@synthesize webDisplay = _webDisplay;
@synthesize colorSwatch = _colorSwatch;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize labelColorName = _labelColorName;


#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.webDisplay loadRequest:[NSURLRequest requestWithURL:self.product.url]];
    
    //[[self navigationItem] setTitleView:[CMCustomTheme getScreenTitleView:self.navigationItem.title]];

    
    // Setting Swatch color and Setting Label Text Color. White for darker swatch and Black for lighter swatch.
    self.colorSwatch.backgroundColor = self.product.color;
    CGFloat backgroundRed, backgroundGreen, backgroundBlue;
    [self.colorSwatch.backgroundColor getRed:&backgroundRed
                                           green:&backgroundGreen
                                            blue:&backgroundBlue
                                           alpha:nil];
    CGFloat colorGray = (backgroundRed*0.299) + (backgroundGreen*0.587) + (backgroundBlue*0.144); //R*0.299 + G*0.587 + B*0.114 -- light is higher than 0.5
    if(colorGray > 0.45f)
    {
        [self.labelColorName setTextColor: [UIColor blackColor]];
    } else {
        [self.labelColorName setTextColor: [UIColor whiteColor]];
    }
    
    self.labelColorName.backgroundColor = self.product.color;

    // Setting the text for ColorName...
    NSString *colorName = self.product.colorName;
    colorName = [colorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *message = [NSArray arrayWithObjects: @"Your plum perfect recommendation is ", colorName, @". Please make sure ", colorName, @" is selected!", nil];
    self.labelColorName.text = [message componentsJoinedByString:@""];
    
    // To show loding indicator...
    //[self.loadingIndicator hidesWhenStopped];
    //[self.loadingIndicator startAnimating];
    [SVProgressHUD showWithStatus:STR_LOADING maskType:SVProgressHUDMaskTypeGradient];
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //[self.loadingIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //[self.loadingIndicator stopAnimating];
    [SVProgressHUD dismiss];
}

- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setWebDisplay:nil];
    [self setColorSwatch:nil];
    [self setLoadingIndicator:nil];
    [self setLabelColorName:nil];
    [super viewDidUnload];
}

@end
