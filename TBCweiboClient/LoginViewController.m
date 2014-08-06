//
//  LoginViewController.m
//  TBCweiboClient
//
//  Created by Lee Larry on 16/6/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hud = [[MBProgressHUD alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"] == nil) {
        self.hud.labelText = @"正在加载授权页面...";
        [self.hud show:YES];
        [self.view addSubview:self.hud];

        //请求授权
        NSString *oauthUrlString = [weiboFetcher returnOAuthUrlString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:oauthUrlString]];
        [self.webView setDelegate:self];
        [self.webView loadRequest:request];
    } else {
        self.hud.labelText = @"正在加载微博内容...";
        [self.hud show:YES];
        [self.view addSubview:self.hud];
        [self performSelectorOnMainThread:@selector(goMainView) withObject:nil waitUntilDone:NO];
    }
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *backURL = [request URL];
    NSString *backURLString = [backURL absoluteString];
    
    if ([backURLString hasPrefix:@"https://api.weibo.com/oauth2/default.html?"]) {
        NSRange rangeOne = [backURLString rangeOfString:@"code="];
        NSRange range = NSMakeRange(rangeOne.location+rangeOne.length, backURLString.length - (rangeOne.location+rangeOne.length));
        NSString *codeString = [backURLString substringWithRange:range];
        //get access token
        weiboFetcher *weibo = [[weiboFetcher alloc] init];
        [weibo getAccessToken:codeString];
        [self performSegueWithIdentifier:@"MainSegue" sender:nil];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.hud removeFromSuperview];
}

- (void)goMainView
{
    [self.hud removeFromSuperview];
    [self performSegueWithIdentifier:@"MainSegue" sender:nil];
}

@end
