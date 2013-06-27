//
//  SplashViewController.m
//  IMAN
//
//  Created by  on 08/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "SplashViewController.h"
#import "Constants.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    
    
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (IMANAppDelegate *)[[UIApplication sharedApplication] delegate];

    splashView = [[UIImageView alloc] init];
    if (IS_IPHONE_5) {
        splashView.image = [UIImage imageNamed:@"Default-568h@2x.png"];
    }
    else {
        splashView.image = [UIImage imageNamed:@"Default.png"];
    }
    splashView.frame = appDelegate.window.frame;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(160, appDelegate.window.bounds.size.height-70);
    [indicator startAnimating];
    [splashView addSubview:indicator];
    [self.view addSubview:splashView];
    
    
    [self performSelector:@selector(showRootView) withObject:nil afterDelay:1.0];
	// Do any additional setup after loading the view.
}



- (void) showRootView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    appDelegate.window.rootViewController = appDelegate.tabBarController;
    
    /*
    [UIView transitionWithView:appDelegate.window duration:0.5 options: UIViewAnimationOptionTransitionFlipFromRight animations:^{
        
    } completion:nil];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
