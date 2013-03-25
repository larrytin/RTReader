#import "OAuthLogin.h"
#import "gtm-oauth2/GTMOAuth2ViewControllerTouch.h"
#import "GTMHTTPFetcher/GTMHTTPFetcherLogging.h"
#import "SBJson/SBJson.h"
#import "JreEmulation.h"
#import "java/util/regex/Pattern.h"
#import "java/util/regex/Matcher.h"
#import <MBProgressHUD/MBProgressHUD.h>

static NSString *const keychainItemNameGoogle = @"OAuth2: Google";
static NSString *const keychainItemNameQQ = @"OAuth2: QQ";

NSString *clientIDGoogle = @"142258081502.apps.googleusercontent.com";     // pre-assigned by service
NSString *clientSecretGoogle = @"XkjTCrTPDJJWPfMFy1DE278l"; // pre-assigned by service
NSString * clientIDQQ = @"100298697";
NSString * clientSecretQQ = @"458cfb89855c48d2f26d6b99ffd5689d";

NSString *scopeGoogle = @"https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email"; // scope for Google+ API
NSString * scopeQQ = @"get_user_info,get_info,get_simple_userinfo";

@interface OAuthLogin ()

@end

@implementation OAuthLogin

@synthesize auth = _auth;
@synthesize loginSuccessHandler;
@synthesize fetchUserInfoCompleteHandler;

+(void)initialize{
  [GTMHTTPFetcher setLoggingEnabled:YES];
}

-(id)init {
  self = [super init];
  if(self) {
    // Fill in the Client ID and Client Secret text fields
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // First, we'll try to get the saved Google authentication, if any, from
    // the keychain
    
    GTMOAuth2Authentication *auth = nil;
    
    if (clientIDGoogle && clientSecretGoogle) {
      auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemNameGoogle
                                                                   clientID:clientIDGoogle
                                                               clientSecret:clientSecretGoogle];
    }
    
    if (auth.canAuthorize) {
      // Select the Google service segment
      self.auth = auth;
    } else {
      // There is no saved Google authentication
      //
      // Perhaps we have a saved authorization for QQ instead; try getting
      // that from the keychain
      if (clientIDQQ && clientSecretQQ) {
        auth = [self authForQQ];
        if (auth) {
          auth.clientID = clientIDQQ;
          auth.clientSecret = clientSecretQQ;
          
          BOOL didAuth = [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:keychainItemNameQQ
                                                                     authentication:auth];
          if (didAuth) {
            // select the DailyMotion radio button
            self.auth = auth;
          }
        }
      }
    }
  }
  return self;
}

- (UIViewController *)signInToGoogle {
  [self signOut];
  GTMOAuth2ViewControllerTouch *viewController;
  viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scopeGoogle
                                                              clientID:clientIDGoogle
                                                          clientSecret:clientSecretGoogle
                                                      keychainItemName:keychainItemNameGoogle
                                                     completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
                                                       if (error != nil) {
                                                         // Authentication failed
                                                         NSLog(@"Sign-in failed");
                                                       } else {
                                                         // Authentication succeeded
                                                         loginSuccessHandler();
                                                         [self fetchUserInfoFromGoogle:auth];
                                                       }
                                                     }
                    ];
  
  // Optional: display some html briefly before the sign-in page loads
  NSString *html = @"<html><body bgcolor=silver><div align=center>登录页加载中...</div></body></html>";
  viewController.initialHTMLString = html;
  return viewController;
}

- (UIViewController *)signInToQQ {
  [self signOut];
  
  GTMOAuth2Authentication *auth = [self authForQQ];
  
  // Specify the appropriate scope string, if any, according to the service's API documentation
  auth.scope = scopeQQ;
  
  NSURL *authURL = [NSURL URLWithString:@"https://openmobile.qq.com/oauth2.0/m_authorize"];
  
  // Display the authentication view
  GTMOAuth2ViewControllerTouch *viewController;
  viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                               authorizationURL:authURL
                                                               keychainItemName:keychainItemNameQQ
                                                              completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
                                                                if (error != nil) {
                                                                  // Sign-in failed
                                                                  NSLog(@"Sign-in failed");
                                                                  
                                                                } else {
                                                                  // Sign-in succeeded
                                                                  loginSuccessHandler();
                                                                  [self fetchUserInfoFromQQ:auth];
                                                                }
                                                              }
                    ];
  
  return  viewController;
}

