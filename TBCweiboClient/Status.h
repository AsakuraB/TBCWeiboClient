//
//  Status.h
//  TBCweiboClient
//
//  Created by Lee Larry on 7/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Status : NSObject

//微博内容
@property (retain, nonatomic) User *user;                   //作者信息

@property (strong, nonatomic) NSString *createdAt;          //创建时间
@property (nonatomic) long long  statuesID;                 //微博ID
@property (strong, nonatomic) NSString *text;               //微博内容
@property (strong, nonatomic) NSString *source;             //微博来源

@property (strong, nonatomic) NSString *thumbnailPic;       //缩略图
@property (strong, nonatomic) NSString *bmiddlePic;         //中等尺寸图
@property (strong, nonatomic) NSString *originalPic;        //原图

@property (retain, nonatomic) Status *retweetedStatus;      //转发的微博
@property (assign, nonatomic) int repostsCount;             //转发数
@property (assign, nonatomic) int commentsCount;            //评论数
@property (assign, nonatomic) int attitudesCount;           //点赞数

@property (strong, nonatomic) NSArray *picUrls;            //配图地址

@property (assign, nonatomic) BOOL hasRetwitter;
@property (assign, nonatomic) BOOL hasRetwitterImage;
@property (assign, nonatomic) BOOL hasImage;
@property (assign, nonatomic) BOOL wasDeleted;


//获取微博信息
- (Status *)initWithJsonDictionary:(NSDictionary *)dic;

//外部调用
+ (Status *)statusWithJsonDictionary:(NSDictionary *)dic;

@end
