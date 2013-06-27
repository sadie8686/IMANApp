//
//  CMTermsViewController.m
//  ColorModulesBeautyApp
//
//  Created by Abhijit Sarkar on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMTermsViewController.h"
#import "NSData+Base64.h"

@interface CMTermsViewController ()

@end

@implementation CMTermsViewController

@synthesize termsWebView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
}


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
    self.termsWebView = nil;
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)loadDataFromFileAtURL
{
    
    NSBundle *bundle = [NSBundle  mainBundle];
    NSString *path = [bundle pathForResource: @"CMTermsAndConditions" ofType:@"rtf"];
    NSURL *termsDataFileURL = [NSURL fileURLWithPath:path];
                             
      
    NSData *fileData = [NSData dataWithContentsOfURL: termsDataFileURL];
    
    
    [termsWebView loadData:fileData MIMEType: @"text/rtf" textEncodingName: @"utf-8" 
                   baseURL: [NSURL URLWithString:@"/"]];
    
    
    return;
}

- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}


@end

