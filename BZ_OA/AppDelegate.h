//
//  AppDelegate.h
//  BZ_OA
//
//  Created by ShenQiang on 16/8/9.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ZhangHaoLoginVC.h"
#import "OA_ViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(strong,nonatomic)Reachability * reach;
@property(nonatomic,assign)BOOL isReachable;


@property (strong, nonatomic) OA_ViewController *homeVC;
@property (strong, nonatomic) ZhangHaoLoginVC *loginVC;

- (void)startWithNewHomeVC;

- (void)switchVCToHome;

- (void)switchVCToLogin;
@end

