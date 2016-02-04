//
//  GoSegmentedControl.h
//  LetsGo
//
//  Created by jamie on 15/12/22.
//  Copyright © 2015年 X-Monster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoSegmentedControl;

@protocol GoSegmentedControlDataSource <NSObject>

@required
/**
 *  Tells the data source to return the number of segmentes of the control.
 *
 *  @param segmentedControl The control requesting the information.
 *
 *  @return The number of segmentes.
 */
- (NSInteger)numberOfSegmentsInGoSegmentedControl:(nonnull GoSegmentedControl *)segmentedControl;
/**
 *  Asks the data source for a custom segment view at a particular index of the control.
 *
 *  @param segmentedControl  The control requesting the information.
 *  @param index             An index locating a segment view in control.
 *
 *  @return A segment view for the specified index.
 */
- (nonnull UIView *)segmentedControl:(nonnull GoSegmentedControl *)segmentedControl customSegmentViewAtIndex:(NSInteger)index;

@end

@protocol GoSegmentedControlDelegate <NSObject>

@required
/**
 *  Asks the delegate for the width to use for a segment in a specified location.
 *
 *  @param segmentedControl The control requesting the information.
 *  @param index            An index locating the segment in control.
 *
 *  @return A nonnegative floating-point value that specifies the width (in points) that segment should be.
 */
- (CGFloat)segmentedControl:(nonnull GoSegmentedControl *)segmentedControl widthForSegmentAtIndex:(NSInteger)index;

@optional
/**
 *  Tells the delegate that a specified segment is about to be move to.
 *
 *  @param segmentedControl The control requesting the informatin.
 *  @param index            An index locating the segment in control.
 */
- (void)segmentedControl:(nonnull GoSegmentedControl *)segmentedControl willMoveToIndex:(NSInteger)index;
/**
 *  Tells the delegate that a specified segment is now moved to.
 *
 *  @param segmentedControl The control requesting the informatin.
 *  @param index            An index locating the segment in control.
 */
- (void)segmentedControl:(nonnull GoSegmentedControl *)segmentedControl didMoveToIndex:(NSInteger)index;

@end

@interface GoSegmentedControl : UIControl

/**
 *  The object that acts as the data source of the control.
 */
@property (nonatomic, weak) id<GoSegmentedControlDelegate> delegate;
/**
 *  The object that acts as the delegate of the control.
 */
@property (nonatomic, weak) id<GoSegmentedControlDataSource> dataSource;
/**
 *  The tint color to apply to the indicator.
 */
@property (nonnull, nonatomic, strong) UIColor *selectionIndicatorColor;
/**
 *  The height of the indicator.
 */
@property (nonatomic, assign) CGFloat selectionIndicatorHeight;
/**
 *  The animation duration that the indicator move from one segment to another.
 */
@property (nonatomic, assign) CGFloat indicatorAnimationDuration;
/**
 *  The margin that relative to segment view to apply to the indicator.
 */
@property (nonatomic, assign) CGFloat indicatorMargin;
/**
 *  Move the indicator the specified index.
 *
 *  @param index The index moved to.
 */
- (void)moveToIndex:(NSUInteger)index;
/**
 *  Move the indicator the specified index.
 *
 *  @param index    The index moved to
 *  @param animated YES to animate the transition at a constant velocity to the new offset, NO to make the transition immediate.
 */
- (void)moveToIndex:(NSUInteger)index animated:(BOOL)animated;
/**
 *  Reload data if data sources are changed.
 */
- (void)reloadData;
/**
 *  Accessing the view at specified index.
 *
 *  @param index An index locating a segment view in control.
 *
 *  @return The view at specified index
 */
- (UIView *)viewAtIndex:(NSUInteger)index;

@end
