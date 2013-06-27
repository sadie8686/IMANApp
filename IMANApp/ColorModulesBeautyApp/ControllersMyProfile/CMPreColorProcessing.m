//
//  CMPreColorProcessing.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/15/13.
//
//

#import "CMPreColorProcessing.h"
#import "CMColorProcessing.h"
#import "ColorUtility.h"
#import "CMUserModel.h"
#import "CMConstants.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "Logging.h"
#import "CMApplicationModel.h"
#import "SVProgressHUD.h"

@interface CMPreColorProcessing (CMColorProcessorDelegate)

<CMColorProcessorDelegate>;

@end

@interface CMPreColorProcessing()

@property (nonatomic,strong) CMColorProcessing *colorProcessor;

@property (nonatomic,strong) NSMutableArray *strColorData;
@property (nonatomic,strong) NSMutableArray *strPositionData;
@property (strong,nonatomic) NSString *userPhotoPath;

@property (nonatomic,strong) NSMutableArray *mProfileColorsOriginal_RawRGB;
@property (nonatomic,strong) NSMutableArray *mProfileColorsCorrected_DeviceRGB;
@property (nonatomic,strong) NSMutableArray *mProfileColorsCorrected_sRGB;
@property (nonatomic,strong) NSMutableArray *mProfileColorsCorrected_Lab;

@property CGRect mAreaOfInterest;
//@property BOOL toColorCorrect;


@property (nonatomic,strong) NSNumber *modelPhotoID;
@property (nonatomic,strong) NSURL *imageFileURL;
@property (nonatomic,weak) CIFaceFeature *mFacialFeatures;

// mCaptureSessionPreset is needed since iPhone 3G saves image as 640x480 irrespective of session preset so the image is scaled to 320x240 and eye-mouth positions later needs to be scaled as well
@property (nonatomic,weak) NSString *mCaptureSessionPreset;

@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) CMApplicationModel *applicationModel;


@end


@implementation CMPreColorProcessing
@synthesize modelPhotoID = _modelPhotoID;
@synthesize imageFileURL = _imageFileURL;
@synthesize mFacialFeatures = _mFacialFeatures;
@synthesize strColorData = _strColorData;
@synthesize strPositionData = _strPositionData;
@synthesize userPhotoPath = _userPhotoPath;
@synthesize mProfileColorsOriginal_RawRGB = _mProfileColorsOriginal_RawRGB;
@synthesize mProfileColorsCorrected_DeviceRGB = _mProfileColorsCorrected_DeviceRGB;
@synthesize mProfileColorsCorrected_sRGB = _mProfileColorsCorrected_sRGB;
@synthesize mProfileColorsCorrected_Lab = _mProfileColorsCorrected_Lab;
@synthesize mCaptureSessionPreset = _mCaptureSessionPreset;
@synthesize controller = _controller;
@synthesize isModelPhoto;

- (id) initWithModelPhotoID: (NSNumber *) modelPhotoID
               WithImageURL: (NSURL *) imageFileURL
             WithController: (UIViewController *) controller
{
    if (self = [super init])
    {
        self.modelPhotoID = modelPhotoID;
        self.imageFileURL = imageFileURL;
        self.controller = controller;
        self.applicationModel = [[CMApplicationModel alloc] init];
        [self setupColorProcessor];
    }
    
    return self;
}

- (id) initWithCaptureSessionPreset: (NSString *) mCaptureSessionPreset
                       WithImageURL: (NSURL *) imageFileURL
                 WithFacialFeatures: (CIFaceFeature *) mFacialFeatures
                     WithController: (UIViewController *) controller
{
    if (self = [super init])
    {
        self.imageFileURL = imageFileURL;
        self.mFacialFeatures = mFacialFeatures;
        self.mCaptureSessionPreset = mCaptureSessionPreset;
        // self.modelPhotoID = [NSNumber numberWithInt:-1];
        self.controller = controller;
        [SVProgressHUD showWithStatus:@"Preparing to extract colors" maskType:SVProgressHUDMaskTypeGradient];
        self.applicationModel = [[CMApplicationModel alloc] init];
        [self setupColorProcessor];
    }
    return self;
}


