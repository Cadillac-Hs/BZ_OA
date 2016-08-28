//
//  OA_Tool.m
//  SchoolHelper
//
//  Created by ShenQiang on 16/8/5.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "OA_Tool.h"
#import "MJExtension.h"
#import "BZ_pch.h"
@implementation OA_Tool

-(OAAccountInfo *)getTA_Dic
{
    NSData *outputData = [USERDEFAULTS objectForKey:@"OAaccountInfo"];
    NSDictionary *outputDict = [NSKeyedUnarchiver unarchiveObjectWithData:outputData];
//    NSLog(@"OA保存的字典 == %@", outputDict);
    
    if (outputDict) {
        OAAccountInfo * accountInfo = [OAAccountInfo mj_objectWithKeyValues:outputDict];
        
        return accountInfo;
    }
    return nil;
}

+ (NSString *)userType{
    
    OA_Tool *tool = [[OA_Tool alloc] init];
    OAAccountInfo *info = [tool getTA_Dic];
    
    return info.userType;
}

+ (NSString *)userId{
    
    OA_Tool *tool = [[OA_Tool alloc] init];
    OAAccountInfo *info = [tool getTA_Dic];
    
    return info.userId;
}

+ (NSString *)token{
    
    OA_Tool *tool = [[OA_Tool alloc] init];
    OAAccountInfo *info = [tool getTA_Dic];
    
    return info.token;
}

+ (NSString *)userName{
    
    OA_Tool *tool = [[OA_Tool alloc] init];
    OAAccountInfo *info = [tool getTA_Dic];
    
    return info.userName;
}

+(void)delegateOA_Path{
 
    [USERDEFAULTS removeObjectForKey:@"OAaccountInfo"];
}

@end
