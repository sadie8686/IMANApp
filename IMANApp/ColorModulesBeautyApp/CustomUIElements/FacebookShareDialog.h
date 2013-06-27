//
//  FacebookShareDialog.h
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 1/29/13.
//
//

#import <UIKit/UIKit.h>

@interface FacebookShareDialog : UIView

- (id) initWithImageURL:(NSString *) imageURL
        WithProductName:(NSString *) productName
         WithProductURL:(NSString *) productURL
          WithColorName:(NSString *) colorName
        withProductType:(NSNumber *) productType
 WithProductDescription: (NSString *) productDescription;

@end
