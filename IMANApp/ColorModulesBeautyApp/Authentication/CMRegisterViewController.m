//
//  CMRegisterViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 5/22/13.
//
//

#import "CMRegisterViewController.h"
#import "CMApplicationModel.h"
#import "SVProgressHUD.h"
#import "CMPhotoSource.h"
@interface CMRegisterViewController ()
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *firstName;
@property (strong, nonatomic) IBOutlet UITextField *lastName;
@end

@implementation CMRegisterViewController

- (IBAction)registerButtonPressed:(id)sender
{
    [CMApplicationModel registerToPlumperfectWithUsername:self.email.text
                                            WithFirstName:self.firstName.text
                                             WithLastName:self.lastName.text
                                 withNavigationController:self.navigationController];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setEmail:nil];
    [self setFirstName:nil];
    [self setLastName:nil];
    [super viewDidUnload];
}
@end
