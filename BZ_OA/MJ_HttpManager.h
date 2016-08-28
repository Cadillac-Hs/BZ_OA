//
//  MJ_HttpManager.h
//  SchoolHelper
//
//  Created by ShenQiang on 16/8/4.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<AFNetworking/AFNetworking.h>
typedef void (^ResultBlock)(NSArray * result,NSError * error);

@interface MJ_HttpManager : NSObject

+(NSString *)loginBaseUrl;


#pragma mark - 单例类
/**
 *  单例类
 */

+(instancetype)getSingleClass;

@property (nonatomic, strong)AFHTTPRequestOperationManager *shareClient;
@property (nonatomic, strong) AFHTTPRequestOperationManager *cleanClient;

#pragma mark - 网络请求方法

#pragma mark 1.登录方法(老师)

/**
 *  账号登录协议 - 老师
 */

-(void)loginAuthorizationWithTeacherParameters:(NSDictionary *)dict resultBlock:(void (^)(int isSuccess,NSString * message,NSError * error))resultBlock;


/**
 *  账号登录协议 - 老师 - 手机验证登录- 获取验证码
 */

-(void)loginAuthorizationWithTeacherGetPhoneCodeParameters:(NSDictionary *)dict resultBlock:(void (^)(int isSuccess,NSString * message, NSError * error))resultBlock;

/**
 *  账号登录协议 - 老师 - 手机验证登录-- 登录协议
 */

-(void)loginAuthorizationWithTeacherPhoneLoginParameters:(NSDictionary *)dict resultBlock:(void (^)(int isSuccess,NSString * message,NSDictionary * dic,  NSError * error))resultBlock;


#pragma mark 2.登录方法(学生)

/**
 *  账号登录协议 - 学生
 */

-(void)loginAuthorizationWithStudentParameters:(NSDictionary *)dict resultBlock:(void (^)(int isSuccess,NSString * message,NSDictionary * dic ,NSError * error))resultBlock;

#pragma mark - 私钥登录
/**
 *  私钥登录 --- 教师端的私钥登录 (学生没有,直接用的是保存本地)
 */
-(void)loginPrivateKeyWithParameters:(NSDictionary *)dict resultBlock:(void (^)(int proResult,NSString * message,NSError * error))resultBlock;

#pragma mark - 退出登录
/**
 *  退出登录的时候,教师端登录时退出时请求,学生端不需要请求
 */
-(void)loginOutWithParameters:(NSDictionary *)dict resultBlock:(void (^)(int proResult,NSString * message , NSError * error))resultBlock;

/**
 *  监听后台  消息
 *
 *  @param urlStr
 *  @param userid
 *  @param block
 */

-(void)OANotificationWithUrl:(NSString *)urlStr andParameter:(NSDictionary *)dict resultBlock:(void (^)(NSString *resultString, NSError *error))block;

@end
