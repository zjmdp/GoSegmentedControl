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
    
    if ([self.delegate respondsToSelector:@selector(segmentedControl:willMoveToIndex:)]) {
        [self.delegate segmentedControl:self willMoveToIndex:self.selectedIndex];
    }
    
    CGFloat selectedItemRightPosition = [self getStartXPositionAtIndex:self.selectedIndex] + [self getSegmentWidthAtIndex:self.selectedIndex];
    CGFloat selectedItemLeftPosition = [self getStartXPositionAtIndex:self.selectedIndex];
    
    if (selectedItemRightPosition > CGRectGetWidth(self.scrollView.bounds)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + selectedItemRightPosition - CGRectGetWidth(self.scrollView.bounds), 0) animated:YES];
    }else if(selectedItemLeftPosition < 0){
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + selectedItemLeftPosition, 0) animated:YES];
    } else{
        [UIView animateWithDuration:self.indicatorAnimationDuration animations:^{
            [self updateIndicatorFrame];
        }completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(segmentedControl:didMoveToIndex:)]) {
                [self.delegate segmentedControl:self didMoveToIndex:self.selectedIndex];
            }
        }];
    }
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

- (CGFloat)getStartXPositionAtIndex:(NSInteger)index{
    CGFloat position = .0f;
    for (NSInteger i = 0; i < index; i++) {
        CGFloat segmentWidth = [self getSegmentWidthAtIndex:i];
        position += segmentWidth;
    }
    return position - self.scrollView.contentOffset.x;
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
    indicatorFrame.origin.x = [self getStartXPositionAtIndex:self.selectedIndex] + self.indicatorMargin;
    indicatorFrame.origin.y = CGRectGetHeight(self.bounds) - self.selectionIndicatorHeight;
    self.indicatorView.frame = indicatorFrame;
}

#pragma mark Public
- (void)moveToIndex:(NSUInteger)index{
    self.selectedIndex = index;
    
    CGFloat selectedItemRightPosition = [self getStartXPositionAtIndex:self.selectedIndex] + [self getSegmentWidthAtIndex:self.selectedIndex];
    CGFloat selectedItemLeftPosition = [self getStartXPositionAtIndex:self.selectedIndex];
    
    if (selectedItemRightPosition > CGRectGetWidth(self.scrollView.bounds)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + selectedItemRightPosition - CGRectGetWidth(self.scrollView.bounds), 0) animated:YES];
    }else if(selectedItemLeftPosition < 0){
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + selectedItemLeftPosition, 0) animated:YES];
    } else{
        [UIView animateWithDuration:self.indicatorAnimationDuration animations:^{
            [self updateIndicatorFrame];
        }];
    }
}

- (void)reloadData{
    [self layoutIfNeeded];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    [self updateIndicatorFrame];
}

@end
