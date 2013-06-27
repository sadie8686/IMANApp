/*--------------------------------------------------------------------------
 CMCameraCaptureViewController.m
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar
 
 Created by Abhijit Sarkar on 2012/01/25
 
 Description:
 Code for Camera capture view that appears when users press the Take My Photo button
 under Take Photo View (CMBeautyTakePhotoViewController).
 
 
 Revision history:
 2012/01/27 - by AS
 2012/02/05 - by AS, added major functionalities
 2012/02/16 - by AS, fixed bugs, added code to save image in Documents folder
 2012/03/05 - by AS, fixed bug (preview not appearing on next session), changed
 button label when disabled/highlighted, added code to prompt user
 to look at the camera
 2012/03/11 - by AS, allowing capture without face recognition for the time being
 updated user feedback label so as to have a grey background
 2012/03/21 - by AS, color correction/extraction code incorporated (3 PM)
 
 
 Existing Problems:
 (date) -
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/


#import "CMCameraCaptureViewController.h"
#import "CMCamCaptureManager.h"
#import "CMCamUtilities.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Logging.h"
#import "CMCustomTheme.h"
#import "CMPreColorProcessing.h"
#import "CMApplicationModel.h"


static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

// all delegate view controllers must be included here
@interface CMCameraCaptureViewController (CMCamCaptureManagerDelegate)
<CMCamCaptureManagerDelegate>;
@end

@interface CMCameraCaptureViewController (InternalMethods) <UIGestureRecognizerDelegate>

-(void) setupAVCapture;
-(void) teardownAVCapture;
-(void) setupVideoInterface;
-(void) tearDownVideoInterface;
-(void) updateButtonStates;
-(void) drawFaceBoxesForFeatures:(NSArray *) features
                     forVideoBox:(CGRect)clap
                     orientation:(UIDeviceOrientation)orientation;
@end



@implementation CMCameraCaptureViewController
@synthesize captureManager = _captureManager;
@synthesize videoPreviewView = _videoPreviewView;
@synthesize faceGuide = _faceGuide;
@synthesize flashView = _flashView;
@synthesize showActivityIndicator = _showActivityIndicator;
@synthesize captureVideoPreviewLayer = _captureVideoPreviewLayer;
@synthesize mExposureMarkerLayer = _mExposureMarkerLayer;
@synthesize mImgFileURL = _mImgFileURL;
@synthesize faceDetector = _faceDetector;
@synthesize mFacialFeatures = _mFacialFeatures;
@synthesize mCaptureSessionPreset = _mCaptureSessionPreset;
@synthesize cancelButton = _cancelButton;
@synthesize stillButton = _stillButton;
@synthesize lblCam = _lblCam;
@synthesize userFeedbackLabel = _userFeedbackLabel;
@synthesize square = _square;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // To set the camCapture disabled...
    [self.stillButton setEnabled:NO];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // not until the view completes loading
    mCameraWBUpdateStatus = 0; // 0: not started
    
    mExposurePointInViewLayer = CGPointZero;
    mExposurePointInDeviceCoords = CGPointMake(0.5f, 0.5f);
    
    mCameraExposureUpdateStatus = 0;
    mExposureNeedsImmediateUpdate = false;
    
    // To get screen's bounds...
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    // To set the still button position...
    float y = screenBounds.size.height - self.stillButton.frame.size.height - 20;
    [self.stillButton setFrame:CGRectMake(0, y, screenBounds.size.width, self.stillButton.frame.size.height)];
    
    // To set the faceGuide width and height and position...
    float faceGuideWidth = screenBounds.size.width;
    float faceGuideHeight = screenBounds.size.height - self.stillButton.frame.size.height*2;
    [self.faceGuide setFrame:CGRectMake(0, 10, faceGuideWidth, faceGuideHeight)];
    
    
    // To setup the picture preview...
    [self setupAVCapture];
    [self setupVideoInterface];
    
    // Setting up face detection...
    self.square = [UIImage imageNamed:@"squarePNG.png"];
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                           context:nil
                                           options:detectorOptions] ;
    detectorOptions = nil;
    mViewIsReadyForFaceDetection = YES;
    mIfToDetectFaces = YES;
    mFaceDetected = NO;
    
    // To set the camCapture disabled...
    [self.stillButton setEnabled:NO];
    
    // Setting activityIndicator properties...
    [self.showActivityIndicator hidesWhenStopped];
    [self.showActivityIndicator stopAnimating];
    [self.showActivityIndicator setHidden:YES];
    
}



-(void) setupAVCapture
{
    NSError *error = nil;
	if (self.captureManager == nil)
    {
        // To create capture manager...
		self.captureManager = [[CMCamCaptureManager alloc] init];
		[self.captureManager setDelegate:self];
        
        // error macro...
        require(error == nil, bail);
        
        // if no error, setup a capture manager session...
        [self.captureManager setupSession];
        self.mCaptureSessionPreset = self.captureManager.session.sessionPreset;
        
        NSLog(@"capturingStillImage: setupAVCapture");
        
        [self.captureManager.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void *)AVCaptureStillImageIsCapturingStillImageContext];
        
        // Create video preview layer and add it to the UI
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
        
        
        [newCaptureVideoPreviewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
        [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        CALayer *viewLayer = self.videoPreviewView.layer;
        [viewLayer setMasksToBounds:NO];
        
        CGRect bounds = [[self view] bounds];
        [newCaptureVideoPreviewLayer setFrame:bounds];
        
        if ([newCaptureVideoPreviewLayer.connection isVideoOrientationSupported]) {
            [newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        
        [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        
        
        [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
        newCaptureVideoPreviewLayer = nil;
        
        // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [[[self captureManager] videoOutput] setSampleBufferDelegate:self queue:videoDataOutputQueue];
        
        
        
        // --------- this is to show a marker during exposure control ---------
        // NOTE: do not move
        
        self.mExposureMarkerLayer = [[CAShapeLayer alloc] init];
        
        CGRect marker = CGRectMake(0, 0, 60, 60);
        
        [self.mExposureMarkerLayer setBounds:marker];
        [self.mExposureMarkerLayer setHidden:YES];
        [self.mExposureMarkerLayer setStrokeColor:[[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0] CGColor]];
        [self.mExposureMarkerLayer setFillColor:[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8] CGColor]];
        [self.mExposureMarkerLayer setLineWidth:2.0];
        [self.mExposureMarkerLayer setPosition:CGPointMake(bounds.size.width/2, bounds.size.height/2)];
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        // add two horizontal line for bull's eye
        CGPathMoveToPoint(path, NULL, 0, 30);
        CGPathAddLineToPoint(path, NULL, 17, 30);
        CGPathMoveToPoint(path, NULL, 43, 30);
        CGPathAddLineToPoint(path, NULL, 60, 30);
        
        // add two vertical line for bull's eye
        CGPathMoveToPoint(path, NULL, 30, 0);
        CGPathAddLineToPoint(path, NULL, 30, 17);
        CGPathMoveToPoint(path, NULL, 30, 43);
        CGPathAddLineToPoint(path, NULL, 30, 60);
        
        // add circle in the middle
        CGPathAddEllipseInRect(path, NULL, CGRectMake(10, 10, 40, 40));
        [self.mExposureMarkerLayer setPath:path];
        
        
        
        [[[self view] layer] insertSublayer:self.mExposureMarkerLayer above:[[viewLayer sublayers] objectAtIndex:0]];
        
        // ---------
        // Start the session. This is done asychronously since -startRunning doesn't return as long as the session is running
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(![[self captureManager] session].isRunning)
                [[[self captureManager] session] startRunning];
        });
        
        
        [self updateButtonStates];
        
        
    }
    
bail:
    
	if (error) {
        [[self captureManager] closeSession];
        
		UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                  message:[error localizedDescription]
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil];
		[alertView show];
		alertView = nil;
        
		[self teardownAVCapture];
        [self.navigationController popViewControllerAnimated:NO];
	}
    
    
    
}


-(void) setupVideoInterface
{
    UIView *view = [self videoPreviewView];
    CALayer *viewLayer = [view layer];
    
    // Create the focus mode UI overlay
    //UILabel *newuserFeedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 35, viewLayer.bounds.size.width - 4, 30)];
    
    UILabel *newuserFeedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, viewLayer.bounds.size.width, 50.0f)];
    //[newuserFeedbackLabel setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7]];
    //[newuserFeedbackLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [newuserFeedbackLabel setFont:[UIFont fontWithName:[CMCustomTheme getFontNameForBold:NO] size:22.0]];
    [newuserFeedbackLabel setBackgroundColor:[UIColor clearColor]];
    [newuserFeedbackLabel setTextColor:[UIColor whiteColor]];
    
    
    //AVCaptureFocusMode initialFocusMode = [[[[self captureManager] videoInput] device] focusMode];
    [newuserFeedbackLabel setText:[NSString stringWithFormat:@""]];
    [view addSubview:newuserFeedbackLabel];
    [self setUserFeedbackLabel:newuserFeedbackLabel];
    newuserFeedbackLabel  = nil;
    
    self.userFeedbackLabel.textAlignment = NSTextAlignmentCenter;
}



/*
 
 Update button states based on the number of available cameras and mics
 
 */