- (void) setupColorProcessor
{
    
    self.strPositionData = [NSMutableArray arrayWithCapacity:4];
    self.strColorData = [NSMutableArray arrayWithCapacity:4];
    
    // Setup color processor...
    if ([self colorProcessor] == nil)
    {
        CMColorProcessing *processor = [[CMColorProcessing alloc] init];
        [self setColorProcessor: processor];
        processor = nil;
        [self.colorProcessor setDelegate: self];
    }
    
    // profile colors: skin device, skin sRGB, lip device, lip sRGB etc...
    self.mProfileColorsOriginal_RawRGB = [NSMutableArray arrayWithCapacity: 4];
    self.mProfileColorsCorrected_DeviceRGB = [NSMutableArray arrayWithCapacity: 4];
    self.mProfileColorsCorrected_sRGB = [NSMutableArray arrayWithCapacity: 4];
    self.mProfileColorsCorrected_Lab = [NSMutableArray arrayWithCapacity: 4];
}


- (void) extractColorsForModelPhoto
{
    // To store eye and mouth positions...
    CGPoint leftEyePos, rightEyePos, mouthPos;
    
    
    // source controller is select model photo view
    CGRect *skinAreaRect = calloc(5, sizeof(CGRect));
    CGRect *eyeAreaRect = calloc(2, sizeof(CGRect));
    CGRect *lipAreaRect = calloc(1, sizeof(CGRect));
    CGRect *hairAreaRect = calloc(5, sizeof(CGRect));
    
    eyeAreaRect[0] = CGRectMake(leftEyePos.x, leftEyePos.y, 10, 10);
    eyeAreaRect[1] = CGRectMake(rightEyePos.x, rightEyePos.y, 10, 10);
    lipAreaRect[0] = CGRectMake(mouthPos.x, mouthPos.y, 10, 10);
    
    UIColor *meanSkinColor, *meanLipColor, *meanEyeColor, *meanHairColor;
    
    // get positions
    [self
     getFacialFeatureLocationsFromModelPhoto:[[self modelPhotoID] intValue]
     HairArea: &hairAreaRect
     SkinArea: &skinAreaRect
     EyeArea:&eyeAreaRect
     LipArea:&lipAreaRect];
    
    // get colors
    [self
     getFacialColorsFromModelPhoto: [[self modelPhotoID] intValue]
     HairColor: &meanHairColor
     SkinColor: &meanSkinColor
     EyeColor: &meanEyeColor
     LipColor: &meanLipColor];
    
    [self.mProfileColorsOriginal_RawRGB addObject: meanEyeColor];
    [self.mProfileColorsOriginal_RawRGB addObject: meanSkinColor];
    [self.mProfileColorsOriginal_RawRGB addObject: meanLipColor];
    [self.mProfileColorsOriginal_RawRGB addObject: meanHairColor];
    
    
    NSString *hairRectPosition = [NSString stringWithFormat:@"[%d, %d, %d, %d]",
                                  (int)hairAreaRect->origin.x,
                                  (int)hairAreaRect->origin.y,
                                  (int)hairAreaRect->size.width,
                                  (int)hairAreaRect->size.height];
    
    NSString *eyeRectPosition = [NSString stringWithFormat:@"[%d, %d, %d, %d]",
                                 (int)eyeAreaRect->origin.x,
                                 (int)eyeAreaRect->origin.y,
                                 (int)eyeAreaRect->size.width,
                                 (int)eyeAreaRect->size.height];
    
    NSString *skinRectPosition = [NSString stringWithFormat:@"[%d, %d, %d, %d]",
                                  (int)skinAreaRect->origin.x,
                                  (int)skinAreaRect->origin.y,
                                  (int)skinAreaRect->size.width,
                                  (int)skinAreaRect->size.height];
    
    NSString *lipRectPosition = [NSString stringWithFormat:@"[%d, %d, %d, %d]",
                                 (int)lipAreaRect->origin.x,
                                 (int)lipAreaRect->origin.y,
                                 (int)lipAreaRect->size.width,
                                 (int)lipAreaRect->size.height];
    
    
    free(hairAreaRect);
    free(eyeAreaRect);
    free(skinAreaRect);
    free(lipAreaRect);
    
    [self.strPositionData addObject:hairRectPosition];
    [self.strPositionData addObject:eyeRectPosition];
    [self.strPositionData addObject:skinRectPosition];
    [self.strPositionData addObject:lipRectPosition];
    
    hairRectPosition = nil; eyeRectPosition = nil; skinRectPosition = nil; lipRectPosition = nil;
    
    [self UpdateInterfaceColors];
    [self updateServerNow];
    
}


