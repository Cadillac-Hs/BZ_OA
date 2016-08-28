//
//  MJ_HttpManager.m
//  SchoolHelper
//
//  Created by ShenQiang on 16/8/4.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "MJ_HttpManager.h"
#import <MJExtension/MJExtension.h>
//数据模型
//#import "LoginModel.h"
#import "TAAccountInfo.h"
#import "OAAccountInfo.h"

#import "BZ_pch.h"


////基础的url
#define LOGINBASEURL @"http://192.168.0.154/gz_ssos/IMobileLoginHandler.ashx"




@implementation MJ_HttpManager

static NSString * const HTTPRequestOperationLoginBaseUrlString = LOGINBASEURL;


#pragma mark - 单例类

/**
 *  使用基础的避免首次拼接
 *
 *  @return
 */
+(NSString *)loginBaseUrl
{
    return HTTPRequestOperationLoginBaseUrlString;
}


/**
 *  单例类
 */

+(instancetype)getSingleClass{
    
    static MJ_HttpManager * shareManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
       
        shareManager =[[MJ_HttpManager alloc]init];
    });
    return shareManager;
}

-(AFHTTPRequestOperationManager *)shareClient{
    if (!_shareClient) {
        _shareClient = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:HTTPRequestOperationLoginBaseUrlString]];
        [_shareClient.requestSerializer setTimeoutInterval:10.f];//超时 10 请求
        [_shareClient.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        [_shareClient.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        _shareClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _shareClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _shareClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json", @"text/html", nil];
    }
    return _shareClient;
}


-(AFHTTPRequestOperationManager *)cleanClient
{
    if (!_cleanClient) {
        _cleanClient = [AFHTTPRequestOperationManager manager];
        [_cleanClient.requestSerializer setTimeoutInterval:10.f];//超时 10 请求
        _cleanClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _cleanClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _cleanClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json", @"text/html", nil];
        
    }
    return _cleanClient;
}

#pragma mark - 网络请求方法

#pragma mark 1.登录方法(老师)
/**
 *  账号登录协议 - 老师
 */

-(void)loginAuthorizationWithTeacherParameters:(NSDictionary *)dict resultBlock:(void (^)(int isSuccess,NSString * message, NSError * error))resultBlock{

    [self.shareClient GET:@"" parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"老师的url___%@",operation);

        NSString *isSuccess = [responseObject objectForKey:@"ProResult"];
        
        if (isSuccess.intValue == 0) { // 有权限访问
            
            //登录后  给一身份,知道是老师端登录进去的
            [USERDEFAULTS setObject:@"teacherLogin" forKey:@"loginIdentity"];
            
            //教师端登录给 陈林存一份  他那里判断的时候用数字来判断的
            int userType = 2;
            
            TAAccountInfo *TAInfo = [[TAAccountInfo alloc] init];
            TAInfo.UserType = @(userType);
            
            NSDictionary *dictTA = TAInfo.mj_keyValues;
            NSData *dataTA = [NSKeyedArchiver archivedDataWithRootObject:dictTA];
            
            [USERDEFAULTS setObject:dataTA forKey:@"TAaccountInfo"];
            [USERDEFAULTS synchronize];
            
            //OA - 门禁需要的
            NSDictionary * dict = [responseObject objectForKey:@"Msg"];
            OAAccountInfo * accountInfo = [OAAccountInfo mj_objectWithKeyValues:dict];
            
            //存储 信息
            NSDictionary *dic = accountInfo.mj_keyValues;
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];

            [USERDEFAULTS setObject:data forKey:@"OAaccountInfo"];
            [USERDEFAULTS synchronize];
            
            if (resultBlock) {
        
                resultBlock(0,nil ,nil);
            }
        } else {
            NSString *message = [responseObject objectForKey:@"Msg"];

            NSError *err = [NSError errorWithDomain:@"error" code:200 userInfo:[NSDictionary dictionaryWithObject:message forKey:@"error"]];
            
            if (resultBlock) {
                
                resultBlock(-1, message,err);
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"老师账号登录failed");
        NSLog(@"ERROR USERINFO ========================================== \n %@", error.userInfo);
        if (resultBlock) {
            
            resultBlock(-100, nil,error);
            NSLog(@"ERROR USERINFO ========================================== \n %@", error.userInfo);
        }
    }];
}


/**
 *   老师 - 手机验证登录- 获取验证码
 */

-(void)loginAuthorizationWithTeacherGetPhoneCodeParameters:(NSDictionary *)dict resultBlock:(void (^)(int isSuccess,NSString * message, NSError * error))resultBlock{
    
    [self.shareClient GET:@"" parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *isSuccess = [responseObject objectForKey:@"ProResult"];
         NSString *message = [responseObject objectForKey:@"Msg"];
        if (isSuccess.intValue == 0) { // 获取验证码成功
            
            if (resultBlock) {
                
                resultBlock(0, message ,nil);
            }
        } else {
            NSError *err = [NSError errorWithDomain:@"error" code:200 userInfo:[NSDictionary dictionaryWithObject:message forKey:@"error"]];
            
            if (resultBlock) {
                
                resultBlock(-100, message,err);
                
            }
            
            NSLog(@"%@", message);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"获取验证码failed");
        
        if (resultBlock) {
            
            resultBlock(NO, nil, error);
            
            NSLog(@"%@", error);
        }
    }];
}

