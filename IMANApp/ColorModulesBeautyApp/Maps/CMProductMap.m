//
//  CMProductMap.m
//  ColorModulesBeautyApp
//
//  Created by Varun Goyal on 2/27/13.
//
//

#import "CMProductMap.h"

@implementation CMProductMap

- (id) initWithProduct: (id) product
{
    if (self = [super init])
    {
        self.productID = [NSNumber numberWithInt:[[product objectForKey:@"id"] integerValue]];
        
        // update with extern id to be returned from backend
        self.externalID = [NSNumber numberWithInt:[[product objectForKey:@"id"] integerValue]];
        
        
        self.typeID = [NSNumber numberWithInt:[[product objectForKey:@"type_id"] integerValue]];
        self.categoryID = [NSNumber numberWithInt:[[product objectForKey:@"product_category_id"] integerValue]];
        self.title = [product objectForKey:@"title"];
        self.colorName = [product objectForKey:@"color_name"];
        self.color = [self extractProductColor:[product objectForKey:@"color"]];
        self.brandName = [product objectForKey:@"brand"];
        self.sellerName = [product objectForKey:@"seller"];
        self.description = [product objectForKey:@"description"];
        self.price = [[product objectForKey:@"price"] floatValue];
        self.url = [NSURL URLWithString:[product objectForKey:@"url"]];
        self.imageURL = [NSURL URLWithString:[product objectForKey:@"image_url_abs"]];
        self.matchMessage = [product objectForKey:@"match_message"];
        self.isWishlist = [[product objectForKey:@"user_saved"] boolValue];
    }
    
    return self;
}

- (UIColor *) extractProductColor: (id) colorDict
{
    float color_r=[[colorDict objectForKey:@"r"] floatValue];
    float color_g=[[colorDict objectForKey:@"g"] floatValue];
    float color_b=[[colorDict objectForKey:@"b"] floatValue];
    
    return [UIColor
            colorWithRed:(float)color_r/255.0f
            green:(float)color_g/255.0f
            blue:(float)color_b/255.0f
            alpha:1.0f];
}


- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties...
    [encoder encodeObject:self.productID forKey:@"productID"];
    [encoder encodeObject:self.externalID forKey:@"externalID"];
    [encoder encodeObject:self.typeID forKey:@"typeID"];
    [encoder encodeObject:self.categoryID forKey:@"categoryID"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.colorName forKey:@"colorName"];
    [encoder encodeObject:self.color forKey:@"color"];
    [encoder encodeObject:self.brandName forKey:@"brandName"];
    [encoder encodeObject:self.sellerName forKey:@"sellerName"];
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:[NSString stringWithFormat:@"%f", self.price] forKey:@"price"];
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.matchMessage forKey:@"matchMessage"];
    [encoder encodeObject: [NSNumber numberWithBool:self.isWishlist] forKey:@"isWishlist"];
}


- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init]))
    {
        // Decode properties
        self.productID = [decoder decodeObjectForKey:@"productID"];
        self.externalID = [decoder decodeObjectForKey:@"externalID"];
        self.typeID = [decoder decodeObjectForKey:@"typeID"];
        self.categoryID = [decoder decodeObjectForKey:@"categoryID"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.colorName = [decoder decodeObjectForKey:@"colorName"];
        self.color = [decoder decodeObjectForKey:@"color"];
        self.brandName = [decoder decodeObjectForKey:@"brandName"];
        self.sellerName = [decoder decodeObjectForKey:@"sellerName"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.price = [[decoder decodeObjectForKey:@"price"] floatValue];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.matchMessage = [decoder decodeObjectForKey:@"matchMessage"];
        self.isWishlist = [[decoder decodeObjectForKey:@"isWishlist"] boolValue];
    }
    return self;
}


@end
