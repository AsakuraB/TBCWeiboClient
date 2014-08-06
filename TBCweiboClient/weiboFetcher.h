//
//  weiboFetcher.h
//  TBCweiboClient
//
//  Created by Lee Larry on 2/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APP_KEY                     @"1578844509"
#define APP_SECRET                  @"2e675f637bb33a04f2855d10509ea3b4"
#define APP_REDIRECT_URL            @"https://api.weibo.com/oauth2/default.html"

#define OAUTH_URL                   @"https://api.weibo.com/oauth2/authorize"
#define ACCESS_TOKEN_URL            @"https://api.weibo.com/oauth2/access_token"
#define GET_UID_URL                 @"https://api.weibo.com/2/account/get_uid.json"

#define HOME_TIMELINE_URL           @"https://api.weibo.com/2/statuses/home_timeline.json"
#define AT_ME_WEIBO_URL             @"https://api.weibo.com/2/statuses/mentions.json"
#define AT_ME_COMMENT_URL           @"https://api.weibo.com/2/comments/mentions.json"
//发送文字微博
#define WEIBO_UPDATE_URL            @"https://api.weibo.com/2/statuses/update.json"
//发送图片微博
#define WEIBO_UPLOAD_URL            @"https://upload.api.weibo.com/2/statuses/upload.json"
//转发微博
#define WEIBO_REPOST_STATUSES       @"https://api.weibo.com/2/statuses/repost.json"

@interface weiboFetcher : NSObject

+ (NSString *) returnAccessTokenString;

+ (NSString *) returnOAuthUrlString;

- (void) getAccessToken : (NSString *) code;

+ (NSString *) returnHomeTimelineUrlString: (int) page;

+ (NSString *) returnAtMeWeiboUrlString: (int) page;

+ (NSString *) returnAtMeCommentUrlString: (int) page;

@end
