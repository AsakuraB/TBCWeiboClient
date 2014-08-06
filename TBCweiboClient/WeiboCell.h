//
//  WeiboCell.h
//  TBCweiboClient
//
//  Created by Lee Larry on 8/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "Comment.h"
#import "TQRichTextView.h"


@interface WeiboCell : UITableViewCell <TQRichTextViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *repostButton;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (nonatomic) IBOutlet NSString *cellHeight;

- (void)setupWeiboCell:(Status *) status;
- (void)setupCommentCell:(Comment *) comment;

@end
