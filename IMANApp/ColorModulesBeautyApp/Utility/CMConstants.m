//
//  constants.m
//  ColorModulesBeautyApp
//
//  Created by Nicky Liu on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMConstants.h"
#import "Logging.h"

@implementation CMConstants
+(UIColor *) getPlumColor
{
    return [UIColor colorWithRed:132/255.0f green:20/255.0f blue:60/255.0f alpha:1.0f];
}





+(NSArray *) getLipSubCategoryOrderedKeys
{
    return ([NSArray arrayWithObjects:
             @"all",
             @"LIPSTICK",
             @"LIPSHIMMER",
             @"LIPSHINE",
             @"LIPSTAIN",
             @"LIPPENCIL",
             nil]);
}
+(NSDictionary *) getLipSubCategories
{
    /*
     #define subCategoryIdForLipgloss @"13"
     #define subCategoryIdForLipstick @"16"
     #define subCategoryIdForLipliner @"43"
     #define subCategoryIdForLipstains @"44"
     #define subCategoryIdForLipshine @"53"
     #define subCategoryIdForLipshimmer @"54"
     #define subCategoryIdForLippencil @"55"
     */
    
    NSDictionary *lipSubCategories = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"", @"all",
                                      subCategoryIdForLipstick, @"LIPSTICK",
                                      subCategoryIdForLipshimmer, @"LIPSHIMMER",
                                      subCategoryIdForLipshine, @"LIPSHINE",
                                      subCategoryIdForLipstains, @"LIPSTAIN",
                                      subCategoryIdForLippencil, @"LIPPENCIL",
                                      nil];
    return lipSubCategories;
}




+(NSArray *) getEyeSubCategoryOrderedKeys
{
    return ([NSArray arrayWithObjects:
             @"all",
             @"EYESHADOW",
             @"EYEPENCIL",
             @"EYEBROW PENCIL",
             @"EYELINER",
             @"EYEPOWDER",
             nil]);
}
+(NSDictionary *) getEyeSubCategories
{
    /*
     #define subCategoryIdForEyeshadow @"9"
     #define subCategoryIdForEyeliner @"45"
     #define subCategoryIdForEyepowder @"50"
     #define subCategoryIdForEyepencil @"51"
     #define subCategoryIdForEyebrowpencil @"52"
     */
    
    NSDictionary *eyeSubCategories = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"", @"all",
                                      subCategoryIdForEyeshadow, @"EYESHADOW",
                                      subCategoryIdForEyepencil, @"EYEPENCIL",
                                      subCategoryIdForEyepencil, @"EYEBROW PENCIL",
                                      subCategoryIdForEyeliner, @"EYELINER",
                                      subCategoryIdForEyepowder,  @"EYEPOWDER",
                                      nil];
    return eyeSubCategories;
    
}




+(NSArray *) getFaceSubCategoryOrderedKeys
{
    return ([NSArray arrayWithObjects:
             @"all",
             @"BB CREME",
             @"FOUNDATION",
             @"POWDER",
             @"BRONZER",
             @"BLUSH",
             nil]);
}
+(NSDictionary *) getFaceSubCategories
{
    /*
     #define subCategoryIdForBlush @"46"
     #define subCategoryIdForNeutralizers @"10"
     #define subCategoryIdForPowder @"12"
     #define subCategoryIdForFoundation @"11"
     #define subCategoryIdForBBCreme @"48"
     #define subCategoryIdForBronzer @"49"
     */
    
    NSDictionary *faceSubCategories = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"", @"all",
                                       subCategoryIdForBBCreme, @"BB CREME",
                                       subCategoryIdForFoundation, @"FOUNDATION",
                                       subCategoryIdForPowder, @"POWDER",
                                       subCategoryIdForBronzer, @"BRONZER",
                                       subCategoryIdForBlush, @"BLUSH",
                                       nil];
    return faceSubCategories;
}

@end
