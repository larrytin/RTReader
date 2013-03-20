#import <UIKit/UIKit.h>
#import "PagedScrollView.h"

@interface HelpViewController : UIViewController <PagedScrollViewDatasource,PagedScrollViewDelegate>

@property(nonatomic, strong) void (^completionBlock)(void);

@end
