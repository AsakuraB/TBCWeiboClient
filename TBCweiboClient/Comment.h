//
//  Comment.h
//  TBCweiboClient
//
//  Created by Lee Larry on 21/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "User.h"

@interface Comment : NSObject

@property (retain, nonatomic) User *commentUser;                   //评论作者

@property (strong, nonatomic) NSString *createdAt;          //创建时间
@property (nonatomic) long long  commentID;                 //评论ID
@property (strong, nonatomic) NSString *text;               //评论内容
@property (strong, nonatomic) NSString *source;             //评论来源

@property (retain, nonatomic) Status *commentedStatus;      //评论的微博

//获取评论信息
- (Comment *)initWithJsonDictionary:(NSDictionary *)dic;

//外部调用
+ (Comment *)commentWithJsonDictionary:(NSDictionary *)dic;

@end
