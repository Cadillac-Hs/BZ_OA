//
//  MBProgressHUD+Tools.h
//  Mook
//
//  Created by 陈林 on 16/4/14.
//  Copyright © 2016年 Chen Lin. All rights reserved.
//

#import "MBProgressHUD.h"
@interface MBProgressHUD (Tools)

+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title;

+ (void)showGlobalProgressHUDWithTitle:(NSString *)title hideAfterDelay:(NSTimeInterval)delay;


+ (void)dismissGlobalHUD;


@end
