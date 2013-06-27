/*--------------------------------------------------------------------------
 CMCamUtilities.m
 
 Part of iPhone App : ColorModulesBeautyApp v1
 Developed by Nicky Liu and Abhijit Sarkar 
 
 Created by Abhijit Sarkar on 2012/02/04
 
 Description: 
 Code for a utility class containing a method to find an AVCaptureConnection of 
 a particular media type from an array of AVCaptureConnections.
 
 
 
 Revision history:
 2012/02/05 - by AS
 
 Existing Problems:
 (date) - 
 
 Copyright (c) 2012 by ColorModules Inc. All rights reserved
 %--------------------------------------------------------------------------*/


#import "CMCamUtilities.h"
#import <AVFoundation/AVFoundation.h>

@implementation CMCamUtilities

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

@end