- (void) extractColorsForPhotoCapturedFromCamera
{
    // To store eye and mouth positions...
    CGPoint leftEyePos, rightEyePos, mouthPos;
    
    // To create a dispatch queue...
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // To get the image into data buffer
    NSString *imagePath = [self.imageFileURL path];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    NSURL *imgURL = [NSURL fileURLWithPath:imagePath];
    
    // To save origin image
    CMApplicationModel *applicationModel = [[CMApplicationModel alloc] init];
    [applicationModel setOriginalImage:UIImagePNGRepresentation(image)];

    // To start the session: read image and metadata etc...
    CGImageRef imageRef = [image CGImage];
    [[self colorProcessor] openColorExtractionSession: imageRef];
    
    if (self.mFacialFeatures)
    {
        // source controller is camera capture
        // ----------- added on 07/02/2012 ----------
        // following is needed for iPhone 3G - size is always 640x480 irrespective of session preset
        // crashing; thus, a scale factor of 2.0 is used used before saving the image as 320 x 240
        float scaleFactorX = 1.0, scaleFactorY = 1.0;
        float sessionPresetWidth = 0, sessionPresetHeight = 0;
        
        if ([[self mCaptureSessionPreset] compare: @"AVCaptureSessionPreset352x288"] == NSOrderedSame) {
            sessionPresetWidth = 288.0; sessionPresetHeight = 352.0;
        }
        else if ([[self mCaptureSessionPreset] compare: @"AVCaptureSessionPreset640x480"] == NSOrderedSame) {
            sessionPresetWidth = 480.0; sessionPresetHeight = 640.0;
        }
        else if ([[self mCaptureSessionPreset] compare: @"AVCaptureSessionPresetMedium"] == NSOrderedSame) {
            // this has to be iPhone 3G (not 3GS), other two should have worked otherwise
            // for iPhone 3G Medium is 400x304
            sessionPresetWidth = 304.0; sessionPresetHeight = 400.0;
        }
        
        scaleFactorX = CGImageGetWidth(imageRef)/sessionPresetWidth;
        scaleFactorY = CGImageGetHeight(imageRef)/sessionPresetHeight;
        
        LogInfo(@"About to start extract: Captured image size = (%zu, %zu), Session Preset was %@ = (%4.0f, %4.0f)", CGImageGetHeight(imageRef), CGImageGetWidth(imageRef), [self mCaptureSessionPreset], sessionPresetHeight, sessionPresetWidth);
        
        leftEyePos.x = ceilf(self.mFacialFeatures.leftEyePosition.y * scaleFactorX) - 8;
        leftEyePos.y = ceilf(self.mFacialFeatures.leftEyePosition.x * scaleFactorY) - 5;
        
        rightEyePos.x = ceilf(self.mFacialFeatures.rightEyePosition.y * scaleFactorX) - 5;
        rightEyePos.y = ceilf(self.mFacialFeatures.rightEyePosition.x * scaleFactorY) - 5;
        
        mouthPos.x = ceilf(self.mFacialFeatures.mouthPosition.y * scaleFactorX) - 10;
        mouthPos.y = ceilf(self.mFacialFeatures.mouthPosition.x * scaleFactorY);
    }
    
    /*  else if([[self modelPhotoID] intValue] < 1)
     {
     // no facial feature positions exist, even though the source controller is camera capture
     NSString *msg = [NSString stringWithFormat:@"There was a problem with face detection. Color extraction cannot proceed. Please retake your photo."];
     
     CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
     UIAlertView *alertView = [[UIAlertView alloc]
     initWithTitle:@"Color Extraction Failure"
     message:msg
     delegate:nil
     cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
     otherButtonTitles:nil];
     [alertView show];
     alertView = nil;
     });
     
     }*/
    
    
    
    // ------------------------ form the face area -----------------------
    CGFloat faceStartX = (leftEyePos.x - (rightEyePos.x - leftEyePos.x)/2);
    if(faceStartX < 0) faceStartX = 3.0;
    
    CGFloat faceStartY = (2.2 * leftEyePos.y - 1.3 * mouthPos.y);
    if(faceStartY < 0) faceStartY = 3.0;
    
    CGFloat faceWidth = ((rightEyePos.x - leftEyePos.x) * 2.0);
    CGFloat faceHeight = ((mouthPos.y - leftEyePos.y) * 2.8);
    
    if((faceStartX + faceWidth) > CGImageGetWidth(imageRef)) faceWidth = CGImageGetWidth(imageRef) - faceStartX;
    if((faceStartY + faceHeight) > CGImageGetHeight(imageRef)) faceHeight = CGImageGetHeight(imageRef) - faceStartY;
    
    // using faceRect instead of whole image saves around 6s
    //mAreaOfInterest = CGRectMake(faceStartX, faceStartY, faceWidth, faceHeight);
    
    self.mAreaOfInterest = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    
    
    // ----------- first get rid of old color profile data ------------
    [self.mProfileColorsOriginal_RawRGB removeAllObjects];
    [self.mProfileColorsCorrected_DeviceRGB removeAllObjects];
    [self.mProfileColorsCorrected_sRGB removeAllObjects];
    [self.mProfileColorsCorrected_Lab removeAllObjects];
    [self.strPositionData removeAllObjects];
    [self.strColorData removeAllObjects];
    
    CGImageRetain(imageRef);
    
    // Start the processing asychronously
    dispatch_async(queue, ^{
        [self.colorProcessor
         correctAndExtractColorProfileDataFromFacialImage:imageRef
         atRect: self.mAreaOfInterest
         LeftEyePosition: leftEyePos
         RightEyePosition: rightEyePos
         MouthPosition: mouthPos
         withImageURL: imgURL];
    });
}