- (void)updateButtonStates
{
	NSUInteger cameraCount = [[self captureManager] cameraCount];
	
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        
        if (cameraCount < 1) {
            [[self stillButton] setEnabled:NO];
        }
        else {
            [[self stillButton] setEnabled:YES];
        }
        
    });
}


/*
 
 Find where the video box is positioned within the preview layer based on the video size and gravity
 
 */

+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
	
	CGRect videoBox;
	videoBox.size = size;
	if (size.width < frameSize.width)
		videoBox.origin.x = (frameSize.width - size.width) / 2;
	else
		videoBox.origin.x = (size.width - frameSize.width) / 2;
	
	if ( size.height < frameSize.height )
		videoBox.origin.y = (frameSize.height - size.height) / 2;
	else
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    
	return videoBox;
}


/*
 
 Called asynchronously as the capture output is capturing sample buffers, this method asks
 the face detector (if on) to detect features and for each draw the red square in a layer
 and set appropriate orientation
 
 */

- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{
	NSArray *sublayers = [NSArray arrayWithArray:[[self captureVideoPreviewLayer] sublayers]];
	NSInteger sublayersCount = [sublayers count], currentSublayer = 0;
	NSInteger featuresCount = [features count], currentFeature = 0;
    
    // mCameraWBUpdateStatus >= 9: camera settings cannot be controlled after 3 attempts, capture impossible
    if (mCameraWBUpdateStatus > 9)
    {
        [self.userFeedbackLabel setText:[NSString stringWithFormat:@"Camera settings problem."]];
        return;
    }
    
    else if (mCameraWBUpdateStatus == 9)
    {
        
        NSString *msg = [NSString stringWithFormat:@"There was a problem with camera settings. Photo capture cannot proceed. Please try later. If the problem persists, contact ColorModules support."];
        
        CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Color capture Failure"
                                                                message:msg
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                      otherButtonTitles:nil];
            [alertView show];
            alertView = nil;
        });
        
        mCameraWBUpdateStatus = 10;
        
        
        return;
        
    }
    
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    
    
	
	// hide all the face layers
	for ( CALayer *layer in sublayers ) {
		if ( [[layer name] isEqualToString:@"FaceLayer"] )
			[layer setHidden:YES];
	}
	
	if ( featuresCount == 0 || !mIfToDetectFaces ) {
        // update the user interface
        if(!mIfToDetectFaces) {
            [self.userFeedbackLabel setText:[NSString stringWithFormat:@"Only portrait please!"]];
            
            [[self faceGuide ] setHidden:YES];
            
        }
        else {
            [self.userFeedbackLabel setText:[NSString stringWithFormat:@"Can't see your face!"]];
            mFaceDetected = NO; // will need this elsewhere
            
        }
        
        // debug: turn off to allow capture even when face is not detected
        [[self stillButton] setEnabled:NO];
        [[self stillButton] setHighlighted:NO];
        [self.mExposureMarkerLayer setHidden: YES];
        [self.userFeedbackLabel setBackgroundColor:[UIColor redColor]];
        
		[CATransaction commit];
		return; // early bail.
	}
    
    [[self faceGuide ] setHidden:NO];
    
    mFaceDetected = YES; // will need this elsewhere
    
    
	CGSize parentFrameSize = [self.videoPreviewView frame].size;
	NSString *gravity = [self.captureVideoPreviewLayer videoGravity];
	BOOL isMirrored = [self.captureVideoPreviewLayer.connection isVideoMirrored];//[self.captureVideoPreviewLayer isMirrored];
	CGRect previewBox = [CMCameraCaptureViewController videoPreviewBoxForGravity:gravity
                                                                       frameSize:parentFrameSize
                                                                    apertureSize:clap.size];
    
    
    CGRect faceRectBuffer;
    
    
	
	for ( CIFaceFeature *ff in features ) {
		// find the correct position for the square layer within the captureVideoPreviewLayer
		// the feature box originates in the bottom left of the video frame.
		// (Bottom right if mirroring is turned on)
		CGRect faceRect = [ff bounds];
        
        
        
		// flip preview width and height
		CGFloat temp = faceRect.size.width;
		faceRect.size.width = faceRect.size.height;
		faceRect.size.height = temp;
		temp = faceRect.origin.x;
		faceRect.origin.x = faceRect.origin.y;
		faceRect.origin.y = temp;
		// scale coordinates so they fit in the preview box, which may be scaled
		CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
		CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
		faceRect.size.width *= widthScaleBy;
		faceRect.size.height *= heightScaleBy;
		faceRect.origin.x *= widthScaleBy;
		faceRect.origin.y *= heightScaleBy;
        
        //NSLog(@"original faceRect: %f %f %f %f, Mirrord=%d", faceRect.origin.x, faceRect.origin.y, faceRect.size.width, faceRect.size.height, captureVideoPreviewLayer.contentsAreFlipped);
        
        //NSLog(@"preview box: %f %f %f %f", previewBox.origin.x, previewBox.origin.y, previewBox.size.width, previewBox.size.height);
        
        
		if ( isMirrored )
			faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
		else
			faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
		
        
        // added on 05/12/12: red rectangle is off - resize and reposition for drawing
        faceRect.size.width *= 0.8;
        faceRect.origin.x *= 0.8;
        
        
		CALayer *featureLayer = nil;
		
		// re-use an existing layer if possible
		while ( !featureLayer && (currentSublayer < sublayersCount) ) {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ( [[currentLayer name] isEqualToString:@"FaceLayer"] ) {
				featureLayer = currentLayer;
				[currentLayer setHidden:NO];
			}
		}
		
		// create a new one if necessary
		if ( !featureLayer ) {
			featureLayer = [CALayer new];
			[featureLayer setContents:(id)[self.square CGImage]];
			[featureLayer setName:@"FaceLayer"];
			[self.captureVideoPreviewLayer addSublayer:featureLayer];
			featureLayer = nil;
		}
		[featureLayer setFrame:faceRect];
        
        
        
        
        
        
        // added on 05/12/12: get back the original size and position of facerect
        faceRect.size.width *= 1/0.8;
        faceRect.origin.x *= 1/0.8;
        
        
        faceRectBuffer = faceRect;
        
        
        
        // mouth: 478, 247
        // left eye: 298, 157
        // right eye: 290, 319
        // previewBox size: 320, 426.7
        
        self.mFacialFeatures = ff;
        
        mFaceRect = faceRect;
        
        // needed for exposure control routine
        mPreviewBox = previewBox;
        
        // will be needed to show exposure marker
        mWidthScaleFactor = widthScaleBy;
        mHeightScaleFactor = heightScaleBy;
        
        
        
		switch (orientation) {
			case UIDeviceOrientationPortrait:
                [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(0.))];
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(180.))];
				break;
			case UIDeviceOrientationLandscapeLeft:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(90.))];
				break;
			case UIDeviceOrientationLandscapeRight:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-90.))];
				break;
			case UIDeviceOrientationFaceUp:
			case UIDeviceOrientationFaceDown:
			default:
				break; // leave the layer in its last known orientation
                
		}
		currentFeature++;
	}
    
	[CATransaction commit];
    
    
    // -------- come up with a feedback based on face location --------
    float percentDevWidth = 0, percentDevHeight = 0;
    float percentDevY = 0; // percentDevX = 0;
    
    NSString *feedback = nil;
    
    
    
    // following comes from typical faceRect values: 80, 130, 254, 253
    // change in case face guide is updated
    //float xRef = previewBox.size.width * 0.213;
    float yRef = previewBox.size.height * 0.283;
    float widthRef = previewBox.size.width * 0.676;
    float heightRef = previewBox.size.height * 0.55;
    
    
    percentDevWidth = (faceRectBuffer.size.width - widthRef)/ widthRef * 100.0;
    percentDevHeight = (faceRectBuffer.size.height - heightRef)/ heightRef * 100.0;
    //percentDevX = abs(faceRectBuffer.origin.x - xRef)/ xRef * 100.0;
    percentDevY = abs(faceRectBuffer.origin.y - yRef)/ yRef * 100.0;
    
    
    
    /* ------------ To check mCameraWBUpdateStatus and initiate white balance update ---------------
     0: not started,
     1: being updated,
     2: done,
     3-6: not started due to error. Retry,
     7: give up
     */
    if (mCameraWBUpdateStatus == 0 || mCameraWBUpdateStatus == 3 || mCameraWBUpdateStatus == 6)
    {
        if((abs(percentDevWidth) > 35.0 && percentDevWidth < 0) ||
           (abs(percentDevHeight) > 35.0 && percentDevHeight < 0))
        {
            // ----------------- camera at arm's length -------------
            
            [self.userFeedbackLabel setText:[NSString stringWithFormat:@"Camera getting ready."]];
            [self.userFeedbackLabel setBackgroundColor:[UIColor orangeColor]];

            
            if (![[self captureManager] updateDeviceWhiteBalanceSettings:(1)])
            {
                // settings could not be updated
                [self.userFeedbackLabel setText:[NSString stringWithFormat:@"Problem. Retrying..."]];
                [self.userFeedbackLabel setBackgroundColor:[UIColor redColor]];
                mCameraWBUpdateStatus = mCameraWBUpdateStatus + 3;
            }
            else
            {
                // settings successfully updated
                mCameraWBUpdateStatus = 1;
            }
            
        }
        else {
            [self.userFeedbackLabel setText:[NSString stringWithFormat:@"Hold device at arm's length"]];
            [self.userFeedbackLabel setBackgroundColor:[UIColor orangeColor]];

        }
        
        return;
        
    }
    if (mCameraWBUpdateStatus == 1)
    {
        if (![[self captureManager] updateDeviceWhiteBalanceSettings:(2)])
        {
            // Settings could not be updated
            mCameraWBUpdateStatus = 0;
            
        }
        else
        {
            // WB settings successfully updated
            [self.userFeedbackLabel setText:[NSString stringWithFormat:@"Camera is ready."]];
            mCameraWBUpdateStatus = 2;
        }
        return;
        
        
    }
    
    
    
    // ----------******************* exposure control code *********************---------------
    
    // when the face comes for the first time into a specific zone, mExposureNeedsImmediateUpdate
    // is set to true, so that the exposure gets set to the brightest point in captureOutput.
    // As long as the face remains in this zone, the exposure stays the same.
    // When face moves away from this zone and then reenters, mExposureNeedsImmediateUpdate is again
    // set to true
    
    // when mCameraExposureUpdateStatus = 1, exposure is currently being updated - leave
    if (mCameraExposureUpdateStatus == 1)
    {
        return;
    }
    
    
    // ---------- decide whether or not the exposure needs to be updated ----------
    if(!mExposureNeedsImmediateUpdate)
    {
        if(abs(percentDevWidth) < 10.0 && abs(percentDevHeight) < 10.0
           && percentDevWidth < 0 && percentDevHeight < 0 && abs(percentDevY) < 30.0)
        {
            // ---------- face in the zone --------------
            
            if (mCameraExposureUpdateStatus == 0)
            {
                // exposure needs update - feedback MUST be shown on the main thread in captureImage
                // causing issues - not getting re-enabled?
                dispatch_async( dispatch_get_main_queue(), ^(void)
                               {
                                   [[self stillButton] setEnabled:NO];
                               });
                
                mExposureNeedsImmediateUpdate = true;
                
                //NSLog(@"Face entered zone <<<<<<");
                
                
            }
            else if (mCameraExposureUpdateStatus == 3)
            {
                // if mCameraExposureUpdateStatus = 3, exposure has been updated in the
                // past, and face still in the zone - keep exposure same and show marker
                mExposureNeedsImmediateUpdate = false;
            }
            
            
        }
        else if((abs(percentDevWidth) > 20.0 && abs(percentDevHeight) > 20.0) || abs(percentDevY) > 50.0)
            //&& percentDevWidth < 0 && percentDevHeight < 0)
        {
            // ---------- face not in the zone --------------
            
            if (mCameraExposureUpdateStatus == 3)
            {
                // exposure has been updated in the past - now face is going out of the zone
                // but don't update yet by setting mExposureNeedsImmediateUpdate - wait till
                // face goes back to the zone
                mCameraExposureUpdateStatus = 0;
                
                mExposureNeedsImmediateUpdate = false;
                
                //NSLog(@"Face left zone <<<<<<");
                
            }
            else
            {
                mExposureNeedsImmediateUpdate = false;
            }
            
        }
        else if (abs(percentDevY) > 60.0)
        {
            // face not at the center
            // exposure will need to be updated
            
            mExposureNeedsImmediateUpdate = false;
            mCameraExposureUpdateStatus = 0;
            
        }
        
        
        
    }
    
    // ---------- check whether or not to show the exposure marker ----------
    if (mCameraExposureUpdateStatus == 2)
    {
        // if mCameraExposureUpdateStatus = 2, exposure just got updated
        // exposure set, marker shown - update feedback and return
        //feedback = [NSString stringWithFormat:@"Exposure updated."];
        //[userFeedbackLabel setText: feedback];
        dispatch_async( dispatch_get_main_queue(), ^(void)
                       {
                           [[self stillButton] setEnabled:YES];
                       });
        
        
        mExposureNeedsImmediateUpdate = false;
        
        mCameraExposureUpdateStatus = 3;
        
        // do not show any other feedback
        return;
        
    }
    else if (mCameraExposureUpdateStatus == 3)
    {
        
        dispatch_async( dispatch_get_main_queue(), ^(void)
                       {
                           [self.mExposureMarkerLayer setHidden: YES];
                           
                       });
        
    }
    
    // moved here on 06/07/12 after changing button art
    [[self stillButton] setEnabled:YES];
    
    
    
    // -------------- update general feedback based on face position --------------
    if (abs(percentDevY) > 60.0)
    {
        feedback = [NSString stringWithFormat:@"Face not at the center!"];
        [[self stillButton] setHighlighted:NO];
        [self.userFeedbackLabel setBackgroundColor:[UIColor redColor]];
        
    }
    else if((abs(percentDevWidth) > 12.0 && percentDevWidth < 0) ||
            (abs(percentDevHeight) > 12.0 && percentDevHeight < 0))
    {
        feedback = [NSString stringWithFormat:@"We see you, come closer!"];
        [[self stillButton] setHighlighted:NO];
        [self.userFeedbackLabel setBackgroundColor:[UIColor orangeColor]];

    }
    else if ((abs(percentDevWidth) > 7.0 && percentDevWidth > 0) ||
             (abs(percentDevHeight) > 7.0 && percentDevHeight > 0))
    {
        feedback = [NSString stringWithFormat:@"Too close!"];
        [[self stillButton] setHighlighted:NO];
        [self.userFeedbackLabel setBackgroundColor:[UIColor redColor]];

    }
    else
    {
        feedback = [NSString stringWithFormat:@"Got you, take photo!"];
        [[self stillButton] setHighlighted:YES];
        [self.userFeedbackLabel setBackgroundColor:[UIColor greenColor]];

    }
    
    
    // update the user interface
    [self.userFeedbackLabel setText: feedback];
    
    
    
    
}



- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if(mIfToDetectFaces == NO || mViewIsReadyForFaceDetection == NO)
        return;
    
    
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
	NSDictionary *imageOptions = nil;
    
    
    
    
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	int exifOrientation;
    
    
    
    BOOL isUsingFrontFacingCamera = [[self captureManager] isUsingFrontFacingCamera];
    
    
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
	
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
            
            // DEBUG: following line added on 3/15/12: to stop change in orientation
            //exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            //break;
            
		default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            
			break;
	}
    
    
    
	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
	NSArray *features = [self.faceDetector featuresInImage:ciImage options:imageOptions];
    
    
	ciImage = nil;
	
    
    
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false); //originIsTopLeft == false
	
    
	dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
                       
                   });
    
    
    // ------ here check mCameraExposureUpdateStatus and initiate exposure update ----------
    // IMPORTANT: mExposureNeedsImmediateUpdate is set in drawFaceBoxesForFeatures - DO NOT SET HERE
    
    
    if (mExposureNeedsImmediateUpdate && mCameraExposureUpdateStatus != 1)
    {
        
        dispatch_sync(dispatch_get_main_queue(), ^(void)
                      {
                          mCameraExposureUpdateStatus = 1;
                          NSString *feedback = [NSString stringWithFormat:@"Updating exposure, wait..."];
                          
                          // update the user interface
                          [self.userFeedbackLabel setText: feedback];
                          [self.stillButton setEnabled:NO];
                          
                      });
        
        BOOL ret = NO;
        
        
        // FOR TEST - COMMENT WHEN DONE: added 07/01/12
        //ret = YES;
        //mExposurePointInDeviceCoords = CGPointMake(0.5f, 0.5f);
        
        
        //CVPixelBufferRef pixelBufferForExposureControl = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        
        // this point is defined in image coord system
        // e.g. for facial features the coords are flipped
        
        CGPoint expPointInViewLayer = CGPointMake(160.0f, 240.0f);
        CGPoint expPointInDeviceCoords = CGPointMake(0.5f, 0.5f);
        
        // tested various options on 0/05/12 to prevent leak in CreateCGImageFromCVPixelBuffer:
        // ANY ATTEMPT TO RELEASE pixelBuffer CAUSES CRASH
        
        /*
         CGImageRef imageRef = NULL;
         
         OSStatus err = CreateCGImageFromCVPixelBuffer(CMSampleBufferGetImageBuffer(sampleBuffer), &imageRef);
         
         
         if(err)
         {
         
         LogError(@"Exposure update failed, buffer could not be obtained <<<<<<");
         return;
         
         }
         */
        
        ret = [[self captureManager] getExposurePointOfInterest: CMSampleBufferGetImageBuffer(sampleBuffer)  AreaOfInterest: mFaceRect PreviewBox: mPreviewBox WidthScaleFactor: mWidthScaleFactor HeightScaleFactor: mHeightScaleFactor IsImageMirrored: NO ExposurePointInViewLayer:  &expPointInViewLayer ExposurePointInDeviceCoords: &expPointInDeviceCoords];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^(void)
                      {
                          if (!ret)
                          {
                              mCameraExposureUpdateStatus = 0;
                              [self.stillButton setEnabled:YES];
                              
                              return;
                          }
                      });
        
        
        mExposurePointInViewLayer = expPointInViewLayer;
        mExposurePointInDeviceCoords = expPointInDeviceCoords;
        
        //mExposurePointInDeviceCoords = CGPointMake(mExposurePointInViewLayer.x/mPreviewBox.size.width, mExposurePointInViewLayer.y/mPreviewBox.size.height);
        
        //NSLog(@"ExposurePointInDeviceCoords: (%4.3f, %4.3f) <<<<<<", mExposurePointInDeviceCoords.x, mExposurePointInDeviceCoords.y);
        
        
        ret = [[self captureManager] updateDeviceExposureSetting:mExposurePointInDeviceCoords];
        
        if (!ret)
        {
            dispatch_sync(dispatch_get_main_queue(), ^(void)
                          {
                              mCameraExposureUpdateStatus = 0;
                              [self.stillButton setEnabled:YES];
                              
                          });
            
            LogError(@"Device exposure update failed.");
            
            return;
            
        }
        
        
        // ---------- show the exposure marker ----------
        
        dispatch_sync(dispatch_get_main_queue(), ^(void)
                      {
                          
                          [CATransaction begin];
                          [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                          
                          if ([self.captureVideoPreviewLayer containsPoint:mExposurePointInViewLayer]) {
                              [self.mExposureMarkerLayer setPosition:mExposurePointInViewLayer];
                          }
                          
                          [self.mExposureMarkerLayer setHidden: NO];
                          
                          [CATransaction commit];
                          
                          mCameraExposureUpdateStatus = 2;
                          
                          [self.stillButton setEnabled:YES];
                          
                      });
        
        
        
        
        /*
         mExposurePointInViewLayer = CGPointMake(mFacialFeatures.mouthPosition.x, mFacialFeatures.mouthPosition.y);
         
         
         
         // flip x and y and scale
         CGRect areaAroundExposurePoint = CGRectMake(mExposurePointInViewLayer.y * mWidthScaleFactor, mExposurePointInViewLayer.x * mHeightScaleFactor, 0, 0);
         
         
         if ([[self captureVideoPreviewLayer] isMirrored])
         areaAroundExposurePoint = CGRectOffset(areaAroundExposurePoint, mPreviewBox.origin.x + mPreviewBox.size.width - areaAroundExposurePoint.size.width - (areaAroundExposurePoint.origin.x * 2), mPreviewBox.origin.y);
         else {
         areaAroundExposurePoint = CGRectOffset(areaAroundExposurePoint, mPreviewBox.origin.x, mPreviewBox.origin.y);
         }
         
         // X-AXIS NEEDS ADDITIONAL SCALING of 0.8, SINCE CHANGE IN IMAGE SIZE TO (320 X 460) WAS MADE
         // NOT SURE WHY
         areaAroundExposurePoint.origin.x *= 0.8;
         
         mExposurePointInViewLayer = CGPointMake(areaAroundExposurePoint.origin.x, areaAroundExposurePoint.origin.y);
         */
        
        
        
    }
    
    
}