/**
 *  老师 - 手机验证登录- 登录 - 登录协议
 */

-(void)loginAuthorizationWithTeacherPhoneLoginParameters:(NSDictionary *)dict resultBlock:(void (^)(int isSuccess,NSString * message, NSDictionary * dic, NSError * error))resultBlock{
    
    [self.shareClient GET:@"" parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"operation___%@",operation);
        NSString *isSuccess = [responseObject objectForKey:@"ProResult"];
        
        
         NSLog(@"--==responseObject=---___%@",responseObject);
        if (isSuccess.intValue == 0) { // 有权限访问TA
            
            NSDictionary * dict = [responseObject objectForKey:@"Msg"];
            OAAccountInfo * accountInfo = [OAAccountInfo mj_objectWithKeyValues:dict];
            
            //存储 信息
            NSDictionary *dic = accountInfo.mj_keyValues;
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
            
            [USERDEFAULTS setObject:data forKey:@"OAaccountInfo"];
            [USERDEFAULTS synchronize];

            if (resultBlock) {
                
                resultBlock(0, nil,dict ,nil);
                
            }
        } else {
            NSString *message = [responseObject objectForKey:@"Msg"];//验证失败
            
            NSError *err = [NSError errorWithDomain:@"error" code:200 userInfo:[NSDictionary dictionaryWithObject:message forKey:@"error"]];
            
            if (resultBlock) {
                
                resultBlock(-1, message, nil,err);
            }
            NSLog(@"%@", message);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"老师手机登录failed");
        
        if (resultBlock) {
            
            resultBlock(-100, nil, nil,error);
            
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark 2.登录方法(学生)

#pragma mark - 私钥登录
-(void)loginPrivateKeyWithParameters:(NSDictionary *)dict resultBlock:(void (^)(int proResult,NSString * message,NSError * error))resultBlock
{
    [self.shareClient GET:@"" parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"operation:_____%@",operation);
        NSLog(@"responseObject:_____%@",responseObject);
        
        NSString *isSuccess = [responseObject objectForKey:@"ProResult"];
        
        if (isSuccess.intValue == 0) { // 有权限访问TA
            
            
            if (resultBlock) {
                
                resultBlock(0, nil,nil);
                
            }
        } else {
            NSString *message = [responseObject objectForKey:@"Msg"];//验证失败
            
            
            NSError *err = [NSError errorWithDomain:@"error" code:200 userInfo:[NSDictionary dictionaryWithObject:message forKey:@"error"]];
            
            if (resultBlock) {
                
                resultBlock(-1, message,err);
            }
            NSLog(@"%@", message);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"私钥登录failed");
        
        if (resultBlock) {
            
            resultBlock(-100, nil,error);
            
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark - 退出登录 (老师需要请求)
-(void)loginOutWithParameters:(NSDictionary *)dict resultBlock:(void (^)(int proResult,NSString * message , NSError * error))resultBlock{
    
    [self.shareClient GET:@"" parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"_____333%@",operation);
        
        NSString *isSuccess = [responseObject objectForKey:@"ProResult"];
        
        if (isSuccess.intValue == 0) { // 有权限访问TA
            
            if (resultBlock) {
                
                resultBlock(0, nil,nil);
                
            }
        } else if (isSuccess.intValue == -1){
            NSString *message = [responseObject objectForKey:@"Msg"];//验证失败
            
            NSError *err = [NSError errorWithDomain:@"error" code:200 userInfo:[NSDictionary dictionaryWithObject:message forKey:@"error"]];
            
            if (resultBlock) {
                
                resultBlock(-1, message,err);
            }
            NSLog(@"%@", message);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"退出登录failed");
        
            resultBlock(-100, nil,error);
            
            NSLog(@"%@", error);
    }];
    
}


#pragma mark - 进行入后进行监听
#pragma mark   OA办公页面需要接受本地通知

-(void)OANotificationWithUrl:(NSString *)urlStr andParameter:(NSDictionary *)dict resultBlock:(void (^)(NSString *resultString, NSError *error))block
{
    
    [self.cleanClient GET:urlStr parameters:dict success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        //        NSLog(@"监听成功___operation________%@",operation);
        //        NSLog(@"___json________%@",responseObject);
        //
        NSString *resultString = nil;
        NSString *resultCode = [responseObject objectForKey:@"ProResult"];
        
        if ([resultCode isEqualToString:@"0"]) { // 获取数据成功
            resultString = [responseObject objectForKey:@"Msg"];
            
            if (block) block(resultString, nil);
            
        } else if ([resultCode isEqualToString:@"-1"]) {
            
            NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{@"message": @"获取数据失败!"}];
            if (block) block(nil, error);
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        if (block) block(nil, error);
        
        //        NSLog(@"监听失败___operation________%@",operation);
        NSLog(@"监听失败");
        
    }];
}
@end
