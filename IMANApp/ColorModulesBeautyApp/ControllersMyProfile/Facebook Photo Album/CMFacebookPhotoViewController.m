//
//  CMFacebookPhotoViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 1/30/13.
//
//

#import "CMFacebookPhotoViewController.h"
#import "CMFacebookPhotoCell.h"
#import "UIImageView+AFNetworking.h"
#import "Logging.h"
#import "AFHTTPClient.h"
#import "CMConstants.h"
#import "AFJSONRequestOperation.h"
#import "CMUserModel.h"
#import "LightBox2.h"
#import "CMMyProfileViewController.h"
#import "SVProgressHUD.h"

@interface CMFacebookPhotoViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation CMFacebookPhotoViewController
@synthesize photosInThisAlbum = _photosInThisAlbum;
@synthesize titleLabel = _titleLabel;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows = 1;
    int numberOfContainersThisRow = 2;
    if (self.photosInThisAlbum.count > numberOfContainersThisRow)
    {
        numberOfRows = self.photosInThisAlbum.count / numberOfContainersThisRow;
        if((self.photosInThisAlbum.count % numberOfContainersThisRow) > 0)
        {
            numberOfRows = numberOfRows + 1;
        }
    }
    
    [SVProgressHUD dismiss];
    return (numberOfRows);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    CMFacebookPhotoCell *cell = (CMFacebookPhotoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[CMFacebookPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    //Configure the cell...
    int numberOfContainersInThisCell = 2;
    int photosDisplayed = (indexPath.row * numberOfContainersInThisCell);
    if((photosDisplayed + numberOfContainersInThisCell)> self.photosInThisAlbum.count)
    {
        numberOfContainersInThisCell = self.photosInThisAlbum.count - photosDisplayed;
    }
    
    NSInteger currentPhotoNumber;
    NSURL *photoURL;
    
    [cell.photoA setHidden:YES];
    [cell.photoB setHidden:YES];
    
    for (int i=0; i<numberOfContainersInThisCell; i++) {
        currentPhotoNumber = photosDisplayed + i;
        photoURL = [self.photosInThisAlbum objectAtIndex:currentPhotoNumber];
        
        switch (i) {
            case 0:
            {
                [cell.photoA setHidden:NO];
                [cell.photoA setTag: currentPhotoNumber];
                [cell.photoA addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(tapAction:)]];
                [cell.photoA setUserInteractionEnabled:YES];
                [cell.photoA setImageWithURL:photoURL placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMG]];
                break;
            }
            case 1:
            {
                [cell.photoB setHidden:NO];
                [cell.photoB setTag: currentPhotoNumber];
                [cell.photoB addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(tapAction:)]];
                [cell.photoB setUserInteractionEnabled:YES];
                [cell.photoB setImageWithURL:photoURL placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMG]];
                break;
            }
            default:
                break;
        }
    }
    
    return cell;
}


- (void)tapAction: (UIGestureRecognizer *)gestureRecognizer
{
    // uploading images...
    [SVProgressHUD showWithStatus:@"Extracting colors from your image" maskType:SVProgressHUDMaskTypeGradient];
    
    NSURL *selectedPhotoURL = [self.photosInThisAlbum objectAtIndex:gestureRecognizer.view.tag];
    [gestureRecognizer.view setOpaque:NO];
    [self uploadPhotoToServer:selectedPhotoURL];
}


- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void) uploadPhotoToServer: (NSURL *) selectedPhotoURL
{
    LogInfo(@"Uploading the facebook image to server.");
    NSURL *url = [NSURL URLWithString: server];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSDictionary *postParams = [NSDictionary dictionaryWithObject:selectedPhotoURL forKey:@"u_url"];
    NSMutableURLRequest *request = [httpClient requestWithMethod: @"POST"
                                                            path: pathToAPICAllForUploadingNewProfileImage
                                                      parameters: postParams];
    
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         BOOL success=[[JSON objectForKey:@"success"] boolValue];
         if (success)
         {
             LogInfo(@"Photo uploaded succesfully.");
             [self checkForErrorMessagesReturnedByServerForUploadedImage: JSON];
         }
         else
         {
             LogError(@"error: %@", JSON);
             [SVProgressHUD dismiss];
             [self showAlertWithTitle:@"Oops..." WithMessage:@"An error occured. Please try again."];
         }
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         LogError(@"error: %i", response.statusCode);
         [self showAlertWithTitle:@"Network Error"
                      WithMessage:@"It appears you have lost internet connectivity. Please check your network settings."];
     }];
    [operation start];
}


- (void) checkForErrorMessagesReturnedByServerForUploadedImage: (NSDictionary *) JSON
{
    NSArray *errors = [JSON objectForKey:@"errors"];
    NSLog(@"Errors: %@", errors);
    [SVProgressHUD dismiss];
    
    if (errors.count > 0)
    {
        if([errors containsObject:@"no_face"])
        {
            LightBox2 *guideLightbox = [[LightBox2 alloc] initWithTitle:@"Oops..." forMessage:@"Something went wrong!  It may be your photo doesn't meet the plum perfect requirements.  Would you try using another one?"];
            [self.view addSubview:guideLightbox];
        }
        
        else
        {
            LightBox2 *guideLightbox = [[LightBox2 alloc] initWithTitle:@"Perfect!" forMessage:@"However, we didn't get some of your colors. Not to worry. Just click edit and we'll guide you on getting your complete color profile."];
            [self.navigationController.view addSubview:guideLightbox];
            
            // To get the new profile data from backend...
            CMUserModel *userModel = [[CMUserModel alloc] initForUserProfile];
            [userModel updateUserProfileDataWithJSONForUploadsImport:JSON];
            
            // To end the processing...
            [self endUploadProcessInSuccess];
            
        }
    }
    
    else
    {
        // To get the new profile data from backend...
        CMUserModel *userModel = [[CMUserModel alloc] initForUserProfile];
        [userModel updateUserProfileDataWithJSONForUploadsImport:JSON];
        
        // To end the processing...
        [self endUploadProcessInSuccess];
        
    }
}

- (void) endUploadProcessInSuccess
{
    LogInfo(@"Uploaded new image and data.");
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self performSegueWithIdentifier:@"go to myprofile" sender:self];
}

- (void) showAlertWithTitle: (NSString *) title
                WithMessage: (NSString *) message
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}
@end
