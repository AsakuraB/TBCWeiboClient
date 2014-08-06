//
//  WeiboCell.m
//  TBCweiboClient
//
//  Created by Lee Larry on 8/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "WeiboCell.h"
#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "HomepageTableViewController.h"

@interface WeiboCell () 
@property (nonatomic, strong) NSArray *picUrlsArray;
@end


@implementation WeiboCell

- (NSString *)getTimeString:(NSString *)string
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *inputDate = [inputFormatter dateFromString:string];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"MMM-dd HH:mm"];
    NSString *outputDate = [outputFormatter stringFromDate:inputDate];
    
    return outputDate;
}

- (NSString *)getCountString:(int)x;
{
    NSString *countString;
    if (x == 0) {
        countString = @"";
    } else if (x >0 && x < 1000) {
        countString = [NSString stringWithFormat:@"%d", x];
    } else if (x >= 1000 && x < 10000) {
        int a = x / 1000;
        countString = [NSString stringWithFormat:@"%d千+", a];
    } else if (x >= 10000) {
        int b = x / 10000;
        countString = [NSString stringWithFormat:@"%d万+", b];
    }
    return countString;
}

- (UIImage *)getImageFromURL:(NSString *)imageURL
{
    NSURL *fileURL = [NSURL URLWithString:imageURL];
    NSData *fileData = [[NSData alloc] initWithContentsOfURL:fileURL];
    UIImage *resultImage = [[UIImage alloc] initWithData:fileData];
    return resultImage;
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    int count = self.picUrlsArray.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        //替换原始图片
        NSString *url = [self.picUrlsArray[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
        
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url];
        [photos addObject:photo];
    }
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag;
    browser.photos = photos;
    [browser show];
}

