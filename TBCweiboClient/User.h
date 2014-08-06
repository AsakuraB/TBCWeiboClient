//
//  User.h
//  TBCweiboClient
//
//  Created by Lee Larry on 7/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

//用户信息
@property (strong, nonatomic) NSString *idStr;              //用户UID
@property (strong, nonatomic) NSString *screenName;         //用户昵称
@property (strong, nonatomic) NSString *name;               //好像是姓名备注？
@property (strong, nonatomic) NSString *profileImageUrl;    //头像地址（50*50）

//获取用户信息
- (User *)initWithJsonDictionary:(NSDictionary *)dic;

//外部调用
+ (User *)UserWithJsonDictionary:(NSDictionary *)dic;


@end
