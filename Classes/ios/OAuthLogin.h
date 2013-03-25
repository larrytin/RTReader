#import <UIKit/UIKit.h>
#import "gtm-oauth2/GTMOAuth2Authentication.h"

@interface OAuthLogin: NSObject

@property (nonatomic, strong) GTMOAuth2Authentication *auth;
@property (nonatomic, strong) void (^loginSuccessHandler)(void);
@property (nonatomic, strong) void (^fetchUserInfoCompleteHandler)(NSString * name);

-(UIViewController *)signInToQQ;
-(UIViewController *)signInToGoogle;
-(void)signOut;

@end