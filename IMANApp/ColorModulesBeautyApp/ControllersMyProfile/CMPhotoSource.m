/*--------------------------------------------------------------------------
 CMBeautyTakePhotoViewController.h
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar
 
 Created by Abhijit Sarkar on 2012/01/25
 
 Description:
 Code for Take Photo view that appears when users press the Start button
 under Profile View (CMBeautyFirstViewController).
 
 
 Revision history:
 2012/01/27 - by AS
 2012/02/16 - by AS, added code for delegate
 2012/03/21 - by AS, color correction/extraction code incorporated (3 PM)
 2012/03/23 - by AS, user flow changed, now this view is a delegate of home view
 
 Existing Problems:
 (date) -
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/


#import "CMPhotoSource.h"
#import "CMSelectModelPhotoViewController.h"
#import "CMCameraCaptureViewController.h"
#import "FacebookSDK/FacebookSDK.h"
#import "CMUserModel.h"
#import "Logging.h"
#import "CMApplicationModel.h"
#import "CMFacebookPhotoAlbumViewController.h"
#import "LightBox2.h"
#import "SVProgressHUD.h"
#import "CMConstants.h"
#import "CMPreColorProcessing.h"
#import <ImageIO/ImageIO.h>
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "CMNetworkAvailability.h"
#import "IMANAppDelegate.h"

// all delegate view controllers must be included here
@interface CMPhotoSource ()
{
    UIImagePickerController *imgPicker;

}
@property (nonatomic, strong) NSArray *facebookAlbums;
@property (nonatomic, strong) UIPopoverController *popOver;
@end


@implementation CMPhotoSource
@synthesize facebookAlbums = _facebookAlbums;

//@synthesize colorProcessingVC;
@synthesize mModelPhotoID = _mModelPhotoID;
@synthesize mProfilePhotoURL = _mProfilePhotoURL;
@synthesize mRequestActionToSourceController = _mRequestActionToSourceController;
@synthesize mFacialFeatures = _mFacialFeatures;
@synthesize mCaptureSessionPreset = _mCaptureSessionPreset;
@synthesize imgPicker,popOver;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // To reset the display of lighbox...
    CMApplicationModel *applicationModel = [[CMApplicationModel alloc] init];
    [applicationModel setToDisplayLightBox:YES];
    
    self.mModelPhotoID = [NSNumber numberWithInt:-1];
    self.mRequestActionToSourceController = [NSString stringWithFormat:@"None"];
    CMUserProfileMap *userData = (CMUserProfileMap *) [[[CMUserModel alloc] initForUserProfile] getUserProfileMapObject];
    
    if (userData.profileID == nil && userData.userID != nil)
    {
        self.navigationItem.hidesBackButton = YES;
    }
    else
    {
        self.navigationItem.hidesBackButton = NO;
    }
    
    [self setImgPicker:[[UIImagePickerController alloc] init]];
	[[self imgPicker ] setAllowsEditing:YES];
	[[self imgPicker ] setDelegate:self];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

// following function is must when setting source view controller as a delegate
// of destination view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"goFacebookPhotoAlbums"])
    {
        CMFacebookPhotoAlbumViewController *facebookPhotoAlbumViewController = (CMFacebookPhotoAlbumViewController *)[segue destinationViewController];
        facebookPhotoAlbumViewController.photoAlbums = self.facebookAlbums;
    }
    
    if([[segue identifier] isEqualToString:@"goModelUpload"])
    {
        CMSelectModelPhotoViewController *selectModelPhotoViewController = (CMSelectModelPhotoViewController *) [segue destinationViewController];
        [selectModelPhotoViewController configure];
        
    }
    
}

// on pressing cancel button in the destination view, this function will be called
-(void) captureViewControllerDidCancel:(CMCameraCaptureViewController *)controller
{
    [self.view setHidden:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}

// on pressing cancel button in the destination view, this function will be called
-(void) captureViewControllerDidFinish:(CMCameraCaptureViewController *)controller
{
    
    // for beta testing
#ifdef BETATESTING
    [TestFlight passCheckpoint:@"PHOTO_CAPTURED"];
    
#endif
    
    self.mProfilePhotoURL = [controller mImgFileURL];
    
    self.mFacialFeatures = [controller mFacialFeatures];
    
    self.mCaptureSessionPreset = [controller mCaptureSessionPreset];
    
    // following indicates source controller of color processing is camera capture
    self.mModelPhotoID = [NSNumber numberWithInt:-1];
    
    [self.view setHidden:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    
    // give back control to the source view controller which is
    // the delegate of current view controller
    //[[self delegate] CMBeautyTakePhotoViewControllerDidFinish:self];
    
    if([self mProfilePhotoURL] != nil)
        [self performSegueWithIdentifier:@"showColorProcessingView" sender:self];
    
    
}


-(void) captureViewController:(CMCameraCaptureViewController *)captureViewController didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
        alertView = nil;
    });
}


/*
 * Methods to upload photo from facebook.
 */