/*
 TODO: Need to make this dynamic eventually...
 */
-(void)getFacialFeatureLocationsFromModelPhoto: (int) modelPhotoID
                                      HairArea: (CGRect **) hairRect
                                      SkinArea: (CGRect **)skinRect
                                       EyeArea: (CGRect **) eyeRect
                                       LipArea:(CGRect **) lipRect
{
    
    switch (modelPhotoID) {
        case 1:
            *hairRect[0] = CGRectMake(145, 12, 10, 10);
            *skinRect[0] = CGRectMake(50, 115, 10, 10);
            *eyeRect[0] = CGRectMake(51, 91, 3, 3);
            *eyeRect[1] = CGRectMake(121, 87, 3, 3);
            *lipRect[0] = CGRectMake(89, 165, 5, 5);
            break;
            
        case 2:
            *hairRect[0] = CGRectMake(215, 71, 10, 10);
            *skinRect[0] = CGRectMake(180, 160, 10, 10);
            *eyeRect[0] = CGRectMake(103, 138, 3, 3);
            *eyeRect[1] = CGRectMake(181, 138, 3, 3);
            *lipRect[0] = CGRectMake(140, 213, 5, 5);
            break;
            
        case 3:
            *hairRect[0] = CGRectMake(79, 38, 10, 10);
            *skinRect[0] = CGRectMake(132, 132, 10, 10);
            *eyeRect[0] = CGRectMake(84, 110, 3, 3);
            *eyeRect[1] = CGRectMake(129, 114, 3, 3);
            *lipRect[0] = CGRectMake(103, 167, 5, 5);
            break;
            
        case 4:
            *hairRect[0] = CGRectMake(99, 36, 10, 10);
            *skinRect[0] = CGRectMake(95, 85, 10, 10);
            *eyeRect[0] = CGRectMake(58, 72, 2, 2);
            *eyeRect[1] = CGRectMake(91, 68, 2, 2);
            *lipRect[0] = CGRectMake(75, 107, 2, 2);
            break;
            
        case 5:
            *hairRect[0] = CGRectMake(17, 53, 10, 10);
            *skinRect[0] = CGRectMake(60, 96, 10, 10);
            *eyeRect[0] = CGRectMake(71, 78, 2, 2);
            *eyeRect[1] = CGRectMake(113, 79, 2, 2);
            *lipRect[0] = CGRectMake(94, 131, 3, 3);
            break;
            
        case 6:
            *hairRect[0] = CGRectMake(71, 13, 5, 5);
            *skinRect[0] = CGRectMake(54, 104, 10, 10);
            *eyeRect[0] = CGRectMake(60, 80, 2, 2);
            *eyeRect[1] = CGRectMake(128, 79, 2, 2);
            *lipRect[0] = CGRectMake(96, 155, 3, 3);
            break;
            
        case 7:
            *hairRect[0] = CGRectMake(166, 20, 10, 10);
            *skinRect[0] = CGRectMake(82, 160, 10, 10);
            *eyeRect[0] = CGRectMake(89, 115, 3, 3);
            *eyeRect[1] = CGRectMake(186, 121, 3, 3);
            *lipRect[0] = CGRectMake(131, 217, 5, 5);
            break;
            
        default:
            break;
    }
}

