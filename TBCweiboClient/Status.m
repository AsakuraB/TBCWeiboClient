//
//  Status.m
//  TBCweiboClient
//
//  Created by Lee Larry on 7/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "Status.h"

@implementation Status

- (Status *)initWithJsonDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        
        if ([dic objectForKey:@"deleted"]) {
            self.text = [dic objectForKey:@"text"];
            self.wasDeleted = YES;
        } else {
        
            //处理用户字典
            NSDictionary *userDic = [dic objectForKey:@"user"];
            if (userDic) {
                self.user = [User UserWithJsonDictionary:userDic];
            }
            
            //处理微博来源
            NSString *string = [dic objectForKey:@"source"];
            NSRange start = [string rangeOfString:@"\">"];
            NSRange end = [string rangeOfString:@"</a>"];
            NSRange range = NSMakeRange(start.location+start.length, string.length-start.location-start.length-end.length);
            self.source = [string substringWithRange:range];

            
            //处理微博内容
            self.createdAt = [dic objectForKey:@"created_at"];
            self.statuesID = [[dic objectForKey:@"id"] longLongValue];
            self.text = [dic objectForKey:@"text"];
            
            self.thumbnailPic = [dic objectForKey:@"thumbnail_pic"];
            self.bmiddlePic = [dic objectForKey:@"bmiddle_pic"];
            self.originalPic = [dic objectForKey:@"original_pic"];
            
            self.repostsCount = [[dic objectForKey:@"reposts_count"] integerValue];
            self.commentsCount = [[dic objectForKey:@"comments_count"] integerValue];
            self.attitudesCount = [[dic objectForKey:@"attitudes_count"] integerValue];
            
            self.picUrls = [dic objectForKey:@"pic_urls"];
            
            
            //处理转发和图片
            NSDictionary *retweetDic = [dic objectForKey:@"retweeted_status"];
            
            if (retweetDic) {
                //有转发
                self.hasRetwitter = YES;
                self.retweetedStatus = [Status statusWithJsonDictionary:retweetDic];
                //该转发是否有图片
                NSString *url = self.retweetedStatus.thumbnailPic;
                self.hasRetwitterImage = (url != nil && [url length] != 0 ? YES : NO);
            } else {
                //没转发
                self.hasRetwitter = NO;
                //该微博是否有图片
                NSString *url = self.thumbnailPic;
                self.hasImage = (url != nil && [url length] != 0 ? YES : NO);
            }
        }
    }
    return self;
}

+ (Status *)statusWithJsonDictionary:(NSDictionary *)dic
{
    return [[Status alloc] initWithJsonDictionary:dic];
}

@end
