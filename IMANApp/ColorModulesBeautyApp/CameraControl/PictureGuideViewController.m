//
//  PictureGuideViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 3/25/13.
//
//

#import "PictureGuideViewController.h"
#import "Logging.h"

@interface PictureGuideViewController ()

@end

@implementation PictureGuideViewController

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
	// Do any additional setup after loading the view.
    
    LogInfo(@"Take a photo button pressed");

}



- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