-(void)getFacialColorsFromModelPhoto: (int) modelPhotoID
                           HairColor: (UIColor **) hairColor
                           SkinColor: (UIColor **)skinColor
                            EyeColor: (UIColor **) eyeColor
                            LipColor:(UIColor **) lipColor
{
    
    switch (modelPhotoID) {
        case 1:
            *hairColor = [UIColor colorWithRed: 195.0/255.0 green:162.0/255.0 blue:109/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 240.0/255.0 green: 195.0/255.0 blue: 176.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 90.0/255.0 green:107.0/255.0 blue: 88.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 214.0/255.0 green: 106.0/255.0 blue:103.0/255.0 alpha:1.0];
            break;
            
        case 2:
            *hairColor = [UIColor colorWithRed: 25.0/255.0 green:17.0/255.0 blue:14.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 194.0/255.0 green:113.0/255.0 blue:66.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 23.0/255.0 green:18.0/255.0 blue:14.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 178.0/255.0 green:130.0/255.0 blue:120.0/255.0 alpha:1.0];
            break;
            
        case 3:
            *hairColor = [UIColor colorWithRed: 39.0/255.0 green: 34.0/255.0 blue: 31.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 247.0/255.0 green: 209.0/255.0 blue: 198.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 88.0/255.0 green: 48.0/255.0 blue: 22.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 238.0/255.0 green: 152.0/255.0 blue: 153.0/255.0 alpha:1.0];
            break;
            
        case 4:
            *hairColor = [UIColor colorWithRed: 30.0/255.0 green: 29.0/255.0 blue: 34.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 190.0/255.0 green: 148.0/255.0 blue: 134.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 31.0/255.0 green: 19.0/255.0 blue: 23.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 189.0/255.0 green: 130.0/255.0 blue: 148.0/255.0 alpha:1.0];
            break;
            
        case 5:
            *hairColor = [UIColor colorWithRed: 90.0/255.0 green: 57.0/255.0 blue: 42.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 234.0/255.0 green: 175.0/255.0 blue: 143.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 25.0/255.0 green: 20.0/255.0 blue: 14.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 221.0/255.0 green: 129.0/255.0 blue: 130.0/255.0 alpha:1.0];
            break;
            
        case 6:
            *hairColor = [UIColor colorWithRed: 74.0/255.0 green: 52.0/255.0 blue: 41.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 232.0/255.0 green: 178.0/255.0 blue: 166.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 98.0/255.0 green: 58.0/255.0 blue: 50.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 225.0/255.0 green: 160.0/255.0 blue: 168.0/255.0 alpha:1.0];
            break;
            
        case 7:
            *hairColor = [UIColor colorWithRed: 139.0/255.0 green: 54.0/255.0 blue: 61.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 248.0/255.0 green: 219.0/255.0 blue: 203.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 100.0/255.0 green: 137.0/255.0 blue: 205.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 235.0/255.0 green: 163.0/255.0 blue: 166.0/255.0 alpha:1.0];
            break;
            
        case 8:
            *hairColor = [UIColor colorWithRed: 15.0/255.0 green: 12.0/255.0 blue: 7.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 201.0/255.0 green: 135.0/255.0 blue: 100.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 25.0/255.0 green: 10.0/255.0 blue: 5.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 198.0/255.0 green: 103.0/255.0 blue: 97.0/255.0 alpha:1.0];
            break;
            
        case 9:
            *hairColor = [UIColor colorWithRed: 37.0/255.0 green: 36.0/255.0 blue: 42.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 134.0/255.0 green: 76.0/255.0 blue: 64.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 28.0/255.0 green: 25.0/255.0 blue: 32.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 166.0/255.0 green: 110.0/255.0 blue: 113.0/255.0 alpha:1.0];
            break;
            
        case 10:
            *hairColor = [UIColor colorWithRed: 38.0/255.0 green: 23.0/255.0 blue: 16.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 242.0/255.0 green: 180.0/255.0 blue: 159.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 103.0/255.0 green: 112.0/255.0 blue: 119.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 221.0/255.0 green: 126.0/255.0 blue: 132.0/255.0 alpha:1.0];
            break;
            
        case 11:
            *hairColor = [UIColor colorWithRed: 35.0/255.0 green: 37.0/255.0 blue: 34.0/255.0 alpha:1.0];
            *skinColor = [UIColor colorWithRed: 217.0/255.0 green: 155.0/255.0 blue: 134.0/255.0 alpha:1.0];
            *eyeColor = [UIColor colorWithRed: 72.0/255.0 green: 58.0/255.0 blue: 49.0/255.0 alpha:1.0];
            *lipColor = [UIColor colorWithRed: 205.0/255.0 green: 126.0/255.0 blue: 122.0/255.0 alpha:1.0];
            break;
            
        default:
            break;
    }
}

