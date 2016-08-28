//
//  TA_Tool.m
//  SchoolHelper
//
//  Created by ShenQiang on 16/7/29.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "TA_Tool.h"
#import "OA_Tool.h"
#import "MJExtension.h"

#import "OAAccountInfo.h"
#import "BZ_pch.h"
@implementation TA_Tool


- (TAAccountInfo *)getTA_Dic
{
    NSData *outputData = [USERDEFAULTS objectForKey:@"TAaccountInfo"];
    NSDictionary *outputDict = [NSKeyedUnarchiver unarchiveObjectWithData:outputData];
//    NSLog(@"OUTPUTDICK == %@", outputDict);
    
    if (outputDict) {
        TAAccountInfo * accountInfo = [TAAccountInfo mj_objectWithKeyValues:outputDict];
        
        return accountInfo;
    }
    
    return nil;
}

+ (int)userType {
    
    TA_Tool *tool = [[TA_Tool alloc] init];
    TAAccountInfo *info = [tool getTA_Dic];
    
    return [info.UserType intValue];
}

+ (NSString *)userId {
    
    TA_Tool *tool = [[TA_Tool alloc] init];
    TAAccountInfo *info = [tool getTA_Dic];
    
    if (info.UserType.intValue == 1) { // 学生
        
        return [NSString stringWithFormat:@"%d", [info.UserId intValue]];

    } else  if (info.UserType.intValue == 2) { // 老师
        
        NSString *userName = [OA_Tool userName];//老师登录把 需要的userName 传给 陈林
        return userName;
        
    }
    
    return nil;
    
}

+(void)delegateTA_Path
{
    [USERDEFAULTS removeObjectForKey:@"TAaccountInfo"];
}
//
//+ (NSString *)userName {
//    
//    TA_Tool *tool = [[TA_Tool alloc] init];
//    TAAccountInfo *info = [tool getTA_Dic];
//    
//    if (!info.Name) {
//        
//        info.Name = [USERDEFAULTS objectForKey:@"account"];
//        
//    }
//    
//    
//    return info.Name ;
//}
//
//+(NSString *)account
//{
//   return  [USERDEFAULTS objectForKey:@"account"];
//}

@end
