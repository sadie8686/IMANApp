//
//  FacebookPhotoAlbumViewController.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 1/29/13.
//
//

#import "CMFacebookPhotoAlbumViewController.h"
#import "FacebookSDK/FacebookSDK.h"
#import "CMFacebookPhotoAlbumCell.h"
#import "UIImageView+AFNetworking.h"
#import "Logging.h"
#import "CMFacebookPhotoViewController.h"
#import "SVProgressHUD.h"
#import "CMUserModel.h"
#import "AFHTTPClient.h"
#import "CMConstants.h"
#import "AFJSONRequestOperation.h"

@interface CMFacebookPhotoAlbumViewController ()
@property (nonatomic, strong) NSMutableArray *thisAlbumPhotos;
@property (nonatomic, strong) CMUserProfileMap *oldProfile;
@property (nonatomic) int indexOfAlbumSelected;
@end

@implementation CMFacebookPhotoAlbumViewController
@synthesize photoAlbums = _photoAlbums;
@synthesize thisAlbumPhotos = _thisAlbumPhotos;
@synthesize oldProfile = _oldProfile;
@synthesize indexOfAlbumSelected = _indexOfAlbumSelected;

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.oldProfile = [[[CMUserModel alloc] initForUserProfile] getUserProfileMapObject];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD dismiss];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows = 1;
    int numberOfContainersThisRow = 2;
    if (self.photoAlbums.count > numberOfContainersThisRow)
    {
        numberOfRows = self.photoAlbums.count / numberOfContainersThisRow;
        if((self.photoAlbums.count % numberOfContainersThisRow) > 0)
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
    CMFacebookPhotoAlbumCell *cell = (CMFacebookPhotoAlbumCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[CMFacebookPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    //Configure the cell...
    int numberOfContainersInThisCell = 2;
    int photosDisplayed = (indexPath.row * numberOfContainersInThisCell);
    if((photosDisplayed + numberOfContainersInThisCell)> self.photoAlbums.count)
    {
        numberOfContainersInThisCell = self.photoAlbums.count - photosDisplayed;
    }
    
    NSInteger currentAlbumNumber;
    NSDictionary *album;
    
    [cell.albumAContainer setHidden:YES];
    [cell.albumBContainer setHidden:YES];
    
    for (int i=0; i<numberOfContainersInThisCell; i++) {
        currentAlbumNumber = photosDisplayed + i;
        album = [self.photoAlbums objectAtIndex:currentAlbumNumber];
        
        NSString *coverImageID = [album objectForKey:@"id"];
        NSString *accessToken = FBSession.activeSession.accessToken;
        NSURL *coverImageURL = [NSURL URLWithString:
                                [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=album&access_token=%@", coverImageID, accessToken]];
        
        switch (i) {
            case 0:
            {
                [cell.albumAContainer setHidden:NO];
                [cell.albumAContainer setTag: currentAlbumNumber];
                [cell.albumAContainer addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(tapAction:)]];
                [cell.albumAContainer setUserInteractionEnabled:YES];
                
                [cell.albumAName setText:[album objectForKey:@"name"]];
                [cell.albumACoverImage setImageWithURL:coverImageURL placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMG]];
                break;
                
            }
            case 1:
            {
                [cell.albumBContainer setHidden:NO];
                [cell.albumBContainer setTag: currentAlbumNumber];
                [cell.albumBContainer addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(tapAction:)]];
                [cell.albumBContainer setUserInteractionEnabled:YES];
                
                [cell.albumBName setText:[album objectForKey:@"name"]];
                [cell.albumBCoverImage setImageWithURL:coverImageURL placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMG]];
                break;
            }
            default:
                break;
        }
    }
    
    return cell;
}



//Action: when an album is selected, get the pictures in the album.
- (void)tapAction: (UIGestureRecognizer *)gestureRecognizer
{
    // Grabbing user's album pics...
    [SVProgressHUD showWithStatus:@"Loading pictures from album"];
    
    UIView *view = [gestureRecognizer view];
    self.indexOfAlbumSelected = view.tag;
    NSString *albumID = [[self.photoAlbums objectAtIndex:self.indexOfAlbumSelected] objectForKey:@"id"];
    NSString * path = [NSString stringWithFormat:@"%@/photos", albumID];
    [self grabUserPhotosFromFacebookForPath:path];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goFacebookThisAlbum"])
    {
        CMFacebookPhotoViewController *facebookPhotoViewController = (CMFacebookPhotoViewController *) [segue destinationViewController];
        facebookPhotoViewController.photosInThisAlbum = self.thisAlbumPhotos;
        facebookPhotoViewController.title = [[self.photoAlbums objectAtIndex:self.indexOfAlbumSelected] objectForKey:@"name"];
    }
}


- (void) grabUserPhotosFromFacebookForPath: (NSString *) path
{
    [[FBRequest requestForGraphPath:path] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary <FBGraphObject> *albumsData, NSError *error){
         if(!error)
         {
             self.thisAlbumPhotos = [[NSMutableArray alloc] initWithCapacity:[[albumsData objectForKey:@"data"] count]];
             for (NSDictionary *images in [albumsData objectForKey:@"data"])
             {
                 NSString *photoString = [[[images objectForKey:@"images"] objectAtIndex:0] objectForKey:@"source"];
                 photoString = [photoString stringByReplacingOccurrencesOfString:@"\"" withString:@""]; // To remove " from start and end of string.
                 
                 [self.thisAlbumPhotos addObject:[NSURL URLWithString:photoString]];
             }
             LogInfo(@"Facebook: Got pictures from user album.");
             [self performSegueWithIdentifier: @"goFacebookThisAlbum" sender: self];
             
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:@"Sorry, Could not get the pictures"];
             LogError(@"Facebook: Could not get pictures from album. Error: %@", error.description);
         }
     }];
}



- (IBAction)backButtonPressed:(id)sender {
    LogInfo(@"Reverting to the old profile");
    [SVProgressHUD showWithStatus:@"Reverting to previous image" maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@", server, pathToAPICallToActivateProfileID, self.oldProfile.profileID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSLog(@"Request: %@", [request description]);
    NSLog(@"Header: %@", [request allHTTPHeaderFields]);
    NSLog(@"Request body: %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         BOOL success=[[JSON objectForKey:@"success"] boolValue];
         if (success)
         {
             LogInfo(@"Revert to profile success JSON: %@", JSON);
             [[[CMUserModel alloc] initForUserProfile] updateUserProfileDataWithJSON:JSON];
             [SVProgressHUD dismiss];
             [self.navigationController popViewControllerAnimated:YES];
         }
         else
         {
             LogError(@"error: %@", JSON);
             [SVProgressHUD showErrorWithStatus:@"An error occured. Please try again."];
         }
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         LogError(@"Response Error:%@", error);
         [SVProgressHUD showErrorWithStatus:@"It appears you have lost internet connectivity. Please check your network settings."];
     }];
    [operation start];
}


@end

