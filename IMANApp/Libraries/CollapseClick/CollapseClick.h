//
//  CollapseClick.h
//  CollapseClick
//
//  Created by Ben Gordon on 2/28/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollapseClickCell.h"

#define kCCPad 1

  //////////////
 // Delegate //
//////////////
@protocol CollapseClickDelegate
@required
-(int)numberOfCellsForCollapseClick;
-(NSString *)titleForCollapseClickAtIndex:(int)index;
-(NSString *)subtitleForCollapseClickAtIndex:(int)index;
-(UIView *)viewForCollapseClickContentViewAtIndex:(int)index;

@optional
-(UIColor *)colorForCollapseClickTitleViewAtIndex:(int)index;
-(UIColor *)colorForTitleLabelAtIndex:(int)index;
-(UIColor *)colorForSubTitleLabelAtIndex:(int)index;
-(UIColor *)colorForTitleArrowAtIndex:(int)index;

@end




  ///////////////
 // Interface //
///////////////
@interface CollapseClick : UIScrollView <UIScrollViewDelegate>  {
    __weak id <CollapseClickDelegate> CollapseClickDelegate;
}

// Delegate
@property (weak) id <CollapseClickDelegate> CollapseClickDelegate;

// Properties
@property (nonatomic, retain) NSMutableArray *isClickedArray;
@property (nonatomic, retain) NSMutableArray *dataArray;

// Methods
-(void)reloadCollapseClick;
-(CollapseClickCell *)collapseClickCellForIndex:(int)index;
-(void)scrollToCollapseClickCellAtIndex:(int)index animated:(BOOL)animated;
-(UIView *)contentViewForCellAtIndex:(int)index;
-(void)openCollapseClickCellAtIndex:(int)index animated:(BOOL)animated;
-(void)closeCollapseClickCellAtIndex:(int)index animated:(BOOL)animated;
-(void)openCollapseClickCellsWithIndexes:(NSArray *)indexArray animated:(BOOL)animated;
-(void)closeCollapseClickCellsWithIndexes:(NSArray *)indexArray animated:(BOOL)animated;

@end
