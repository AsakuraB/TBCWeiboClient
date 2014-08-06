//
//  LoginViewController.h
//  TBCweiboClient
//
//  Created by Lee Larry on 16/6/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "weiboFetcher.h"

@interface LoginViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
