//
//  Tool.m
//  BZ_OA
//
//  Created by ShenQiang on 16/8/10.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "Tool.h"

@implementation Tool


+ (UIColor *)getColor:(NSString *)hexColor
{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    //    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:>red];
    //
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}

+ (NSNumber *)currentTimestampWithLongLongFormat
{
    double timeStamp = ceil([[NSDate date] timeIntervalSince1970] * 1000);
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGeneratesDecimalNumbers:false];
    NSNumber *timeNumber = [NSNumber numberWithDouble:timeStamp];
    NSString *timeString = [formatter stringFromNumber:timeNumber];
    
    // NSTimeInterval is defined as double
    return [NSNumber numberWithLongLong:[timeString longLongValue]];
}

@end
