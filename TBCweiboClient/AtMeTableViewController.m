//
//  AtMeTableViewController.m
//  TBCweiboClient
//
//  Created by Lee Larry on 20/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "AtMeTableViewController.h"
#import "MJRefresh.h"
#import "RePostWeiboViewController.h"
#import "weiboFetcher.h"

@interface AtMeTableViewController () 
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSIndexPath *cellIndexPath;

@end

@implementation AtMeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.atMeWeiboArray = [[NSMutableArray alloc] init];
    self.weiboPage = 1;
    self.atMeCommentArray = [[NSMutableArray alloc] init];
    self.commentPage = 1;
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(headerRefreshing) forControlEvents:UIControlEventValueChanged];
    [self setupRefresh];
}

- (void)setupRefresh
{
    [self.tableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.tableView headerBeginRefreshing];
    [self.tableView addFooterWithTarget:self action:@selector(footerRefreshing)];
}

- (void)headerRefreshing
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.atMeWeiboArray = [[NSMutableArray alloc] init];
        self.weiboPage = 1;
        [self getAtMeWeiboData:self.weiboPage];
    } else {
        self.atMeCommentArray = [[NSMutableArray alloc] init];
        self.commentPage = 1;
        [self getAtMeCommentData:self.commentPage];
    }
}

- (void)footerRefreshing
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self getAtMeWeiboData:++self.weiboPage];
    } else {
        [self getAtMeCommentData:++self.commentPage];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch Data

- (void)getAtMeWeiboData:(int)page
{
    NSURL *url = [NSURL URLWithString:[weiboFetcher returnAtMeWeiboUrlString:page]];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("at me weibo fetcher", NULL);
    dispatch_async(fetchQ, ^{
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data == nil)
    {
        NSLog(@"获取数据失败");
    } else
    {
        NSDictionary *atMeWeiboData = [NSJSONSerialization JSONObjectWithData:data
                                                            options:0
                                                              error:NULL];
        NSArray *atMeWeiboArray = [atMeWeiboData objectForKey:@"statuses"];
        for (NSDictionary *dictionary in atMeWeiboArray) {
            Status *sta = [[Status alloc] init];
            sta = [sta initWithJsonDictionary:dictionary];
            [self.atMeWeiboArray addObject:sta];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView headerEndRefreshing];
            [self.tableView footerEndRefreshing];
        });
        }
    });
}

- (void)getAtMeCommentData:(int)page
{
    NSURL *url = [NSURL URLWithString:[weiboFetcher returnAtMeCommentUrlString:page]];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("at me comment fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data == nil)
        {
            NSLog(@"获取数据失败");
        } else
        {
            NSDictionary *atMeCommentData = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:NULL];
            NSArray *atMeCommentArray = [atMeCommentData objectForKey:@"comments"];
            for (NSDictionary *dictionary in atMeCommentArray) {
                Comment *com = [[Comment alloc] init];
                com = [com initWithJsonDictionary:dictionary];
                [self.atMeCommentArray addObject:com];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView headerEndRefreshing];
                [self.tableView footerEndRefreshing];
            });
        }
    });

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return [self.atMeWeiboArray count];
    } else {
        return [self.atMeCommentArray count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"At Me Weibo Cell";
    
    WeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell != nil) {
        [cell removeFromSuperview];
    }
    cell = [[WeiboCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
    
        Status *status = [[Status alloc] init];
        status = [self.atMeWeiboArray objectAtIndex:[indexPath row]];

        [cell setupWeiboCell:status];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        
        Comment *comment = [[Comment alloc] init];
        comment = [self.atMeCommentArray objectAtIndex:[indexPath row]];
        
        [cell setupCommentCell:comment];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {

        Status *status = [[Status alloc] init];
        status = [self.atMeWeiboArray objectAtIndex:[indexPath row]];
        
        CGFloat yHeight = 70.0;
        
        CGSize constraint = CGSizeMake(300, MAXFLOAT);
        CGSize sizeOne = [status.text sizeWithFont:[UIFont systemFontOfSize:14.0f]
                                 constrainedToSize:constraint
                                     lineBreakMode:NSLineBreakByWordWrapping];
        yHeight += (sizeOne.height + 10.0);
        
        Status *retweetStatus = status.retweetedStatus;
        
        if (retweetStatus.wasDeleted) {
            NSString *deletedWeiboText = [NSString stringWithFormat:@"%@", retweetStatus.text];
            CGSize textSize = CGSizeMake(300, MAXFLOAT);
            CGSize sizeTwo = [deletedWeiboText sizeWithFont:[UIFont systemFontOfSize:12.0f]
                                          constrainedToSize:textSize
                                              lineBreakMode:NSLineBreakByWordWrapping];
            yHeight +=(sizeTwo.height + 10.0);

        } else {
            if (status.hasRetwitter) {
                NSString *retweetWeiboText = [NSString stringWithFormat:@"@%@:%@", retweetStatus.user.screenName, retweetStatus.text];
                CGSize textSize = CGSizeMake(300, MAXFLOAT);
                CGSize sizeTwo = [retweetWeiboText sizeWithFont:[UIFont systemFontOfSize:12.0f]
                                              constrainedToSize:textSize
                                                  lineBreakMode:NSLineBreakByWordWrapping];
                yHeight += (sizeTwo.height + 10.0);
                if (status.hasRetwitterImage) {
                    int x = status.retweetedStatus.picUrls.count;
                    if (x >= 1 && x <= 3) {
                        yHeight += 95+10;
                    }
                    if (x >= 4 && x <= 6) {
                        yHeight += 190+10;
                    }
                    if (x >= 7 && x <= 9) {
                        yHeight += 285+10;
                    }
                }
                
            } else {
                if (status.hasImage) {
                    int x = status.picUrls.count;
                    if (x >= 1 && x <= 3) {
                        yHeight += 100;
                    }
                    if (x >= 4 && x <= 6) {
                        yHeight += 195;
                    }
                    if (x >= 7 && x <= 9) {
                        yHeight += 290;
                    }
                }
            }
            yHeight += 30;
        }
        return yHeight;
    } else {
        
        Comment *comment = [[Comment alloc] init];
        comment = [self.atMeCommentArray objectAtIndex:[indexPath row]];
        
        CGFloat yHeight = 70.0;
        
        CGSize constraint = CGSizeMake(300, MAXFLOAT);
        CGSize size = [comment.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        yHeight += (size.height + 10.0);
        
        Status *commentStatus = comment.commentedStatus;
        
        NSString *commentedStatusText = [NSString stringWithFormat:@"@%@:%@", commentStatus.user.screenName, commentStatus.text];
        CGSize constraint1 = CGSizeMake(300, MAXFLOAT);
        CGSize size1 = [commentedStatusText sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
        yHeight += (size1.height + 10.0);
        
        return yHeight;
    }
}

@end























