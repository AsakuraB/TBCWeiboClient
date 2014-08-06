//
//  Comment.m
//  TBCweiboClient
//
//  Created by Lee Larry on 21/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (Comment *)initWithJsonDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        
        //处理评论作者字典
        NSDictionary *commentUserDic = [dic objectForKey:@"user"];
        if (commentUserDic) {
            self.commentUser = [User UserWithJsonDictionary:commentUserDic];
        }
        
        //处理评论来源
        NSString *string = [dic objectForKey:@"source"];
        NSRange start = [string rangeOfString:@"\">"];
        NSRange end = [string rangeOfString:@"</a>"];
        NSRange range = NSMakeRange(start.location+start.length, string.length-start.location-start.length-end.length);
        self.source = [string substringWithRange:range];

        //处理评论内容
        self.createdAt = [dic objectForKey:@"created_at"];
        self.commentID = [[dic objectForKey:@"id"] longLongValue];
        self.text = [dic objectForKey:@"text"];

        //处理评论的微博
        NSDictionary *commentedStatusDic = [dic objectForKey:@"status"];
        if (commentedStatusDic) {
            self.commentedStatus = [Status statusWithJsonDictionary:commentedStatusDic];
        }
    }
    return self;
}

+ (Comment *)commentWithJsonDictionary:(NSDictionary *)dic
{
    return [[Comment alloc] initWithJsonDictionary:dic];
}

@end
