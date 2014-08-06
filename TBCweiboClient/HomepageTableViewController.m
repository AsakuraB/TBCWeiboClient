//
//  HomepageTableViewController.m
//  TBCweiboClient
//
//  Created by Lee Larry on 3/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "HomepageTableViewController.h"
#import "weiboFetcher.h"
#import "MJRefresh.h"
#import "RePostWeiboViewController.h"
#import "TQRichTextView.h"

@interface HomepageTableViewController () <TQRichTextViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSIndexPath *cellIndexPath;
@end

@implementation HomepageTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.page = 1;
    self.weiboArray = [[NSMutableArray alloc] init];
    [self setupRefresh];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sky.jpg"]];
    self.tableView.backgroundView = imageView;
}

#pragma mark - Refresh Stuff

- (void)setupRefresh
{
    [self.tableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.tableView headerBeginRefreshing];
    
    [self.tableView addFooterWithTarget:self action:@selector(footerRefreshing)];
}

- (void)headerRefreshing
{
    self.weiboArray = [[NSMutableArray alloc] init];
    self.page = 1;
    [self getWeiboData:self.page];
}

- (void)footerRefreshing
{
    [self getWeiboData:++self.page];
}


#pragma mark - Fetch Weibo Data

- (void)getWeiboData:(int)page
{
    NSURL *url = [NSURL URLWithString:[weiboFetcher returnHomeTimelineUrlString:page]];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("weibo fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        if (jsonResults == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"噢no！"
                                                            message:@"Cookie好像过期了，重新登录试试吧！"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"好吧！", nil];
            [alert show];
        } else {
        NSDictionary *weiboData = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                  options:0
                                                                    error:NULL];
        NSArray *weibo = [weiboData objectForKey:@"statuses"];
        for (NSDictionary *dictionary in weibo) {
            Status *sta = [[Status alloc] init];
            sta = [sta initWithJsonDictionary:dictionary];
            [self.weiboArray addObject:sta];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView headerEndRefreshing];
            [self.tableView footerEndRefreshing];
        });
        }
    });
}

//access_token如果过期，重新登录
//getWeiboData的alert的delegate是self，才会调用下面这个方法。评论alert的delegate是nil

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:@"Return Login" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.weiboArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Weibo Cell";
    
    WeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...    
    if (cell != nil) {
        [cell removeFromSuperview];
    }
    cell = [[WeiboCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    Status *status = [[Status alloc] init];
    //这句有可能会crash，原因未知
    status = [self.weiboArray objectAtIndex:indexPath.row];

    [cell setupWeiboCell:status];
        [cell.repostButton addTarget:self action:@selector(repostButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

/**
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
 */

//动态调整Cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Status *status = [[Status alloc] init];
    status = [self.weiboArray objectAtIndex:[indexPath row]];
    
    CGFloat yHeight;
    
    NSString *contentString = status.text;
    CGRect rect = [TQRichTextView boundingRectWithSize:CGSizeMake(290, 500) font:[UIFont systemFontOfSize:14.0f] string:contentString lineSpace:1.0f];
    
    yHeight += 80 + rect.size.height;
    
    Status *retweetStatus = status.retweetedStatus;
    
    if (status.hasRetwitter) {
        NSString *retweetWeiboText = [NSString stringWithFormat:@"@%@:%@", retweetStatus.user.screenName, retweetStatus.text];
        
        CGRect retweetRect = [TQRichTextView boundingRectWithSize:CGSizeMake(280, 500) font:[UIFont systemFontOfSize:12.0f] string:retweetWeiboText lineSpace:1.0f];
        
        yHeight += retweetRect.size.height + 15;

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
    //补差值
    yHeight += 30;
    
    return yHeight;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = self.cellIndexPath;
    
    if ([segue.identifier isEqualToString:@"Repost Weibo"]) {
        
        Status *status = [self.weiboArray objectAtIndex:[indexPath row]];
        RePostWeiboViewController *RPWVC = segue.destinationViewController;
        RPWVC.statusID = status.statuesID;
        if (status.hasRetwitter) {
            RPWVC.repostContext = [NSString stringWithFormat:@"//@%@:%@", status.user.screenName, status.text];
            RPWVC.yuanWeibo = [NSString stringWithFormat:@"@%@:%@", status.retweetedStatus.user.screenName, status.retweetedStatus.text];
        } else {
            RPWVC.repostContext = nil;
            RPWVC.yuanWeibo = [NSString stringWithFormat:@"@%@:%@", status.user.screenName, status.text];
        }
    }

}

#pragma mark - Cell Button Pressed

- (void)repostButtonPressed:(UIButton *)sender
{
    NSIndexPath *indexPath = nil;
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview.superview;
    indexPath = [self.tableView indexPathForCell:cell];
    self.cellIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"Repost Weibo" sender:self];
}

- (void)commentButtonPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh！"
                                                    message:@"这里跟转发差不多啦_(:з」∠)_，略。"
                                                   delegate:nil
                                          cancelButtonTitle:@"好吧我去试试转发！"
                                          otherButtonTitles:nil];
    [alert show];
}


@end
