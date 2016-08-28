//
//  NSString+Tools.m
//  TeachingAssistant
//
//  Created by 陈林 on 16/7/4.
//  Copyright © 2016年 Chen Lin. All rights reserved.
//

#import "NSString+Tools.h"
#import <UIKit/UIKit.h>
#import "NSDate+MJ.h"

@implementation NSString (Tools)

- (NSString *)convertFromHtmlString {
    
//    NSError *err = nil;
//    
//    NSAttributedString *attString = [[NSAttributedString alloc] initWithData:[self dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:&err];
//    
//
//    if(err) {
//        NSLog(@"Unable to parse label text: %@", err);
//        return nil;
//    }
//
//    return [NSString stringWithFormat:@"%@", attString];
    
    NSString *html = self;

    html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"</p>"] withString:@"</p>\n"];

    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    
    
    while ([theScanner isAtEnd] == NO) {
        
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}


// 获取NSDate数据的实时时间文本
+ (NSString *)getDateString:(NSDate *)date
{
    // Tue Mar 10 17:32:22 +0800 2015
    // 字符串转换NSDate
    //    _created_at = @"Tue Mar 11 17:48:24 +0800 2015";
    
    NSString *_created_at;
    // 日期格式字符串
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEE MMM d HH:mm:ss Z yyyy";
    
    // 设置格式本地化,日期格式字符串需要知道是哪个国家的日期，才知道怎么转换
    fmt.locale = [NSLocale localeWithLocaleIdentifier:@"en_us"];
    
    if ([date isThisYear]) { // 今年
        
        if ([date isToday]) { // 今天
            
            // 计算跟当前时间差距
            NSDateComponents *cmp = [date deltaWithNow];
            
            if (cmp.hour >= 1) {
                return [NSString stringWithFormat:NSLocalizedString(@"%ld小时之前", nil),cmp.hour];
            }else if (cmp.minute > 1){
                return [NSString stringWithFormat:NSLocalizedString(@"%ld分钟之前", nil),cmp.minute];
            }else{
                return NSLocalizedString(@"刚刚", nil);
            }
            
        }else if ([date isYesterday]){ // 昨天
            fmt.dateFormat = NSLocalizedString(@"昨天 HH:mm", nil);
            return  [fmt stringFromDate:date];
            
        }else{ // 前天
            fmt.dateFormat = @"MM-dd HH:mm";
            return  [fmt stringFromDate:date];
        }
        
        
        
    }else{ // 不是今年
        
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        
        return [fmt stringFromDate:date];
        
    }
    
    return _created_at;
}


@end
