//
//  StoreLocatorAnnotation.m
//  IMAN
//
//  Created by  on 18/03/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "StoreLocatorAnnotation.h"

@implementation StoreLocatorAnnotation

@synthesize coordinate, rightBtn;
@synthesize counter, subcounter;

- (NSString *)subtitle{
    return storeSubTitle;
}

- (NSString *)title{
    return storeTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)c Title:(NSString *)title SubTitle:(NSString *)subTitle index:(NSInteger)index subindex:(NSInteger)subindex rightBtn:(UIButton *)rightbtn{
    coordinate=c;
    storeTitle = title;
    counter = index;
    subcounter = subindex;
    storeSubTitle = subTitle;
    rightBtn = rightbtn;
    return self;
}

@end
