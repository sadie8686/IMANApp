//
//  StoreLocatorAnnotation.h
//  IMAN
//
//  Created by  on 18/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "StoreLocatorViewController.h"
#import <MapKit/MapKit.h>

@interface StoreLocatorAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *storeTitle;
    NSString *storeSubTitle;
    UIButton *rightBtn;
    NSInteger counter;
    NSInteger subcounter;
}

@property (nonatomic, retain) UIButton *rightBtn;
@property NSInteger counter;
@property NSInteger subcounter;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c Title:(NSString *)title SubTitle:(NSString *)subTitle index:(NSInteger)index subindex:(NSInteger)subindex rightBtn:(UIButton *)rightbtn;

@end