- (void) UpdateInterfaceColors
{
    UIColor *skinColor, *lipColor, *eyeColor, *hairColor;
    
    if(!self.modelPhotoID) // Thus not a model photo...
    {
        // To clear all colorCorrectData from application model...
        [self.applicationModel clearColorCorrectedData];
        
        // To Save that the user photo was uploaded and save the color corrected colors...
        [self.applicationModel setToColorCorrect:YES];
        
        // ------------------- show corrected colors -------------------
        eyeColor = [self.mProfileColorsCorrected_sRGB objectAtIndex:0];
        skinColor = [self.mProfileColorsCorrected_sRGB objectAtIndex:1];
        lipColor = [self.mProfileColorsCorrected_sRGB objectAtIndex:2];
        hairColor = [self.mProfileColorsCorrected_sRGB objectAtIndex:3];
        
        [self.applicationModel setColorCorrectedValueWithEyeColor: eyeColor
                                                    WithSkinColor: skinColor
                                                     WithLipColor: lipColor
                                                    WithHairColor: hairColor];
        
        self.applicationModel = nil;
    }
    
    else
    {
        // To clear all colorCorrectData from application model...
        [self.applicationModel clearColorCorrectedData];
        
        // To set the color correct to no...
        [self.applicationModel setToColorCorrect:NO];
        self.applicationModel = nil;
    }
    
    
    // show uncorrected, extracted colors
    eyeColor = [self.mProfileColorsOriginal_RawRGB objectAtIndex:0];
    skinColor = [self.mProfileColorsOriginal_RawRGB objectAtIndex:1];
    lipColor = [self.mProfileColorsOriginal_RawRGB objectAtIndex:2];
    hairColor = [self.mProfileColorsOriginal_RawRGB objectAtIndex:3];
    
    NSString *hairCode = [ColorUtility hexadecimalValueOfAUIColor: hairColor];
    NSString *eyeCode = [ColorUtility hexadecimalValueOfAUIColor: eyeColor];
    NSString *skinCode = [ColorUtility hexadecimalValueOfAUIColor: skinColor];
    NSString *lipCode = [ColorUtility hexadecimalValueOfAUIColor: lipColor];
    
    // To update server db with new colors...
    [self.strColorData addObject:hairCode];
    [self.strColorData addObject:eyeCode];
    [self.strColorData addObject:skinCode];
    [self.strColorData addObject:lipCode];
    
    // To save user's profile image to local db...
    self.userPhotoPath = [self.imageFileURL path];
}


