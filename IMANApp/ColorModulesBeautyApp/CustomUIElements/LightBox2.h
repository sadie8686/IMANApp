//
//  LightBox2.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 12/11/12.
//
//

#import <UIKit/UIKit.h>

@interface LightBox2 : UIScrollView <UITextFieldDelegate>

-(id) initWithTitle: (NSString *) title
         forMessage:(NSString *) message;

- (id) initForHelpfulTipsWithTitle: (NSString *) title
                       WithMessage: (NSString *) message;



-(void)closeNoticeDropDown:(id)sender;

@end
