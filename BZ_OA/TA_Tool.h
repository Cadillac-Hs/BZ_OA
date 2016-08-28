//
//  TA_Tool.h
//  SchoolHelper
//
//  Created by ShenQiang on 16/7/29.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TAAccountInfo.h"
@interface TA_Tool : NSObject

-(TAAccountInfo *)getTA_Dic;

+ (int)userType;

+ (NSString *)userId;

+(void)delegateTA_Path;

@end
