//
//  AppDelegate.m
//  BZ_OA
//
//  Created by ShenQiang on 16/8/9.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "AppDelegate.h"

#import "MJ_HttpManager.h"
#import "OA_Tool.h"
#import "OA_ViewController.h"
#import "BZ_pch.h"
#import "ZhangHaoLoginVC.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD+Tools.h"
#import "OANotificationTool.h"
#import "Tool.h"
@interface AppDelegate ()
{
    
    NSTimer  * _timer;
    
    CADisplayLink *theTimer;
    
    int  _count;
}
@end

@implementation AppDelegate
- (void)initVC {
    
    self.homeVC = [[OA_ViewController alloc] init];
    self.loginVC = [[ZhangHaoLoginVC alloc] init];
    
}

- (void)startWithNewHomeVC{
    
    self.homeVC = [[OA_ViewController alloc] init];
    UINavigationController * navVC =[[UINavigationController alloc] initWithRootViewController:self.homeVC];
    
    [self.window setRootViewController:navVC];
    
    [OANotificationTool startFetchingNofificationInForeground];
    
}

- (void)switchVCToHome {
    
    UINavigationController * navVC =[[UINavigationController alloc] initWithRootViewController:self.homeVC];
    
    [self.window setRootViewController:navVC];
    
    [OANotificationTool startFetchingNofificationInForeground];
}

- (void)switchVCToLogin {
    
    UINavigationController * navVC =[[UINavigationController alloc] initWithRootViewController:self.loginVC];
    
    [self.window setRootViewController:navVC];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    
    [self initVC];
    
    // 判断是否需要登录
    {
        NSData *userInfoData = [USERDEFAULTS objectForKey:@"OAaccountInfo"];
        
        if (userInfoData) { // 如果有保存的用户信息, 说明用户没有退出登录, 不需要展示登录界面
            
            if ([OA_Tool userType]) { //有身份的时候，私钥登录可以
            
                //私钥登录
                [self loginPrivateKeyCompleted:^{ // 私钥登录成功之后, 才可以展示OA推送的消息!
                    
                    if (launchOptions) {
                        
                        UILocalNotification * localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
                        
                        NSString * str_OA = [localNotif.userInfo objectForKey:@"OA"];
                        
                        if ([str_OA isEqualToString:@"1"]) {
                            
                            [USERDEFAULTS setObject:@"刷掉点击通知栏" forKey:@"ClickNoti"];
                            
                            [self switchVCToHome];
                        
                        }
                        
                    }
                }];
            }
            
        } else { // 如果没有保存的用户信息, 说明用户需要重新登录
            // 展示登录界面
            
            [self switchVCToLogin];
            
        }
    }
    [self kaiQiWangLuoJianCe];
    

    
    NSError * setCategoryErr = nil;
    
    NSError * activationErr  = nil;
    
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance]setActive:YES error:&activationErr];
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(startListen:) userInfo:nil repeats:YES];
//    [_timer setFireDate:[NSDate distantFuture]];//关闭定时器;
    _count = 0;

    
    return YES;
}


-(void)loginPrivateKeyCompleted:(void (^)())completeBlock

{
    NSDictionary * dic = @{
                           @"loginType" : @"2",
                           @"userId" : [OA_Tool userId],
                           @"token" : [OA_Tool token]
                           };
    
    [[MJ_HttpManager getSingleClass]loginPrivateKeyWithParameters:dic resultBlock:^(int proResult, NSString *message, NSError *error) {
        
        if (proResult == 0) {
            
            [self switchVCToHome]; // 登录成功, 展示主页
            if (completeBlock) completeBlock();
            
        }else{ // 私钥登录失败, 则直接进入登录界面
            
            [self switchVCToLogin];
        }
        
    }];

}
-(void)kaiQiWangLuoJianCe
{
    //
    ///开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [self.reach startNotifier]; //开始监听，会启动一个run loop
}
//通知
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    NSParameterAssert([reach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable) {
        self.isReachable = NO;
        
        [MBProgressHUD showGlobalProgressHUDWithTitle:@"网络已断开" hideAfterDelay:1.0];
        
        NSLog(@"Notification Says Unreachable");
    }else if(status == ReachableViaWWAN){
        
        //        [self viewAddMain];
        
        self.isReachable = YES;
    }else if(status == ReachableViaWiFi){
        
        //        [self viewAddMain];
        
        self.isReachable = YES;
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

// 本地通知回调函数，当应用程序在前台时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"active---程序当前正处于前台********");
        //        程序当前正处于前台
        [application setApplicationIconBadgeNumber:0];
        
        
    }
    else if(application.applicationState == UIApplicationStateInactive)
    {
        NSLog(@"inactive-----程序处于后台*********");
        //程序当前正处于前台
        [application setApplicationIconBadgeNumber:0];
        
        //程序处于后台
        [[NSNotificationCenter defaultCenter]postNotificationName:@"123456" object:nil userInfo:notification.userInfo];
        
    }else{
        NSLog(@"backGround");
        
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.使用这个方法来释放共享资源,保存用户数据,无效计时器,和储存足够多的应用程序状态信息来恢复您的应用程序的当前状态情况下,终止。
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.如果您的应用程序支持后台执行,而不是调用此方法applicationWillTerminate:当用户退出
    
    
    //设置永久后台运行
    UIApplication * app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
            
        });
        
        
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
            
        });
    
    });
    
    NSString * str = [USERDEFAULTS objectForKey:@"KaiQi"];
    
    if (str) {
        
        if ([[OA_Tool userType] containsString:@"教职工"]) {
            
            if ([str isEqualToString:@"开启通知"]) {
                
                [OANotificationTool startFetchingNofificationInBackground];
                
            }
        }
    }
    NSLog(@"进入后台-");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [OANotificationTool stopFetchingNotification];    //    [_timer setFireDate:[NSDate distantFuture]];
    NSLog(@"_后台运行计数为%d",_count);
    
    NSNumber * time =  [Tool currentTimestampWithLongLongFormat];
    NSLog(@"后台进入的时候 时间戳 : %@",time);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