/*
 
 Perform a flash bulb animation using KVO to monitor the value of the
 capturingStillImage property of the AVCaptureStillImageOutput class
 
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    
	if ( context == (__bridge void *)AVCaptureStillImageIsCapturingStillImageContext )
    {
		BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
		
		if ( isCapturingStillImage ) {
            
            /*
             // do flash bulb like animation
             flashView = [[UIView alloc] initWithFrame:[[self view] frame]];
             [flashView setBackgroundColor:[UIColor whiteColor]];
             [flashView setAlpha:0.0f];
             [[[self view] window] addSubview:flashView];
             
             
             [UIView animateWithDuration:0.4f
             animations:^{
             [flashView setAlpha:1.f];
             }
			 ];
             */
            
		}
		else {
			[UIView animateWithDuration:0.2f
							 animations:^{
								 [self.flashView setAlpha:0.f];
							 }
							 completion:^(BOOL finished){
                                 
                                 // photo has been captured - get out of this view and
                                 // show upload view
                                 // terminate AV capture before leaving
                                 [self teardownAVCapture];
                                 [self tearDownVideoInterface];
                                 
                                 
                                 
                                 // give back control to the source view controller which is
                                 // the delegate of current view controller
                                 [[self delegate] captureViewControllerDidFinish:self];
                                 
                                 
							 }
			 ];
            
            //still image has been captured
            
            
		}
	}
    
    
    
    /* // keep this for future reference
     
     else if (context == CMCamFocusModeObserverContext) {
     // Update the focus UI overlay string when the focus mode changes
     [userFeedbackLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForUserFeedback:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
     } */
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    
}



