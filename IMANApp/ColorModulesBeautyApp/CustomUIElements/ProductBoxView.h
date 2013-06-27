//
//  ProductBoxView.h
//  ColorModulesBeautyApp
//
//  Created by Po Hsun Lai on 4/23/13.
//
//

#import <UIKit/UIKit.h>
#import "CMProductModel.h"
#import "CMProductMap.h"
#import "CMConstants.h"
#import "ShareFunctionalityView.h"
#import "SVProgressHUD.h"

@interface ProductBoxView : UIView
{
    UIViewController *superVC;
    CMProductMap *productBoxproduct;
}

@property(nonatomic, strong) IBOutlet UIButton *pBtn;
@property(nonatomic, strong) IBOutlet UIButton *shareBtn;
@property(nonatomic, strong) IBOutlet UIButton *wishListBtn;
@property(nonatomic, strong) IBOutlet UIView *pView;
@property(nonatomic, strong) IBOutlet UIImageView *controlBoxImageView;
@property(nonatomic, strong) IBOutlet UIButton *productBoxButton;

- (id) initWithProduct:(CMProductMap *) product
              withPosx:(float) x
              withPosy:(float) y
             withWidth:(float) width
            withHeight:(float) height
    withViewController:(UIViewController *)superViewComtroller;


@end