- (void) updateServerNow
{
    // To upload the photo & colors to the server and get a response with calculated values...
    NSURL *remoteUrl = [NSURL URLWithString:server];
    NSData *photoImageData = [NSData dataWithContentsOfFile:self.userPhotoPath];//UIImageJPEGRepresentation(image, 1.0);
        
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[self.strColorData objectAtIndex:0] forKey:@"hair"];
    [parameters setObject:[self.strColorData objectAtIndex:1] forKey:@"eyes"];
    [parameters setObject:[self.strColorData objectAtIndex:2] forKey:@"skin"];
    [parameters setObject:[self.strColorData objectAtIndex:3] forKey:@"lips"];
    
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
             [self.controller performSegueWithIdentifier:@"goMyProfile" sender:self.controller];
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
             
             if(isLightingBad&&!self.isModelPhoto){
                 //[self showAlertWithTitle:@"Oops..." WithMessage:@"lighting bad take another"];
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"lightingBad" object:self];
                 
             }
             
             
         }
         else
         {
             [self showAlertWithTitle:@"Oops..."
                          WithMessage:@"Some error occur could you please try again later."];
             LogError(@"There was an error uploading user image. JSON: %@", JSON);
             [self.controller.navigationController popToRootViewControllerAnimated:NO];
         }
         
         [SVProgressHUD dismiss];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LogError(@"operaton:%@, error: %@", operation, error);
         [self showAlertWithTitle:@"Network Error"
                      WithMessage:@"It appears you have lost internet connectivity. Please check your network settings."];
         [self.controller.navigationController popToRootViewControllerAnimated:NO];
         
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


@end




@implementation CMPreColorProcessing (CMColorProcessorDelegate)

- (void)colorProcessor:(CMColorProcessing *)colorProcessor didFailWithError:(NSError *)error
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



- (void) showError:(CMColorProcessing *)colorProcessor ErrorMessage:(NSString *) errMsg
{
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [SVProgressHUD showErrorWithStatus:errMsg];
    });
}



- (void)  updateProcessingStatus:(CMColorProcessing *)colorProcessor StatusCode:(int) code
{
    __block NSString *strCode;
    
    switch (code) {
        case 0:
            strCode = [NSString stringWithFormat:@"Initializing color processing..."];
            break;
        case 1:
            strCode = [NSString stringWithFormat:@"Estimating scene lighting..."];
            break;
        case 2:
            strCode = [NSString stringWithFormat:@"Preparing for color correction..."];
            break;
        case 3:
            strCode = [NSString stringWithFormat:@"Extracting eye color..."];
            break;
        case 4:
            strCode = [NSString stringWithFormat:@"Extracting skin color..."];
            break;
        case 5:
            strCode = [NSString stringWithFormat:@"Extracting lip color..."];
            break;
        case 6:
            strCode = [NSString stringWithFormat:@"Extracting hair color..."];
            break;
        case 7:
            strCode = [NSString stringWithFormat:@"Saving profile colors and corrected photo..."];
            break;
            
            
        default:
            strCode = [NSString stringWithFormat:@"Processing..."];
            break;
            
    }
    
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [SVProgressHUD setStatus:strCode];
    });
}


- (void) profileColorsComputed:(CMColorProcessing *)colorProcessor
{
    for (UIColor * aColor in [[self colorProcessor] mProfileColorsOriginal_RawRGB])
        [self.mProfileColorsOriginal_RawRGB addObject:aColor];
    
    for (UIColor * aColor in [[self colorProcessor] mProfileColorsCorrected_DeviceRGB])
        [self.mProfileColorsCorrected_DeviceRGB addObject:aColor];
    
    for (UIColor * aColor in [[self colorProcessor] mProfileColorsCorrected_sRGB])
        [self.mProfileColorsCorrected_sRGB addObject:aColor];
    
    for(NSArray *objLab in [[self colorProcessor] mProfileColorsCorrected_Lab])
        [self.mProfileColorsCorrected_Lab addObject: objLab];
    
    
    
    // show all colors depending on the switch settings
    [self UpdateInterfaceColors];
    
    
    
}


- (void) processingComplete:(CMColorProcessing *)colorProcessor
{
    self.imageFileURL = self.colorProcessor.mCorrectedPhotoURL;
    [[self colorProcessor] closeColorExtractionSession];
    [self UpdateInterfaceColors];
    [self updateServerNow];
}

- (void) processingDidCancel:(CMColorProcessing *)colorProcessor
{
    [self.controller.navigationController popViewControllerAnimated:NO];
}

- (void) newImageRowComputed:(CMColorProcessing *)colorProcessor RawPixelData:(unsigned char *) imageData ImageWidth: (int) width ImageHeight: (int) height RowIndex: (int) rowIndex ProcessingTimeLeft: (float) timeLeft
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [SVProgressHUD setStatus:[NSString stringWithFormat:@"Please wait—we're extracting your colors %2.0f", timeLeft]];
    });
}

@end

