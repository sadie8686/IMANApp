//
//  CMGlobal.h
//  ColorModulesBeautyApp
//
//  Created by Po Hsun Lai on 4/25/13.
//
//

#import <Foundation/Foundation.h>

@interface CMNetworkAvailability : NSObject

+ (CMNetworkAvailability*) sharedGlobal;
- (BOOL) checkInternetConnection;
- (BOOL) checkServerAvailability;
@end