-(void)fetchUserInfoFromGoogle:(GTMOAuth2Authentication *) auth {
  NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v1/userinfo"];
  NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
  NSString * __block toRtn;
  [auth authorizeRequest:request completionHandler:^(NSError *error) {
    if (error == nil) {
      GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
      [myFetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error != nil) {
          // failed; either an NSURLConnection error occurred, or the server returned
          // a status value of at least 300
          //
          // the NSError domain string for server status errors is kGTMHTTPFetcherStatusDomain
          int status = [error code];
          [self displayAlertWithMessage:@"取用户信息失败"];
          return;
        }
        NSDictionary * json = [[[SBJsonParser alloc] init ]objectWithData:data];
        // fetch succeeded
        toRtn = [json objectForKey:@"email"];
        fetchUserInfoCompleteHandler(toRtn);
      }];
    }
  }
   ];
}

-(void)fetchUserInfoFromQQ:(GTMOAuth2Authentication *) auth {
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.qq.com/oauth2.0/me?access_token=%@", auth.accessToken]];
  NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
  [auth authorizeRequest:request completionHandler:^(NSError *error) {
    if(error != nil){
      [self displayAlertWithMessage:@"取用户OpenId失败"];
      return;
    }
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
      if (error != nil) {
        // failed; either an NSURLConnection error occurred, or the server returned
        // a status value of at least 300
        //
        // the NSError domain string for server status errors is kGTMHTTPFetcherStatusDomain
        int status = [error code];
        [self displayAlertWithMessage:@"取用户信息失败"];
        return;
      }
      NSString* str = [[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding];
      JavaUtilRegexPattern * p = [JavaUtilRegexPattern compileWithNSString:@".*(\\{.*\\}).*"];
      JavaUtilRegexMatcher *m = [p matcherWithJavaLangCharSequence:str];
      if([m find]){
        NSString *j = [m groupWithInt:1];
        NSDictionary * json = [[[SBJsonParser alloc] init ]objectWithString:j];
        // fetch succeeded
        NSString *openId = [json objectForKey:@"openid"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.qq.com/user/get_info?access_token=%@&oauth_consumer_key=%@&openid=%@", auth.accessToken, auth.clientID, openId]];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        [myFetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
          NSDictionary * json = [[[SBJsonParser alloc] init ]objectWithData:data];
          NSString * name = [self getNameFromQQ:json];
          fetchUserInfoCompleteHandler(name);
        }];
      }
    }];
  }
   ];
}

-(NSString *)getNameFromQQ:(NSDictionary *)dict {
  NSDictionary * da = [dict objectForKey:@"data"];
  NSString * email = [da objectForKey:@"email"];
  if([email length] !=0 ){
    return email;
  }
  NSString * name = [da objectForKey:@"name"];
  if([name length]!=0 ){
    return name;
  }
  NSString *openId = [da objectForKey:@"openid"];
  return openId;
}

- (GTMOAuth2Authentication *)authForQQ {
  
  NSURL *tokenURL = [NSURL URLWithString:@"https://graph.qq.com/oauth2.0/token"];
  
  // We'll make up an arbitrary redirectURI.  The controller will watch for
  // the server to redirect the web view to this URI, but this URI will not be
  // loaded, so it need not be for any actual web page.
  NSString *redirectURI = @"http://moon.goodow.com/login";
  
  GTMOAuth2Authentication *auth;
  auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"QQ"
                                                           tokenURL:tokenURL
                                                        redirectURI:redirectURI
                                                           clientID:clientIDQQ
                                                       clientSecret:clientSecretQQ];
  return auth;
}

- (void)displayAlertWithMessage:(NSString *)message {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录"
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

- (void)signOut {
  if ([self.auth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
    // remove the token from Google's servers
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
  }
  
  // remove the stored Google authentication from the keychain, if any
  [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:keychainItemNameGoogle];
  
  // remove the stored QQ authentication from the keychain, if any
  [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:keychainItemNameQQ];
  
  // Discard our retained authentication object.
  self.auth = nil;
}

@end
