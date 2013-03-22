//
//  GDRootViewController.m
//  RTReader
//
//  Created by dev on 13-3-20.
//  Copyright (c) 2013年 Larry Tin. All rights reserved.
//

#import "GDRootViewController.h"
#import "gtm-oauth2/GTMOAuth2ViewControllerTouch.h"
#import "SBJson/SBJson.h"
#import "JreEmulation.h"
#import "java/util/regex/Pattern.h"
#import "java/util/regex/Matcher.h"

static NSString *const keychainItemNameGoogle = @"OAuth2: Google";
static NSString *const keychainItemNameQQ = @"OAuth2: QQ";

NSString *clientIDGoogle = @"142258081502.apps.googleusercontent.com";     // pre-assigned by service
NSString *clientSecretGoogle = @"XkjTCrTPDJJWPfMFy1DE278l"; // pre-assigned by service
NSString * clientIDQQ = @"100298697";
NSString * clientSecretQQ = @"458cfb89855c48d2f26d6b99ffd5689d";

NSString *scopeGoogle = @"https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email"; // scope for Google+ API
NSString * scopeQQ = @"get_user_info,get_info,get_simple_userinfo";

@interface GDRootViewController ()

@end

@implementation GDRootViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.item) {
    case 0:
      [self signInToQQ];
      break;
      
    case 1:
      [self signInToGoogle];
      break;
    default:
      break;
  }
}

- (void)signInToGoogle {
  //  [self signOut];
  GTMOAuth2ViewControllerTouch *viewController;
  viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scopeGoogle
                                                              clientID:clientIDGoogle
                                                          clientSecret:clientSecretGoogle
                                                      keychainItemName:keychainItemNameGoogle
                                                     completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
                                                       if (error != nil) {
                                                         // Authentication failed
                                                         [self displayAlertWithMessage:@"登录失败"];
                                                       } else {
                                                         // Authentication succeeded
                                                         [self fetchUserInfoFromGoogle:auth];
                                                       }
                                                     }
                    ];
  
  // Optional: display some html briefly before the sign-in page loads
  NSString *html = @"<html><body bgcolor=silver><div align=center>登录页加载中...</div></body></html>";
  viewController.initialHTMLString = html;
  [[self navigationController] pushViewController:viewController
                                         animated:YES];
  
}



-(void)fetchUserInfoFromGoogle:(GTMOAuth2Authentication *) auth {
  NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v1/userinfo"];
  NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
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
        } else {
          NSDictionary * json = [[[SBJsonParser alloc] init ]objectWithData:data];
          // fetch succeeded
          self.userName.text = [json objectForKey:@"email"];
        }
      }];
    }
  }
   ];
}

-(void)fetchUserInfoFromQQ:(GTMOAuth2Authentication *) auth {
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.qq.com/oauth2.0/me?access_token=%@", auth.accessToken]];
  NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
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
        } else {
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
              self.userName.text = name;
            }];
          }
        }
      }];
    }
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

- (void)signInToQQ {
  //  [self signOut];
  
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
                                                                  [self displayAlertWithMessage:@"登录失败"];
                                                                } else {
                                                                  // Sign-in succeeded
                                                                  [self fetchUserInfoFromQQ:auth];
                                                                }
                                                              }
                    ];
  
  // Now push our sign-in view
  [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)displayAlertWithMessage:(NSString *)message {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录"
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

@end
