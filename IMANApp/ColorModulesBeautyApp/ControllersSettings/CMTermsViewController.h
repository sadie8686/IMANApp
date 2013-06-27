//
//  CMTermsViewController.h
//  ColorModulesBeautyApp
//
//  Created by Abhijit Sarkar on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTermsViewController : UIViewController


@property (nonatomic, retain) IBOutlet UIWebView *termsWebView;

- (void)loadDataFromFileAtURL;

@end
