//
//  CMLoginViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 5/22/13.
//
//

#import "CMLoginViewController.h"
#import "CMApplicationModel.h"
#import "SVProgressHUD.h"

@interface CMLoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *textFieldEmail;
@end

@implementation CMLoginViewController

- (IBAction)loginButtonPressed:(id)sender
{
    [CMApplicationModel loginToPlumPerfectWithUsername:self.textFieldEmail.text
                              withNavigationController:self.navigationController];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setTextFieldEmail:nil];
    [super viewDidUnload];
}
@end
