//
//  OANotificationTool.h
//  SchoolHelper
//
//  Created by 陈林 on 16/8/12.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OANotificationTool : NSObject

@property (assign, nonatomic) BOOL isFetchingNotification; // 判断获取服务是否正在运行

@property (copy, nonatomic) void (^notificationBlock)(NSString *resultString); // 后台通知处理
@property (copy, nonatomic) void (^UIBlock)(NSString *resultString); // 前台UI刷新处理

+ (instancetype)getInstance;

+ (void)startFetchingNofificationInBackground; // 后台
+ (void)startFetchingNofificationInForeground; // 后台

+ (void)startFetchingNofification;

+ (void)stopFetchingNotification;

+ (void)dismissTimer; //释放掉定时器

@end
