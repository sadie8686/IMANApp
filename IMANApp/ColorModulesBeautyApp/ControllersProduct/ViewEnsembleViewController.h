//
//  ViewEnsembleViewController.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 3/27/13.
//
//

#import <UIKit/UIKit.h>

@interface ViewEnsembleViewController : UIViewController


- (void) setEyeProductList:(NSArray *) eyeProductsArray
WithCurrentEyeProductPosition: (int) currentEyePosition
        setLipsProductList: (NSArray *) lipsProductsArray
WithCurrentLipsProductPosition: (int) currentLipsPosition
       setBlushProductList:(NSArray *) blushProductsArray
WithCurrentBlushProductPoistion: (int) currentBlushPosition
        setFaceProductList:(NSArray *) faceProductsArray
WithCurrenFaceProductPosition: (int) currentFacePosition;

@end
