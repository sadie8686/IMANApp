//
//  CMProductLandingViewController.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/5/13.
//
//

#import <UIKit/UIKit.h>

@interface CMProductLandingViewController : UIViewController <UIScrollViewDelegate>
-(void) requestProductsFromServerForProductType: (NSString *) productType;
@end
