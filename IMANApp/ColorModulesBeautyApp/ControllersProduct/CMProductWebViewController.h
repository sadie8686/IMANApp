//
//  CMProductWebViewController.h
//  ColorModulesBeautyApp
//
//  Created by Nicky Liu on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMProductMap.h"

@interface CMProductWebViewController : UIViewController <UIWebViewDelegate>
@property (weak,nonatomic) CMProductMap *product;
@property (weak, nonatomic) IBOutlet UIWebView *webDisplay;
@property (weak, nonatomic) IBOutlet UIView *colorSwatch;
@property (weak, nonatomic) IBOutlet UILabel *labelColorName;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;



@end
