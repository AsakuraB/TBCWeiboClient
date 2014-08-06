//
//  TQRichTextRunTopic.m
//  TQRichTextViewDemo
//
//  Created by Lee Larry on 31/7/14.
//  Copyright (c) 2014年 fuqiang. All rights reserved.
//

#import "TQRichTextRunTopic.h"

@implementation TQRichTextRunTopic

/**
 *  向字符串中添加相关Run类型属性
 */
- (void)decorateToAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    [super decorateToAttributedString:attributedString range:range];
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:range];
}

/**
 *  解析字符串中url内容生成Run对象
 *
 *  @param attributedString 内容
 *
 *  @return TQRichTextRunURL对象数组
 */
+ (NSArray *)runsForAttributedString:(NSMutableAttributedString *)attributedString
{
    NSString *string = attributedString.string;
    NSMutableArray *array = [NSMutableArray array];
    
    NSError *error = nil;;
    NSString *regulaStr = @"#([^\\#|.]+)#";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error == nil)
    {
        NSArray *arrayOfAllMatches = [regex matchesInString:string
                                                    options:0
                                                      range:NSMakeRange(0, [string length])];
        
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
            NSString* substringForMatch = [string substringWithRange:match.range];
            
            TQRichTextRunTopic *run = [[TQRichTextRunTopic alloc] init];
            run.range    = match.range;
            run.text     = substringForMatch;
            run.drawSelf = NO;
            [run decorateToAttributedString:attributedString range:match.range];
            [array addObject:run ];
        }
    }
    
    return array;
}

@end