- (IBAction)uploadFromFacebookPressed {
    
    LogInfo(@"Upload from FB button pressed");
    
    if ([[CMNetworkAvailability sharedGlobal]checkInternetConnection])
    {
        if(FBSession.activeSession.isOpen)
        {
            // To get user's permission to access photos...
            [SVProgressHUD showWithStatus:@"Getting permission" maskType:SVProgressHUDMaskTypeGradient];
            
            if ([FBSession.activeSession.permissions indexOfObject:@"user_photos"] == NSNotFound)
            {
                [FBSession.activeSession
                 reauthorizeWithReadPermissions: [NSArray arrayWithObject:@"user_photos"]
                 completionHandler:^(FBSession *session, NSError *error) {
                     if (!error)
                     {
                         // If permissions granted, grab user's phots...
                         LogInfo(@"Facebook: User granted permission to access photos.");
                         [self grabUserPhotosFromFacebook];
                     }
                     else
                     {
                         [SVProgressHUD dismiss];
                         LogError(@"Facebook: Photo Access Permission. Error: %@", error.description);
                     }
                 }];
            }
            else
            {
                // If permissions granted, grab user's phots...
                LogInfo(@"Facebook: Permission to access photos is present.");
                [self grabUserPhotosFromFacebook];
            }
        }
        else
        {
            NSLog(@"session is closed!");
            IMANAppDelegate *appDelegate =(IMANAppDelegate *) [[UIApplication sharedApplication] delegate];
            //CMBeautyAppDelegate *appDelegate = (CMBeautyAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate openSessionWithAllowLoginUI:YES];
        }

    }
    else
    {
        [self showAlertWithTitle:@"Network Error"
                     WithMessage:@"It appears you have lost internet connectivity. Please check your network settings."];
    }
        
}

- (void) grabUserPhotosFromFacebook
{
    // getting user albums...
    [SVProgressHUD setStatus:@"Getting user album"];
    
    [[FBRequest requestForGraphPath:@"me/albums"] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary <FBGraphObject> *albumsData, NSError *error){
         if(!error)
         {
             self.facebookAlbums = [albumsData objectForKey:@"data"];
             [self performSegueWithIdentifier:@"goFacebookPhotoAlbums" sender:self];
             LogInfo(@"Facebook: Got user albums.");
         }
         else
         {
             [SVProgressHUD dismiss];
             LogError(@"Facebook: Could not get user pictures. Error: %@", error.description);
             self.facebookAlbums = nil;
         }
     }];
}

- (IBAction)useAModelPressed:(id)sender {

    LogInfo(@"Use a model button pressed");

    [self performSegueWithIdentifier:@"goModelUpload" sender:self];
}


- (IBAction)getFromLibraryPressed:(id)sender{
    
    LogInfo(@"Upload from library button pressed");
    
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIView *anchor = sender;
        self.popOver = [[UIPopoverController alloc] initWithContentViewController:imgPicker];;
        popOver.delegate = self;
        [self.popOver presentPopoverFromRect:anchor.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
    }
    else
    {
        [self presentModalViewController:imgPicker animated:YES];
    }
}


#pragma mark - UIImagePickerController delegate methods

- (IBAction)grabImage{
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc]init];
    [imagePicker setAllowsEditing:YES];
    [imagePicker setDelegate:self];
	[self presentModalViewController:imagePicker animated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (popOver) {
        [popOver dismissPopoverAnimated:YES];
    }
    
    [SVProgressHUD showWithStatus:STR_LOADING maskType:SVProgressHUDMaskTypeGradient];
    
    // the image grabbed from the device...
    UIImage *img=[info objectForKey:UIImagePickerControllerEditedImage];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"" forKey:@"hair"];
    [parameters setObject:@"" forKey:@"eyes"];
    [parameters setObject:@"" forKey:@"skin"];
    [parameters setObject:@"" forKey:@"lips"];
    
    NSURL *remoteUrl = [NSURL URLWithString:server];
    NSData *photoImageData = UIImageJPEGRepresentation(img, 1.0);
   
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:remoteUrl];
    
    NSMutableURLRequest *afRequest = [httpClient
                                      multipartFormRequestWithMethod:@"POST"
                                      path:pathToAPICAllForUploadingNewProfileImage
                                      parameters:parameters
                                      constructingBodyWithBlock:
                                      ^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:photoImageData
                                                                      name:@"u_photo"
                                                                  fileName:nil
                                                                  mimeType:@"image/JPG"];
                                          
                                      }];
    NSLog(@"afRequest: %@ with param %@", afRequest,parameters);

    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:afRequest];
    
    // if the server call is successful...
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON)
     {
         BOOL success=[[JSON objectForKey:@"success"] boolValue];
         if (success)
         {
             [[[CMUserModel alloc]initForUserProfile] updateUserProfileDataWithJSONForUploadsImport:JSON];
             NSLog(@"response: %@",JSON);
             //[self.controller performSegueWithIdentifier:@"goMyProfile" sender:self.controller];
             
             [self dismissModalViewControllerAnimated:YES];

             [self performSegueWithIdentifier:@"goMyProfileFromPhotoSource" sender:self];

             LogInfo(@"Successfully updated user image.");
             
             BOOL isLightingBad = NO;
             NSArray *errorArray=[JSON valueForKey:@"errors"];
             for (id obj in errorArray) {
                 if ([obj isEqualToString:@"too_dark"]) {
                     isLightingBad = YES;
                 }
                 if ([obj isEqualToString:@"too_light"]) {
                     isLightingBad = YES;
                 }
                 if ([obj isEqualToString:@"incandescent"]) {
                     isLightingBad = YES;
                 }
             }
             
             if(isLightingBad){
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"lightingBad" object:self];                 
             }
             
             
         }
         else
         {
             [self showAlertWithTitle:@"Oops..."
                          WithMessage:@"Some error occur could you please try again later."];
             LogError(@"There was an error uploading user image. JSON: %@", JSON);
             [self dismissModalViewControllerAnimated:YES];
         }
         
         [SVProgressHUD dismiss];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LogError(@"operaton:%@, error: %@", operation, error);
         [self showAlertWithTitle:@"Network Error"
                      WithMessage:@"It appears you have lost internet connectivity. Please check your network settings."];
         
         [self dismissModalViewControllerAnimated:YES];
         [SVProgressHUD dismiss];
         
     }
     ];
    
    [operation setUploadProgressBlock:
     ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
     }
     ];
    
    [operation start];    
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


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}




- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
