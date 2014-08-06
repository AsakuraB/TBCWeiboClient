//
//  User.m
//  TBCweiboClient
//
//  Created by Lee Larry on 7/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "User.h"

@implementation User

- (User *)initWithJsonDictionary:(NSDictionary *)dic
{
    self.idStr = [dic objectForKey:@"idstr"];
    self.screenName = [dic objectForKey:@"screen_name"];
    self.name = [dic objectForKey:@"name"];
    self.profileImageUrl = [dic objectForKey:@"profile_image_url"];
    return self;
}

+ (User *)UserWithJsonDictionary:(NSDictionary *)dic
{
    return [[User alloc] initWithJsonDictionary:dic];
}


@end
