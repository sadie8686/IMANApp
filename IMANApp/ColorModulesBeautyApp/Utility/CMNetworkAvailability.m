//
//  CMGlobal.m
//  ColorModulesBeautyApp
//
//  Created by Po Hsun Lai on 4/25/13.
//
//

#import "CMNetworkAvailability.h"
#import "Reachability.h"
#import "CMConstants.h"

@implementation CMNetworkAvailability

static CMNetworkAvailability* sharedMyGlobal_ = nil;

+(CMNetworkAvailability*)sharedGlobal
{
    @synchronized([CMNetworkAvailability class])
	{
		if (!sharedMyGlobal_) sharedMyGlobal_ = [[self alloc] init];
        
		return sharedMyGlobal_;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([CMNetworkAvailability class])
	{
		NSAssert(sharedMyGlobal_ == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedMyGlobal_ = [super alloc];
		return sharedMyGlobal_;
	}
    
	return nil;
}

-(id)init
{
	if ((self = [super init]))
    {
        // 
	}
    
	return self;
}

- (void)dealloc
{
    sharedMyGlobal_ = nil;
}

// -------------------------------------------------------------------------
// Desc	 : Reachability Impementation. Test for Internet Connection
// Return  : NO = no net connection; Yes = net connection available
// -------------------------------------------------------------------------
- (BOOL) checkInternetConnection
{
	Reachability *r = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL internet;
    
	if (internetStatus == NotReachable) internet = NO;
	else internet = YES;
	
	return internet;
}

- (BOOL) checkServerAvailability
{
    NSString *serverURL = server;
    serverURL = [serverURL stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    Reachability* r = [Reachability reachabilityWithHostname:serverURL];
    NetworkStatus status = [r currentReachabilityStatus];
    
    return status == NotReachable ? NO : YES;
}
@end