/*
 
 Utility routing used during image capture to set up capture orientation
 
 */
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // only protrait orientation will be allowed for capture
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
        mIfToDetectFaces = YES;
    else
        mIfToDetectFaces = NO;
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)cancelButtonPressed:(id)sender
{
    [self teardownAVCapture];
    [self tearDownVideoInterface];
    self.mImgFileURL = nil;
    [self.cancelButton setEnabled:NO];
    
    // give back control to the source view controller which is
    // the delegate of current view controller
    [self.navigationController popViewControllerAnimated:NO];
}


/*
 
 Utility routine to display error aleart if takePicture fails
 
 */
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
		alertView = nil;
	});
}



/*
 
 Capture a still image
 
 */

- (IBAction)captureStillImage:(id)sender
{
    NSLog(@"captureStillImage Pressed.");
    
    // stillButton is enabled again in captureManagerStillImageCaptured
    [self.stillButton setEnabled:NO];
    [self.stillButton setHidden:YES];
    [self.userFeedbackLabel setHidden:YES];
    
    // do animation
    self.flashView = [[UIView alloc] initWithFrame:[[self view] frame]];
    [self.flashView setBackgroundColor:[UIColor whiteColor]];
    [self.flashView setAlpha:0.0f];
    [[[self view] window] addSubview:self.flashView];
    
    
    CGRect bounds = [[self view] bounds];
    CGRect labelFrame = CGRectMake(bounds.origin.x, bounds.origin.y+50, bounds.size.width, 50);
    
    
    self.lblCam = [[UILabel alloc] initWithFrame:labelFrame];
    [self.lblCam setFont:[UIFont
                          fontWithName:[CMCustomTheme getFontNameForBold:NO]
                          size:28.0]];
    self.lblCam.textColor = [UIColor redColor];
    self.lblCam.textAlignment = NSTextAlignmentCenter;
    self.lblCam.backgroundColor = [UIColor whiteColor];
    self.lblCam.text = @"Look at camera...";
    [self.lblCam setAlpha:1.0f];
    
    [self.flashView addSubview:self.lblCam];
    
    
    [UIView animateWithDuration:0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionOverrideInheritedDuration
                     animations:^{
                         
                         [self.flashView setAlpha:1.0f];
                         
                     }
                     completion:^(BOOL finished){
                         
                         [[self videoPreviewView] setHidden:YES];
                         
                         self.mImgFileURL = nil;
                         
                         self.mImgFileURL = [[self captureManager]
                                             captureImage: videoDataOutputQueue
                                             HavingFaceRect: mFaceRect];
                     }];
    
}


