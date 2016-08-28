//
//  OA_Tool.h
//  SchoolHelper
//
//  Created by ShenQiang on 16/8/5.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAAccountInfo.h"
@interface OA_Tool : NSObject

-(OAAccountInfo *)getTA_Dic;

+ (NSString *)userType;

+ (NSString *)userId;

+ (NSString *)token;

+ (NSString *)userName;

+(void)delegateOA_Path;

@end
