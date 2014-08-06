//
//  AtMeTableViewController.h
//  TBCweiboClient
//
//  Created by Lee Larry on 20/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "Comment.h"
#import "WeiboCell.h"

@interface AtMeTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *atMeWeiboArray;
@property (nonatomic) int weiboPage;

@property (strong, nonatomic) NSMutableArray *atMeCommentArray;
@property (nonatomic) int commentPage;

@end