- (void)setupWeiboCell:(Status *)status
{
    //头像异步下载
    __block UIImageView *profilePhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("profile image", NULL);
    dispatch_async(fetchQ, ^{
        UIImage *image = [self getImageFromURL:status.user.profileImageUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            profilePhotoView.image = image;
            [self.contentView addSubview:profilePhotoView];
        });
    });
    CALayer *profilePhotoLayer = [profilePhotoView layer];
    profilePhotoLayer.masksToBounds = YES;
    profilePhotoLayer.cornerRadius = 6.0;
    profilePhotoLayer.borderWidth = 2.0;
    profilePhotoLayer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.8].CGColor;
    
   //用户名
    UILabel *screenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, 235, 25)];
    screenNameLabel.text = status.user.screenName;
    screenNameLabel.textColor = [UIColor colorWithRed:21/255.0 green:29/255.0 blue:71/255.0 alpha:1.0];
    screenNameLabel.font = [UIFont systemFontOfSize:17.0f];
    screenNameLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:screenNameLabel];
    
    //微博时间和来源
    NSString *sourcestring = [self getTimeString:status.createdAt];
    UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 45, 235, 15)];
    sourceLabel.text = [NSString stringWithFormat:@"%@ 来自%@", sourcestring, status.source];
    sourceLabel.textColor = [UIColor colorWithRed:75/255.0 green:79/255.0 blue:96/255.0 alpha:1.0];
    sourceLabel.font = [UIFont systemFontOfSize:12.0f];
    sourceLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:sourceLabel];
    
    //微博内容
    NSString *retweetText = status.text;
    CGRect rect = [TQRichTextView boundingRectWithSize:CGSizeMake(290, 500) font:[UIFont systemFontOfSize:14.0f] string:retweetText lineSpace:1.0f];
    
    TQRichTextView *contentTextView = [[TQRichTextView alloc] initWithFrame:CGRectMake(15, 75, rect.size.width, rect.size.height)];
    
    contentTextView.text = retweetText;
    contentTextView.lineSpace = 1.0f;
    contentTextView.font = [UIFont systemFontOfSize:14.0f];
    contentTextView.backgroundColor = [UIColor clearColor];
    contentTextView.delegage = self;
    
    [self.contentView addSubview:contentTextView];
    
    //高度设定
    CGFloat yHeight = contentTextView.frame.origin.y + contentTextView.frame.size.height + 5;
    CGFloat yStartHeight = yHeight;
    
    //转发情况
    Status *repostStatus = status.retweetedStatus;
    
    if (repostStatus.wasDeleted) {
        NSString *deletedText = repostStatus.text;
        
        CGRect deletedRect = [TQRichTextView boundingRectWithSize:CGSizeMake(280, 500) font:[UIFont systemFontOfSize:12.0f] string:deletedText lineSpace:1.0f];
        
        TQRichTextView *deletedTextView = [[TQRichTextView alloc] initWithFrame:CGRectMake(20, yHeight+5, deletedRect.size.width, deletedRect.size.height)];
        
        deletedTextView.text = deletedText;
        deletedTextView.lineSpace = 1.0f;
        deletedTextView.font = [UIFont systemFontOfSize:12.0f];
        deletedTextView.backgroundColor = [UIColor clearColor];
        deletedTextView.delegage = self;
        
        [self.contentView addSubview:deletedTextView];

        UILabel *deletedTextBGL = [[UILabel alloc] initWithFrame:CGRectMake(15, yHeight, 290, deletedTextView.frame.size.height+20)];
        deletedTextBGL.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        CALayer *dtbglLayer = [deletedTextBGL layer];
        dtbglLayer.masksToBounds = YES;
        dtbglLayer.cornerRadius = 10;
        [self.contentView addSubview:deletedTextBGL];
        [self.contentView sendSubviewToBack:deletedTextBGL];
        
        yHeight += deletedTextView.frame.size.height +10;
        
    } else {
        if (status.hasRetwitter) {
            //转发的文本
            NSString *retweetText = [NSString stringWithFormat:@"@%@:%@", repostStatus.user.screenName, repostStatus.text];
            
            CGRect retweetRect = [TQRichTextView boundingRectWithSize:CGSizeMake(280, 500) font:[UIFont systemFontOfSize:12.0f] string:retweetText lineSpace:1.0f];
            
            TQRichTextView *retweetTextView = [[TQRichTextView alloc] initWithFrame:CGRectMake(20, yHeight+5, 280, retweetRect.size.height)];
            
            retweetTextView.text = retweetText;
            retweetTextView.lineSpace = 1.0f;
            retweetTextView.font = [UIFont systemFontOfSize:12.0f];
            retweetTextView.backgroundColor = [UIColor clearColor];
            retweetTextView.delegage = self;
            
            [self.contentView addSubview:retweetTextView];

            yHeight += retweetTextView.frame.size.height + 10;
            
            if (status.hasRetwitterImage) {
                //准备图片链接
                int x = status.retweetedStatus.picUrls.count;
                NSMutableArray *picUrls = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < x; i++) {
                    NSDictionary *imageUrlDic = [status.retweetedStatus.picUrls objectAtIndex:i];
                    NSString *imageUrlString = [imageUrlDic objectForKey:@"thumbnail_pic"];
                    [picUrls addObject:imageUrlString];
                }
                self.picUrlsArray = picUrls;
                
                //创建imageview
                UIImage *placeholder = [UIImage imageNamed:@"timeline_image_loading.png"];
                CGFloat width = 90;
                CGFloat height = 90;
                CGFloat margin = 20;
                CGFloat interval = 5;
                //CGFloat startX = margin;
                //CGFloat startY = yHeight;
                
                for (int j = 0; j < x; j++) {
                    //计算位置
                    int row = j/3;
                    int column = j%3;
                    
                    UIImageView *imageView = [[UIImageView alloc] init];
                    [self.contentView addSubview:imageView];
                    
                    CGFloat x = margin + column * (width + interval);
                    CGFloat y = yHeight + row * (height + interval);
                    imageView.frame = CGRectMake(x, y, width, height);
                    

                    //下载图片
                    [imageView setImageURLStr:picUrls[j] placeholder:placeholder];
                    
                    imageView.tag = j;
                    imageView.userInteractionEnabled = YES;
                    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                    
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                }
                
                if (x >= 1) {
                    yHeight += 100;
                }
                if (x >= 4) {
                    yHeight += 95;
                }
                if (x >= 7) {
                    yHeight += 95;
                }
            }
            
            //转发背景图
            UILabel *repostBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, yStartHeight, 290, yHeight-yStartHeight-5)];
            repostBackgroundLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
            CALayer *rblLayer = [repostBackgroundLabel layer];
            rblLayer.masksToBounds = YES;
            rblLayer.cornerRadius = 10;
            [self.contentView addSubview:repostBackgroundLabel];
            [self.contentView sendSubviewToBack:repostBackgroundLabel];
            yHeight += 5;
        }
        else if (status.hasImage) {
                int x = status.picUrls.count;
                NSMutableArray *picUrls1 = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < x; i++) {
                    NSDictionary *imageUrlDic1 = [status.picUrls objectAtIndex:i];
                    NSString *imageUrlString1 = [imageUrlDic1 objectForKey:@"thumbnail_pic"];
                    [picUrls1 addObject:imageUrlString1];
                }
                self.picUrlsArray = picUrls1;
                
                UIImage *placeholder = [UIImage imageNamed:@"timeline_image_loading.png"];
                CGFloat width = 90;
                CGFloat height = 90;
                CGFloat margin = 20;
                CGFloat interval = 5;
                
                for (int j = 0; j < x; j++) {
                    int row = j/3;
                    int column = j%3;
                    
                    UIImageView *imageView = [[UIImageView alloc] init];
                    [self.contentView addSubview:imageView];
                    
                    CGFloat x = margin + column * (width + interval);
                    CGFloat y = yHeight + row * (height + interval);
                    imageView.frame = CGRectMake(x, y, width, height);
                    
                    [imageView setImageURLStr:picUrls1[j] placeholder:placeholder];
                    
                    imageView.tag = j;
                    imageView.userInteractionEnabled = YES;
                    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                    
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                }
                
                if (x >= 1) {
                    yHeight += 100;
                }
                if (x >= 4) {
                    yHeight += 95;
                }
                if (x >= 7) {
                    yHeight += 95;
                }
            }
    }
    
    
    
    //最下面2个按钮
    self.repostButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.repostButton.frame = CGRectMake(10, yHeight, 150, 30);
    NSString *repostCountString = [self getCountString:status.repostsCount];
    [self.repostButton setTitle:[NSString stringWithFormat:@"%@转发", repostCountString] forState:UIControlStateNormal];
    self.repostButton.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.repostButton];
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.commentButton.frame = CGRectMake(160, yHeight, 150, 30);
    NSString *commentCountString = [self getCountString:status.commentsCount];
    [self.commentButton setTitle:[NSString stringWithFormat:@"%@评论", commentCountString] forState:UIControlStateNormal];
    self.commentButton.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.commentButton];
    
    //按钮横线+竖线
    UILabel *horizontalLine = [[UILabel alloc] initWithFrame:CGRectMake(15, yHeight, 290, 2)];
    horizontalLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    UILabel *verticalLine = [[UILabel alloc] initWithFrame:CGRectMake(159, yHeight+2, 2, 28)];
    verticalLine.backgroundColor =[UIColor colorWithWhite:1.0 alpha:0.4];
    [self.contentView addSubview:horizontalLine];
    [self.contentView addSubview:verticalLine];
    
    yHeight += 25;
    
    //cell背景图
    UILabel *cellBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 310, yHeight)];
    cellBackgroundLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    CALayer *cellBGLayer = [cellBackgroundLabel layer];
    cellBGLayer.masksToBounds = YES;
    cellBGLayer.cornerRadius = 10;
    [self.contentView addSubview:cellBackgroundLabel];
    [self.contentView sendSubviewToBack:cellBackgroundLabel];
    
    self.cellHeight = [NSString stringWithFormat:@"%f", yHeight];
}


