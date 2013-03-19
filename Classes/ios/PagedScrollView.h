//
//  XLCycleScrollView.h
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PagedScrollViewDatasource;
@protocol PagedScrollViewDelegate;

@interface PagedScrollView : UIView<UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic, weak) id<PagedScrollViewDatasource> datasource;
@property (weak) id<PagedScrollViewDelegate> delegate;

-(void)scrollToPage:(int)page;

@end

@protocol PagedScrollViewDelegate <NSObject>

@optional
- (void)finish;
- (void) scrollToPage:(int)page;
@end

@protocol PagedScrollViewDatasource <NSObject>

@required
- (NSInteger)numberOfPages;
- (UIView *)pageAtIndex:(NSInteger)index;

@end
