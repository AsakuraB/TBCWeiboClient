//
//  weiboFetcher.m
//  TBCweiboClient
//
//  Created by Lee Larry on 2/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "weiboFetcher.h"

@implementation weiboFetcher

+ (NSString *) returnAccessTokenString
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
}


+ (NSString *) returnOAuthUrlString
{
    return [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=code&display=mobile&state=authorize", OAUTH_URL, APP_KEY, APP_REDIRECT_URL];
}

- (void) getAccessToken : (NSString *) code
{
    NSMutableString *accessTokenUrlString = [[NSMutableString alloc] initWithFormat:@"%@?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=",ACCESS_TOKEN_URL, APP_KEY, APP_SECRET, APP_REDIRECT_URL];
    [accessTokenUrlString appendString:code];
    
    NSURL *urlstring = [NSURL URLWithString:accessTokenUrlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlstring
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil
                                                         error:nil];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:received
                                                            options:0
                                                              error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:[results objectForKey:@"access_token"] forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self getUidString];
    NSLog(@"access token is = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]);
}

- (void) getUidString
{
    NSString *uidURLString = [[NSString alloc] initWithFormat:@"%@?access_token=%@", GET_UID_URL, [weiboFetcher returnAccessTokenString]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:uidURLString]];
    NSData *uidData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:nil
                                                        error:nil];
    NSDictionary *uid = [NSJSONSerialization JSONObjectWithData:uidData
                                                        options:0
                                                          error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:[uid objectForKey:@"uid"] forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // NSLog(@"uid is = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]);
}

+ (NSString *) returnHomeTimelineUrlString: (int) page
{
    return [NSString stringWithFormat:@"%@?access_token=%@&page=%d", HOME_TIMELINE_URL, [weiboFetcher returnAccessTokenString], page];
}

+ (NSString *) returnAtMeWeiboUrlString:(int)page
{
    return [NSString stringWithFormat:@"%@?access_token=%@&page=%d", AT_ME_WEIBO_URL, [weiboFetcher returnAccessTokenString], page];
}

+ (NSString *) returnAtMeCommentUrlString:(int)page
{
    return [NSString stringWithFormat:@"%@?access_token=%@&page=%d", AT_ME_COMMENT_URL, [weiboFetcher returnAccessTokenString], page];
}

@end