- (void)setupCommentCell:(Comment *)comment
{
    //头像异步下载
    __block UIImageView *profilePhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("profile image", NULL);
    dispatch_async(fetchQ, ^{
        UIImage *image = [self getImageFromURL:comment.commentUser.profileImageUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            profilePhotoView.image = image;
            [self.contentView addSubview:profilePhotoView];
        });
    });
    CALayer *layer = [profilePhotoView layer];
    layer.masksToBounds = YES;
    layer.cornerRadius = 6.0;
    
    //用户名
    UILabel *screenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 25)];
    screenNameLabel.text = comment.commentUser.screenName;
    screenNameLabel.font = [UIFont systemFontOfSize:17.0f];
    screenNameLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:screenNameLabel];
    
    //评论时间和来源
    NSString *sourcestring = [self getTimeString:comment.createdAt];
    UILabel *sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 45, 240, 15)];
    sourceLabel.text = [NSString stringWithFormat:@"%@ 来自%@", sourcestring, comment.source];
    sourceLabel.textColor = [UIColor grayColor];
    sourceLabel.font = [UIFont systemFontOfSize:12.0f];
    sourceLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:sourceLabel];
    
    //评论内容
    UILabel *weiboTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    weiboTextLabel.font = [UIFont systemFontOfSize:14.0f];
    weiboTextLabel.numberOfLines = 0;
    weiboTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.contentView addSubview:weiboTextLabel];
    
    CGSize constraint = CGSizeMake(300, MAXFLOAT);
    CGSize size = [comment.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    weiboTextLabel.text = comment.text;
    weiboTextLabel.frame = CGRectMake(10, 70, size.width, size.height);
    
    //高度设定
    CGFloat yHeight = weiboTextLabel.frame.origin.y + weiboTextLabel.frame.size.height +10;
    
    //评论的微博内容
    Status *commentStatus = comment.commentedStatus;
    
    NSString *commentedStatusText = [NSString stringWithFormat:@"@%@:%@", commentStatus.user.screenName, commentStatus.text];
    CGSize constraint1 = CGSizeMake(300, MAXFLOAT);
    CGSize size1 = [commentedStatusText sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *commentedStatusTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yHeight, 300, size1.height)];
    commentedStatusTextLabel.text = commentedStatusText;
    commentedStatusTextLabel.font = [UIFont systemFontOfSize:12.0f];
    commentedStatusTextLabel.numberOfLines = 0;
    commentedStatusTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    commentedStatusTextLabel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.contentView addSubview:commentedStatusTextLabel];
    
    yHeight += commentedStatusTextLabel.frame.size.height + 10;
    
}

@end










































