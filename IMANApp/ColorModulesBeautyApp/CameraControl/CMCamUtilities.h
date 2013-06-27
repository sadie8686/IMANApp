/*--------------------------------------------------------------------------
 CMCamUtilities.h
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar 
 
 Created by Abhijit Sarkar on 2012/02/04
 
 Description: 
 Header for a utility class containing a method to find an AVCaptureConnection of 
 a particular media type from an array of AVCaptureConnections.

 
 
 Revision history:
 2012/02/05 - by AS
 
 Existing Problems:
 (date) - 
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/



#import <Foundation/Foundation.h>

@class AVCaptureConnection;

@interface CMCamUtilities : NSObject {
    
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

@end
