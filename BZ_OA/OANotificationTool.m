//
//  OANotificationTool.m
//  SchoolHelper
//
//  Created by 陈林 on 16/8/12.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "OANotificationTool.h"
#import "MJ_HttpManager.h"
#import "OA_Tool.h"
#import "AppDelegate.h"
#import "OA_ViewController.h"
#import "BZ_pch.h"



@interface OANotificationTool()

@property (strong, nonatomic) NSTimer *timer;

+ (void)startFetchingNofificationWithNotificationBlock:(void (^)(NSString *resultString))notificationBlock;

+ (void)startFetchingNotificationWithUIBlock:(void (^)(NSString *resultString))UIBlock;

- (void)getOANotification;

@end

@implementation OANotificationTool

+ (void)startFetchingNofificationWithNotificationBlock:(void (^)(NSString *resultString))notificationBlock {
    
    [[OANotificationTool getInstance] setNotificationBlock:notificationBlock];
    [OANotificationTool startFetchingNofification];
}

+ (void)startFetchingNofificationInBackground {
    
    [[OANotificationTool getInstance] setNotificationBlock:^(NSString *resultString) {
        [OANotificationTool addLocalNotification:resultString];
        NSLog(@"发送了通知");

    }];
    [OANotificationTool startFetchingNofification];
}

+ (void)startFetchingNofificationInForeground{
    
    [[OANotificationTool getInstance] setUIBlock:^(NSString *resultString) {
        AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        OA_ViewController *homeVC = app.homeVC;
//        [homeVC updateBadgeUI:resultString];

    }];
    [OANotificationTool startFetchingNofification];
    
}

+ (void)startFetchingNotificationWithUIBlock:(void (^)(NSString *resultString))UIBlock {
    
    [[OANotificationTool getInstance] setUIBlock:UIBlock];
    [OANotificationTool startFetchingNofification];
}

+ (instancetype)getInstance {
    static OANotificationTool* sharedTool = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedTool = [[OANotificationTool alloc] init];
    });
    
    return sharedTool;
}

- (instancetype)init {
    
    if (self = [super init]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(getOANotification) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];//关闭定时器;
        _isFetchingNotification = NO;

    }
    return self;
}

// 开始获取OA消息
+ (void)startFetchingNofification {
    
    OANotificationTool *tool = [OANotificationTool getInstance];
    
    if (tool.timer == nil) {
        tool.timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(getOANotification) userInfo:nil repeats:YES];

    }
    
    //开启定时器
    [tool.timer setFireDate:[NSDate distantPast]];
    tool.isFetchingNotification = YES;


}

// 停止获取OA消息
+ (void)stopFetchingNotification {
    
    OANotificationTool *tool = [OANotificationTool getInstance];

    if (tool.timer == nil) return;
    
    [tool.timer setFireDate:[NSDate distantFuture]]; //关闭定时器;
    tool.isFetchingNotification = NO;

}


- (void)setNotificationBlock:(void (^)(NSString *resultString))notificationBlock {
    
    _notificationBlock = notificationBlock;
    _UIBlock = nil;
}

- (void)setUIBlock:(void (^)(NSString *resultString))UIBlock {
    
    _UIBlock = UIBlock;
    _notificationBlock = nil;
}

- (void)getOANotification {
    
    if ([[OA_Tool userType] containsString:@"教职工"]) {
        
        NSDictionary *dict = @{
                               @"userid" : [OA_Tool userId],
                               @"token" : [OA_Tool token]
                               };
        
        [[MJ_HttpManager getSingleClass] OANotificationWithUrl:[WEB_BASE_URL stringByAppendingString:GET_NOTIFICATION_URL] andParameter:dict resultBlock:^(NSString *resultString, NSError *error) {
            
            if (!error) {
                
                if (resultString) { //从服务器获取到的通知消息(内含消息数量)
                    
                    NSString * numMessage = [USERDEFAULTS objectForKey:@"MainVCNoti"];
                    NSLog(@"------%@-+++++++--%@",numMessage,resultString);
                    if (_UIBlock) _UIBlock(resultString);

                    if (numMessage == nil || [numMessage isEqualToString:resultString] == NO) { // 如果是第一次获得消息或者获得的消息与之前的消息不同
                        
                        if (_notificationBlock) _notificationBlock(resultString);
                        
                        // 保存新的消息到沙盒中.
                        [USERDEFAULTS setObject:resultString forKey:@"MainVCNoti"];
                        [USERDEFAULTS synchronize];
                        
                    }
  
                }
                
            }
        }];
    }

}

+(void) addLocalNotification:(NSString *)num
{
    UILocalNotification * noti = [[UILocalNotification alloc]init];
    NSDate * fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
    
    noti.fireDate = fireDate;
    noti.alertBody = [NSString stringWithFormat:@"您有%@条消息未读",num];
    noti.applicationIconBadgeNumber = [num intValue];
    
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"1" forKey:@"OA"];
    noti.userInfo = userDict;
    
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
        //        noti.repeatInterval = NSCalendarUnitDay;
    } else {
        // 通知重复提示的单位，可以是天、周、月
        //        noti.repeatInterval = NSDayCalendarUnit;
    }
    
    [USERDEFAULTS setObject:@"保存通知" forKey:@"saveNoti"];
    
    // 执行通知注册   docx
    [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
    
}

+ (void)dismissTimer {
    
    OANotificationTool *tool = [OANotificationTool getInstance];
    
    tool.isFetchingNotification = NO;
    if (tool.timer == nil) return;
    
    [tool.timer invalidate];
    tool.timer = nil;
}

@end
