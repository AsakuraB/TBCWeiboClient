//
//  HomepageTableViewController.h
//  TBCweiboClient
//
//  Created by Lee Larry on 3/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboCell.h"
#import "Status.h"
#import "weiboFetcher.h"

@interface HomepageTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *weiboArray;
@property (nonatomic) int page;

@end
