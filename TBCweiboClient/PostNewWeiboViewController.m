//
//  PostNewWeiboViewController.m
//  TBCweiboClient
//
//  Created by Lee Larry on 15/7/14.
//  Copyright (c) 2014年 OW.produced. All rights reserved.
//

#import "PostNewWeiboViewController.h"
#import "weiboFetcher.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface PostNewWeiboViewController () <UITextViewDelegate, WBHttpRequestDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *weiboTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) IBOutlet UILabel *textCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *attentionLabel;
@property (strong, nonatomic) IBOutlet UIButton *postWeiboButton;
@property (assign, nonatomic) BOOL hasPostImage;

@end

@implementation PostNewWeiboViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.postWeiboButton.enabled = NO;
    self.hasPostImage = NO;
    [self.weiboTextView becomeFirstResponder];
    
}

#pragma mark - TextViewStuff

//因为微博内容不需要回车，所以当按下键盘上回车键的时候，关闭键盘
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//统计微博字符长度（中文1字符，英文0.5字符）
- (int)getToInt:(NSString *)string
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [string dataUsingEncoding:enc];
    int x = ceil((double)[data length]/2);
    return x;
}

//当微博字段为空时，显示“分享新鲜事...”提示Label
//剩余字数提示，当超出140字时，不可点击发送按钮
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
        self.postWeiboButton.enabled = NO;
    } else {
        if (remainingCharactersLength == 140) {
            self.postWeiboButton.enabled = NO;
        } else {
            self.postWeiboButton.enabled = YES;
        }
        self.textCountLabel.textColor = [UIColor blackColor];
    }
    self.textCountLabel.text = [NSString stringWithFormat:@"%d", remainingCharactersLength];
}

#pragma mark - ImageViewStuff

//判断是否能添加图片
+ (BOOL)canAddPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - PostWeiboStuff

//发送文字微博
- (void)postOrdinaryWeibo:(NSString *)text
{
    NSMutableDictionary *weibo = [NSMutableDictionary dictionaryWithCapacity:5];
    
    [weibo setObject:text forKey:@"status"];
    
    [WBHttpRequest requestWithAccessToken:[weiboFetcher returnAccessTokenString]
                                      url:WEIBO_UPDATE_URL
                               httpMethod:@"POST"
                                   params:weibo
                                 delegate:self
                                  withTag:@"1"];
}

//发送图片微博
- (void)postImageWeibo:(NSString *)text image:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSMutableDictionary *imageWeibo = [NSMutableDictionary dictionaryWithCapacity:6];
    [imageWeibo setObject:text forKey:@"status"];
    [imageWeibo setObject:imageData forKey:@"pic"];
    
    [WBHttpRequest requestWithAccessToken:[weiboFetcher returnAccessTokenString]
                                      url:WEIBO_UPLOAD_URL
                               httpMethod:@"POST"
                                   params:imageWeibo
                                 delegate:self
                                  withTag:@"2"];
}

//发送完毕
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"微博"
                                                    message:@"微博发送成功"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"好的！", nil];
    [alert show];
}

//当发送完毕时，ViewController消失
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancelButtonItem];
}

#pragma mark - Button Pressed Stuff

- (IBAction)cancelButtonItem
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)postNewWeiboButtonItem
{
    UIImage *image = self.imageView.image;
    if (!self.hasPostImage) {
        [self postOrdinaryWeibo:self.weiboTextView.text];
    } else {
        [self postImageWeibo:self.weiboTextView.text image:image];
    }
}

- (IBAction)takePhotoButtonItem
{
    if ([[self class] canAddPhoto]) {
        UIImagePickerController *impc = [[UIImagePickerController alloc] init];
        impc.sourceType = UIImagePickerControllerSourceTypeCamera;
        impc.delegate = self;
        impc.mediaTypes = @[(NSString *)kUTTypeImage];
        impc.allowsEditing = YES;
        
        [self presentViewController:impc animated:YES completion:NULL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"照相"
                                                        message:@"该设备不能照相"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"好吧", nil];
        [alert show];
    }
}

- (IBAction)pickPhotoButtonItem
{
    UIImagePickerController *impc = [[UIImagePickerController alloc] init];
    impc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    impc.delegate = self;
    impc.mediaTypes = @[(NSString *)kUTTypeImage];
    impc.allowsEditing = NO;
    
    [self presentViewController:impc animated:YES completion:NULL];
}

#pragma mark - Image Picker Stuff

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
  //self.image = image;
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.hasPostImage = YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
