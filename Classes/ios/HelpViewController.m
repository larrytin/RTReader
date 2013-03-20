#import "HelpViewController.h"
#import "PagedScrollView.h"

@interface HelpViewController ()
@property PagedScrollView *portrait;
@property PagedScrollView *landscape;
@end

@implementation HelpViewController {
  int curPage;
}

#define degreesToRadians(x) (M_PI * (x) / 180.0)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
	// Do any additional setup after loading the view.
  [self loadScrollView:self.interfaceOrientation];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
  [self loadScrollView:interfaceOrientation];
}

-(void)loadScrollView:(UIInterfaceOrientation) interfaceOrientation{
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    if(!self.portrait){
      self.portrait = [[PagedScrollView alloc] initWithFrame:[self rectInOrientation:interfaceOrientation]];
      [self.portrait setDatasource: self];
      self.portrait.delegate = self;
      [self.view addSubview:self.portrait];
    }
    self.landscape.hidden = YES;
    [self.portrait scrollToPage:curPage];
    self.portrait.hidden = NO;
  } else {
    if(!self.landscape){
      self.landscape = [[PagedScrollView alloc] initWithFrame:[self rectInOrientation:interfaceOrientation]];
      self.landscape.datasource=self;
      self.landscape.delegate = self;
      [self.view addSubview:self.landscape];
    }
    self.portrait.hidden = YES;
    [self.landscape scrollToPage:curPage];
    self.landscape.hidden = NO;
  }
    //  [self.view setNeedsDisplay];
}

-(void)scrollToPage:(int)page{
  curPage = page;
}

-(void)finish{
  if(self.presentingViewController){
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
  } else {
    self.completionBlock();
  }
}

- (UIView *)pageAtIndex:(NSInteger)index
{
  NSString *name = [NSString stringWithFormat:@"help_%@_%d.PNG", UIInterfaceOrientationIsPortrait(self.interfaceOrientation)?@"portrait":@"landscape", index];
  UIImage *image = [UIImage imageNamed:name];
  UIImageView *view = [[UIImageView alloc] initWithImage: image];
  return view;
}


-(CGRect) rectInOrientation:(UIInterfaceOrientation)orientation
{
  CGSize size = [UIScreen mainScreen].bounds.size;
  UIApplication *application = [UIApplication sharedApplication];
  if (UIInterfaceOrientationIsLandscape(orientation) ^ (size.width > size.height)){
    size = CGSizeMake(size.height, size.width);
  }
  if (application.statusBarHidden == NO)
  {
    size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
  }
  return CGRectMake(0,0,size.width,size.height);
}

- (NSInteger)numberOfPages
{
  return 5;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
