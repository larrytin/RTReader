#import "PagedScrollView.h"

@implementation PagedScrollView {
  NSMutableArray *_curViews;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = YES;
    [self addSubview:self.scrollView];
    
    CGRect rect = self.bounds;
    rect.origin.y = rect.size.height - 90;
    rect.size.height = 30;
    self.pageControl = [[UIPageControl alloc] initWithFrame:rect];
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.currentPage = 0;
    //        [self addSubview:self.pageControl];
  }
  return self;
}

-(void)setDatasource:(id<PagedScrollViewDatasource>)datasource{
  _datasource = datasource;
  self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * [datasource numberOfPages] , self.bounds.size.height);
  self.pageControl.numberOfPages = [datasource numberOfPages];
  [self loadPage: self.pageControl.currentPage];
  _curViews = [[NSMutableArray alloc] init];
  for(int i=0;i<[datasource numberOfPages];i++){
    [_curViews addObject:[NSNull null]];
  }
}

- (void)loadScrollViewWithPage:(int)page
{
  if (page < 0)
    return;
  if (page >= [self.datasource numberOfPages]) {
    return;
  }
  
  // replace the placeholder if necessary
  UIView *view = [_curViews objectAtIndex:page];
  if ((NSNull *)view==[NSNull null])
  {
    view = [self.datasource pageAtIndex:page];
    [_curViews replaceObjectAtIndex:page withObject:view];
  }
  
  // add the controller's view to the scroll view
  if (view.superview == nil)
  {
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    view.frame = frame;
    [self.scrollView addSubview:view];
  }
}

-(void)loadPage:(int)page {
  [self.delegate scrollToPage:page];
  [self loadScrollViewWithPage:page - 1];
  [self loadScrollViewWithPage:page];
  [self loadScrollViewWithPage:page + 1];
}

-(void) scrollToPage:(int)page {
  [self loadPage:page];
  self.scrollView.contentOffset = CGPointMake(page * self.scrollView.frame.size.width, 0);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
  // Switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = self.scrollView.frame.size.width;
  int offsetX = self.scrollView.contentOffset.x;
  if(offsetX > pageWidth * ([self.datasource numberOfPages] - 1)) {
    [self.delegate finish];
    self.delegate = nil;
    return;
  }
  int page = floor((offsetX - pageWidth / 2) / pageWidth) + 1;
  self.pageControl.currentPage = page;
  // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
  [self loadPage:page];
  // update the scroll view to the appropriate page
  CGRect frame = self.scrollView.frame;
  frame.origin.x = frame.size.width * page;
  frame.origin.y = 0;
}

@end
