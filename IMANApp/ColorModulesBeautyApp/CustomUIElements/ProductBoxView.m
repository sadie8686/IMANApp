//
//  ProductBoxView.m
//  ColorModulesBeautyApp
//
//  Created by Po Hsun Lai on 4/23/13.
//
//

#import "ProductBoxView.h"
#import "CMApplicationModel.h"
#import "UIImageView+AFNetworking.h"

@implementation ProductBoxView
@synthesize pBtn,shareBtn,wishListBtn;
@synthesize productBoxButton;
@synthesize pView;
@synthesize controlBoxImageView;

- (id) initWithProduct:(CMProductMap *) product
              withPosx:(float) x
              withPosy:(float) y
             withWidth:(float) width
            withHeight:(float) height
    withViewController:(UIViewController *)superViewComtroller
{
    self = [super initWithFrame:CGRectMake(x, y, width, height)];
    
    if (self) {
        
        // Setting global variables...
        superVC = superViewComtroller;
        productBoxproduct = product;
        
        // Customizing the self view...
        [self setBackgroundColor:[UIColor whiteColor]];
        
        // adding product image...
        UIImageView *productImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, width-10, height)];
        [productImageView setImageWithURL:product.imageURL];
        [productImageView setUserInteractionEnabled:YES];
        [productImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:productImageView];
        
        // adding color swatch...
        UIView *colorSwatchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.frame.size.height)];
        colorSwatchView.backgroundColor = product.color;
        [self addSubview:colorSwatchView];
        
        // add product box button
        productBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [productBoxButton setFrame:CGRectMake(0, 0, width, height)];
        [self addSubview:productBoxButton];
        
        // adding p button
        pBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [pBtn setFrame:CGRectMake(width-30, 0, 30, 50)];
        [pBtn setImage:[UIImage imageNamed:@"p_icon.png"] forState:UIControlStateNormal];
        [pBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 25, 0)];
        [pBtn addTarget:self action:@selector(pViewButtonPressed) forControlEvents:UIControlEventAllEvents];
        
        if (product.matchMessage) {
            [self addSubview:pBtn];
        }
        
        // set control box image view
        controlBoxImageView = [[UIImageView alloc]initWithFrame:CGRectMake(width-70, height-20, 60, 30)];
        [controlBoxImageView setImage:[UIImage imageNamed:@"large_blank_fav_share.png"]];
        [controlBoxImageView setUserInteractionEnabled:YES];
        
        // set share button
        shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareBtn setFrame:CGRectMake(30, 0, 30, 30)];
        [shareBtn setImage:[UIImage imageNamed:@"ShareIcon.png"] forState:UIControlStateNormal];
        [shareBtn setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [shareBtn addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [controlBoxImageView addSubview:shareBtn];
        
        // set wishlist button
        wishListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [wishListBtn setFrame:CGRectMake(0, 0, 30, 30)];
        [wishListBtn addTarget:self action:@selector(wishlistButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self adjustWishlistButton];
        [wishListBtn setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [controlBoxImageView addSubview:wishListBtn];
        [self addSubview:controlBoxImageView];
        
        // pView
        
        //NSString *deviceType = [UIDevice currentDevice].model;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        if (screenBounds.size.width > 320)
        {
            self.pView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, superViewComtroller.view.frame.size.width, superViewComtroller.view.frame.size.height)];
            [self.pView setBackgroundColor:[UIColor clearColor]];
            
            
            UIView *pBoxView = [[UIView alloc]initWithFrame:CGRectMake(0, 200, screenBounds.size.width, 400)];
            [pBoxView setBackgroundColor:[UIColor whiteColor]];
            [self.pView addSubview:pBoxView];
            
            UIImageView *pImageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 13, 15, 25)];
            [pImageView setImage:[UIImage imageNamed:@"p_icon.png"]];
            [pBoxView addSubview:pImageView];
            
            UILabel *recommandLabel= [[UILabel alloc]initWithFrame:CGRectMake(48, 19, 236, 21)];
            [recommandLabel setText:@"RECOMMENDED BECAUSE:"];
            [recommandLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
            [pBoxView addSubview:recommandLabel];
            
            UIButton *closebutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [closebutton setFrame:CGRectMake(screenBounds.size.width-38, 15, 25, 25)];
            [closebutton setImage:[UIImage imageNamed:@"Cross_Button.png"] forState:UIControlStateNormal];
            [closebutton addTarget:self action:@selector(pViewCloseButtonPressed) forControlEvents:UIControlEventAllEvents];
            [pBoxView addSubview:closebutton];
            
            UIImageView *pProductImageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 55, 250, 250)];
            [pProductImageView setImageWithURL:product.imageURL];
            [pProductImageView setContentMode:UIViewContentModeScaleAspectFit];
            [pBoxView addSubview:pProductImageView];
            
            UILabel *whyThisProductLabel = [[UILabel alloc]initWithFrame:CGRectMake(300, 30, 400, 300)];
            [whyThisProductLabel setText:product.matchMessage];
            [whyThisProductLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
            [whyThisProductLabel setNumberOfLines:0];
            [pBoxView addSubview:whyThisProductLabel];
            
            UIView *upLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenBounds.size.width, 2)];
            [upLineView setBackgroundColor:[UIColor blackColor]];
            [pBoxView addSubview:upLineView];
            
            UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, pBoxView.frame.size.height-2, screenBounds.size.width, 2)];
            [bottomLineView setBackgroundColor:[UIColor blackColor]];
            [pBoxView addSubview:bottomLineView];
            
            [self.pView setHidden:YES];
            
            [superViewComtroller.view addSubview:self.pView];
        }
        else
        {
            self.pView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, superViewComtroller.view.frame.size.width, superViewComtroller.view.frame.size.height)]; 
            [self.pView setBackgroundColor:[UIColor clearColor]];
            

            UIView *pBoxView = [[UIView alloc]initWithFrame:CGRectMake(0, 125, 320, 210)];
            [pBoxView setBackgroundColor:[UIColor whiteColor]];
            [self.pView addSubview:pBoxView];
            
            UIImageView *pImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 15, 25)];
            [pImageView setImage:[UIImage imageNamed:@"p_icon.png"]];
            [pBoxView addSubview:pImageView];
            
            UILabel *recommandLabel= [[UILabel alloc]initWithFrame:CGRectMake(27, 7, 236, 21)];
            [recommandLabel setText:@"RECOMMENDED BECAUSE:"];
            [recommandLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
            [pBoxView addSubview:recommandLabel];
            
            UIButton *closebutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [closebutton setFrame:CGRectMake(295, 5, 20, 20)];
            [closebutton setImage:[UIImage imageNamed:@"Cross_Button.png"] forState:UIControlStateNormal];
            [closebutton addTarget:self action:@selector(pViewCloseButtonPressed) forControlEvents:UIControlEventAllEvents];
            [pBoxView addSubview:closebutton];
            
            UIImageView *pProductImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 51, 116, 116)];
            [pProductImageView setImageWithURL:product.imageURL];
            [pProductImageView setContentMode:UIViewContentModeScaleAspectFit];
            [pBoxView addSubview:pProductImageView];
            
            UILabel *whyThisProductLabel = [[UILabel alloc]initWithFrame:CGRectMake(131, 33, 184, 149)];
            [whyThisProductLabel setText:product.matchMessage];
            [whyThisProductLabel setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:15.0]];
            [whyThisProductLabel setNumberOfLines:0];
            [pBoxView addSubview:whyThisProductLabel];
            
            UIView *upLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 2)];
            [upLineView setBackgroundColor:[UIColor blackColor]];
            [pBoxView addSubview:upLineView];
            
            UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 208, 320, 2)];
            [bottomLineView setBackgroundColor:[UIColor blackColor]];
            [pBoxView addSubview:bottomLineView];
            
            [self.pView setHidden:YES];
            
            [superViewComtroller.view addSubview:self.pView];
                
        }
        
    }
    
    
    return self;
    
}

