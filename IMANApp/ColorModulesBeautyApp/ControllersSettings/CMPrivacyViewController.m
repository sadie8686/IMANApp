//
//  CMPrivacyViewController.m
//  ColorModulesBeautyApp
//
//  Created by Abhijit Sarkar on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMPrivacyViewController.h"

@interface CMPrivacyViewController()
@property (nonatomic, retain) IBOutlet UIWebView *privacyWebView;
@end

@implementation CMPrivacyViewController
@synthesize privacyWebView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"patternPaper.png"]];
    
	// Do any additional setup after loading the view.
    [self loadDataFromFileAtURL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.privacyWebView = nil;
}


- (void)loadDataFromFileAtURL
{
    NSBundle *bundle = [NSBundle  mainBundle];
    NSString *path = [bundle pathForResource: @"CMPrivacyPolicy" ofType:@"rtf"];
    NSURL *termsDataFileURL = [NSURL fileURLWithPath:path];
    
    NSData *fileData = [NSData dataWithContentsOfURL: termsDataFileURL];
    
    [privacyWebView loadData:fileData MIMEType: @"text/rtf" textEncodingName: @"utf-8" 
                   baseURL: [NSURL URLWithString:@"/"]];
    
    
    return;
}


- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonPressedSettings {
    [self backButtonPressed];
}

@end
