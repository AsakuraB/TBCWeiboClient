//
//  RePostWeiboViewController.m
//  TBCweiboClient
//
//  Created by Lee Larry on 28/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "RePostWeiboViewController.h"
#import "weiboFetcher.h"

@interface RePostWeiboViewController () <UITextViewDelegate, WBHttpRequestDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *repostContextTextView;
@property (strong, nonatomic) IBOutlet UILabel *attentionLabel;
@property (strong, nonatomic) IBOutlet UILabel *textCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *repostWeiboButton;
@property (nonatomic) NSString *weiboID;
@end

@implementation RePostWeiboViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.repostContextTextView.text = self.repostContext;
    if (self.repostContext) {
        self.repostWeiboButton.enabled = YES;
        self.attentionLabel.hidden = YES;
    } else {
        self.repostWeiboButton.enabled = NO;
        self.attentionLabel.hidden = NO;
    }
    self.weiboID = [NSString stringWithFormat:@"%lld", self.statusID];
    NSString *yuanWeiboContext = self.yuanWeibo;
    CGSize constraint = CGSizeMake(280, MAXFLOAT);
    CGSize size = [yuanWeiboContext sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *yuanWeiboLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 306, 280, size.height)];
    yuanWeiboLabel.text = yuanWeiboContext;
    yuanWeiboLabel.font = [UIFont systemFontOfSize:12.0f];
    yuanWeiboLabel.numberOfLines = 0;
    yuanWeiboLabel.lineBreakMode = NSLineBreakByWordWrapping;
    yuanWeiboLabel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.view addSubview:yuanWeiboLabel];
    
    //直接让textview进入到编辑状态，并把光标移动到最开始
    [self.repostContextTextView becomeFirstResponder];
    NSRange range = NSMakeRange(0, 0);
    self.repostContextTextView.selectedRange = range;
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (int)getToInt:(NSString *)string
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [string dataUsingEncoding:enc];
    int x = ceil((double)[data length]/2);
    return x;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        self.attentionLabel.hidden = NO;
    } else {
        self.attentionLabel.hidden = YES;
    }
    NSString *content = [[NSString alloc] initWithString:textView.text];
    NSInteger contentLength = [self getToInt:content];
    NSInteger remainingCharactersLength = 140-contentLength;
    if (remainingCharactersLength < 0) {
        self.textCountLabel.textColor = [UIColor redColor];
        self.repostWeiboButton.enabled = NO;
    } else {
        if (remainingCharactersLength == 140) {
            self.repostWeiboButton.enabled = NO;
        } else {
            self.repostWeiboButton.enabled = YES;
        }
        self.textCountLabel.textColor = [UIColor blackColor];
    }
    self.textCountLabel.text = [NSString stringWithFormat:@"%d", remainingCharactersLength];

}

- (void)repostWeibo:(NSString *)text
{
    NSString *repostWeiboID = [NSString stringWithFormat:@"%lld", self.statusID];
    
    NSMutableDictionary *weibo = [NSMutableDictionary dictionaryWithCapacity:5];
    [weibo setObject:repostWeiboID forKey:@"id"];
    [weibo setObject:text forKey:@"status"];

    [WBHttpRequest requestWithAccessToken:[weiboFetcher returnAccessTokenString]
                                      url:WEIBO_REPOST_STATUSES
                               httpMethod:@"POST"
                                   params:weibo
                                 delegate:self
                                  withTag:@"1"];
    
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"转发微博"
                                                    message:@"转发微博成功"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"好的！", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancelButton];
}

- (IBAction)cancelButton
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)repostButton
{
    [self repostWeibo:self.repostContextTextView.text];
}

@end