- (void)wishlistButtonPressed
{
    
    // if the product is not saved yet, then save the product.
    if([CMApplicationModel isWishlistItem:productBoxproduct])
    {
        // To remove the product from wishlist locally...
        [SVProgressHUD showSuccessWithStatus:REMOVE_FROM_WISHLIST];
        [CMApplicationModel removeProductFromWishlist:productBoxproduct];
        [self adjustWishlistButton];
    }
    else
    {
        // To save the product locally first...
        [SVProgressHUD showSuccessWithStatus:ADDED_TO_WISHLIST];
        [CMApplicationModel addProductToWishlist:productBoxproduct];
        [self adjustWishlistButton];
    }
    
    [superVC viewWillAppear:YES];
    
}

-(void) adjustWishlistButton
{
    //Check if the item is in saved list. If yes, disable the save button.
    if ([CMApplicationModel isWishlistItem:productBoxproduct])
    {
        [self.wishListBtn setImage:[UIImage imageNamed: @"HeartIcon_Pressed.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.wishListBtn setImage:[UIImage imageNamed: @"HeartIcon.png"] forState:UIControlStateNormal];
    }
}


- (void)shareButtonPressed
{
    [superVC.view addSubview:[[ShareFunctionalityView alloc]
                              initWithProductArray:[NSArray arrayWithObject:productBoxproduct]
                              WithSuperViewController:superVC
                              WithViewPosition:VIEW_LOCATION_BOTTOM]];
}


- (void)pViewCloseButtonPressed
{
    self.pView.hidden=YES;
}

- (IBAction)pViewButtonPressed
{
    self.pView.hidden=NO;
}

@end
