//
//  Tool.h
//  BZ_OA
//
//  Created by ShenQiang on 16/8/10.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Tool : NSObject

//十六进制转换---可用的颜色
+ (UIColor *)getColor:(NSString *)hexColor;


+ (NSNumber *)currentTimestampWithLongLongFormat;

@end
