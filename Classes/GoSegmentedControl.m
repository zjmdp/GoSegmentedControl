//
//  GoSegmentedControl.m
//  LetsGo
//
//  Created by jamie on 15/12/22.
//  Copyright © 2015年 X-Monster. All rights reserved.
//

#import "GoSegmentedControl.h"

@interface GoSegmentedControl() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger segmentCounts;

@property (nonatomic, strong) UIView *indicatorView;

@end

@implementation GoSegmentedControl

- (instancetype)init{
    if (self = [super init]) {
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollViewTap:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    [self addSubview:self.scrollView];
    
    self.selectionIndicatorHeight = 4.f;
    self.selectionIndicatorColor = [UIColor colorWithRed:(CGFloat)217/255
                                                   green:(CGFloat)70/255
                                                    blue:(CGFloat)72/255
                                                   alpha:1];
    self.indicatorAnimationDuration = .4f;
}

- (void)layoutSubviews{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat currentLayoutWidth = .0f;
    self.segmentCounts = [self getSegmentsCount];
    for (NSInteger i = 0; i < self.segmentCounts; i++) {
        CGFloat segmentWidth = [self getSegmentWidthAtIndex:i];
        UIView *segmentView = [self getSegmentViewAtIndex:i];
        [segmentView setFrame:CGRectMake(currentLayoutWidth, 0, segmentWidth, CGRectGetHeight(self.bounds) - self.selectionIndicatorHeight)];
        [self.scrollView addSubview:segmentView];
        currentLayoutWidth += segmentWidth;
    }
    [self.scrollView setContentSize:CGSizeMake(currentLayoutWidth, CGRectGetHeight(self.bounds))];
    
    if (self.segmentCounts > 0) {
    }
    if (self.indicatorView == nil) {
        self.indicatorView = [UIView new];
        [self addSubview:self.indicatorView];
    }
    [self.indicatorView setBackgroundColor:self.selectionIndicatorColor];
    [self updateIndicatorFrame];
}

#pragma mark Private

- (void)handleScrollViewTap:(UITapGestureRecognizer *)recognizer{
    CGPoint tappedPoint = [recognizer locationInView:self.scrollView];
    CGFloat exploreWidth = .0f;
    for (NSInteger i = 0; i < self.segmentCounts; i++) {
        exploreWidth += [self getSegmentWidthAtIndex:i];
        if (exploreWidth > tappedPoint.x) {
            self.selectedIndex = i;
            break;
        }
    }
    [self updateStateWithRespondingDelegate:YES animated:YES];
}

- (NSInteger)getSegmentsCount{
    if ([self.dataSource respondsToSelector:@selector(numberOfSegmentsInGoSegmentedControl:)]) {
        NSInteger segmentsCount = [self.dataSource numberOfSegmentsInGoSegmentedControl:self];
        NSAssert(segmentsCount >= 0, @"number of segments must >= 0");
        return segmentsCount;
    }else{
        return 0;
    }
}

- (CGFloat)getSegmentWidthAtIndex:(NSInteger)index{
    if ([self.delegate respondsToSelector:@selector(segmentedControl:widthForSegmentAtIndex:)]) {
        NSInteger width = [self.delegate segmentedControl:self widthForSegmentAtIndex:index];
        NSAssert(width > 0, @"Segment widht must >= 0");
        return width;
    }else{
        return CGFLOAT_MIN;
    }
}

- (CGFloat)getContentOffsetXAtIndex:(NSInteger)index{
    CGFloat position = .0f;
    for (NSInteger i = 0; i < index; i++) {
        CGFloat segmentWidth = [self getSegmentWidthAtIndex:i];
        position += segmentWidth;
    }
    return position;
}

- (UIView *)getSegmentViewAtIndex:(NSInteger)index{
    if ([self.dataSource respondsToSelector:@selector(segmentedControl:customSegmentViewAtIndex:)]) {
        UIView *customView = [self.dataSource segmentedControl:self customSegmentViewAtIndex:index];
        if (customView == nil) {
            return [UIView new];
        }
        return customView;
    }else{
        return [UIView new];
    }
}

- (void)updateIndicatorFrame{
    CGRect indicatorFrame = self.indicatorView.frame;
    indicatorFrame.size.width = [self getSegmentWidthAtIndex:self.selectedIndex] - 2 * self.indicatorMargin;
    indicatorFrame.size.height = self.selectionIndicatorHeight;
    indicatorFrame.origin.x = [self getContentOffsetXAtIndex:self.selectedIndex] - self.scrollView.contentOffset.x + self.indicatorMargin;
    indicatorFrame.origin.y = CGRectGetHeight(self.bounds) - self.selectionIndicatorHeight;
    self.indicatorView.frame = indicatorFrame;
}

- (void)updateStateWithRespondingDelegate:(BOOL)isResponding animated:(BOOL)animated{
    if (isResponding) {
        if ([self.delegate respondsToSelector:@selector(segmentedControl:willMoveToIndex:)]) {
            [self.delegate segmentedControl:self willMoveToIndex:self.selectedIndex];
        }
    }
    
    CGFloat selectedItemLeftPosition = [self getContentOffsetXAtIndex:self.selectedIndex];
    CGFloat selectedItemWidth = [self getSegmentWidthAtIndex:self.selectedIndex];
    
    if(selectedItemLeftPosition >= self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds) / 2){
        if (animated) {
            [UIView animateWithDuration:self.indicatorAnimationDuration animations:^{
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width - self.scrollView.bounds.size.width, 0)];
                [self updateIndicatorFrame];
            }];
        }else{
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width - self.scrollView.bounds.size.width, 0)];
            [self updateIndicatorFrame];
        }
    }else if (selectedItemLeftPosition + selectedItemWidth / 2 > CGRectGetWidth(self.scrollView.bounds) / 2) {
            CGFloat newOffset = selectedItemLeftPosition + selectedItemWidth / 2 - CGRectGetWidth(self.scrollView.bounds) / 2;
            if (animated) {
                [UIView animateWithDuration:self.indicatorAnimationDuration animations:^{
                    [self.scrollView setContentOffset:CGPointMake(newOffset, 0)];
                    [self updateIndicatorFrame];
                }];
            }else{
                [self.scrollView setContentOffset:CGPointMake(newOffset, 0)];
                [self updateIndicatorFrame];
            }
    } else{
        if (self.scrollView.contentOffset.x > 0) {
            CGFloat newOffset = (self.scrollView.contentOffset.x - selectedItemWidth / 2 > 0) ? (self.scrollView.contentOffset.x - selectedItemWidth / 2) : 0;
            if (animated) {
                [UIView animateWithDuration:self.indicatorAnimationDuration animations:^{
                    [self.scrollView setContentOffset:CGPointMake(newOffset, 0)];
                }];
            }else{
                [self.scrollView setContentOffset:CGPointMake(newOffset, 0)];
            }
        }else{
            if (animated) {
                [UIView animateWithDuration:self.indicatorAnimationDuration animations:^{
                    [self updateIndicatorFrame];
                }];
            }else{
                [self updateIndicatorFrame];
            }
        }
    }
    
    if (isResponding && [self.delegate respondsToSelector:@selector(segmentedControl:didMoveToIndex:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.indicatorAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate segmentedControl:self didMoveToIndex:self.selectedIndex];
        });
    }
    
}

#pragma mark Public
- (void)moveToIndex:(NSUInteger)index{
    [self moveToIndex:index animated:YES];
}

- (void)moveToIndex:(NSUInteger)index animated:(BOOL)animated{
    if (self.selectedIndex != index) {
        self.selectedIndex = index;
        [self updateStateWithRespondingDelegate:NO animated:animated];
    }
}

- (void)reloadData{
    [self layoutIfNeeded];
}

- (UIView *)viewAtIndex:(NSInteger)index{
    if(index <= self.scrollView.subviews.count - 1 && index >= 0){
        return self.scrollView.subviews[index];
    }else{
        return nil;
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    [self updateIndicatorFrame];
}

@end
