//
//  NSString+Tools.h
//  TeachingAssistant
//
//  Created by 陈林 on 16/7/4.
//  Copyright © 2016年 Chen Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tools)

- (NSString *)convertFromHtmlString;

// 获取NSDate数据的实时时间文本
+ (NSString *)getDateString:(NSDate *)date;

@end