/*
 
 Methods to tear down the view...
 
 */

-(void) teardownAVCapture
{
    // NOTE: views and layers are removed in tearDownVideoInterface
    // stop detecting faces
    mIfToDetectFaces = NO;
    mViewIsReadyForFaceDetection = NO;
    
    mExposurePointInViewLayer = CGPointZero;
    mCameraExposureUpdateStatus = 0;
    mCameraWBUpdateStatus = 0;
    
    mExposureNeedsImmediateUpdate = false;
    
    [self.captureManager.stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage"];
    [self.captureManager closeSession];
    
    NSLog(@"teardownAVCapture complete.");
}

-(void) tearDownVideoInterface
{
    [self.lblCam removeFromSuperview];
    [self.userFeedbackLabel removeFromSuperview];
    
    [self.videoPreviewView removeFromSuperview];
    [self.faceGuide removeFromSuperview];
    [self.flashView removeFromSuperview];
    [self.showActivityIndicator removeFromSuperview];
    
    [self.captureVideoPreviewLayer removeFromSuperlayer];
    [self.mExposureMarkerLayer removeFromSuperlayer];

    NSLog(@"tearDownVideoInterface complete.");
}

-(void) dealloc
{
    // do not get rid of mImgFileURL - needed later
    self.captureManager = nil;
    self.videoPreviewView = nil;
    self.faceGuide = nil;
	self.flashView = nil;
    self.showActivityIndicator = nil;
    self.captureVideoPreviewLayer = nil;
    self.mExposureMarkerLayer = nil;
    self.faceDetector = nil;
    self.mFacialFeatures = nil;
    self.cancelButton = nil;
    self.stillButton = nil;
	self.userFeedbackLabel = nil;
    self.lblCam = nil;
    self.square = nil;
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


@end




@implementation CMCameraCaptureViewController (CMCamCaptureManagerDelegate)

- (void)captureManager:(CMCamCaptureManager *)captureManager didFailWithError:(NSError *)error
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

- (void)captureManagerStillImageCaptured:(CMCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void)
                          {
                              [[self stillButton] setEnabled:YES];
                              [[self userFeedbackLabel] setHidden: NO];
                              [[self userFeedbackLabel] setTextColor: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
                              NSLog(@"CAPTURED");
                              
                              
                              if(self.mImgFileURL != nil)
                              {
                                  CMPreColorProcessing *preColorProcessing = [[CMPreColorProcessing alloc]
                                                                              initWithCaptureSessionPreset: self.mCaptureSessionPreset
                                                                              WithImageURL:self.mImgFileURL
                                                                              WithFacialFeatures:self.mFacialFeatures
                                                                              WithController:self];
                                  
                                  [preColorProcessing extractColorsForPhotoCapturedFromCamera];
                              }
                          });
}

- (void)captureManagerDeviceConfigurationChanged:(CMCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}

@end