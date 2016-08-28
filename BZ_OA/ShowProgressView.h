//
//  ShowProgressView.h
//  SchoolHelper
//
//  Created by ShenQiang on 16/8/9.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLCircleProgressView.h"
@class OAFile;

//// 代理方法
//@protocol ShowProgressViewDelegate <NSObject>
//
//// 可选执行方法
//@optional
//// 点击按钮下标时传递参数
//- (void)dismissProgressView;
//@end


@interface ShowProgressView : UIView

@property(nonatomic,strong)UIView *cover;

@property(nonatomic,strong)WLCircleProgressView *circleProgress1;
//@property (nonatomic, strong) WLCircleProgressView *progressView1;
@property(nonatomic,strong)UILabel * progressLab;
//@property(nonatomic,strong)UILabel * progressLab22;
@property (nonatomic, assign) CGFloat progressLabValue;// 范围: 0 ~ 1
@property (nonatomic, strong) void(^cancelBlock)();


//+(ShowProgressView *)getSingleClass;

+ (void)upLoadFileFromUrlStr:(NSString *)urlStr withParametes:(NSDictionary *)dic withOAFileModel:(OAFile *)fileModel  successBlock:(void (^)())sucessBlock errorInfoBlock:(void (^)(NSString * error))errorInfoBlock;

+ (instancetype)progressView;
+ (instancetype)progressViewWithFrame:(CGRect)frame;

- (void)setCancelBlock:(void (^)())cancelBlock;

- (void)updateProgress:(CGFloat)progress;


+(UIView *)showProgressAddsubview:(ShowProgressView *)progressView;
-(void)view:(UIView *)view addupdateProgress:(CGFloat)progressValue;
+(void)dismiss;

// 代理属性
//@property (assign, nonatomic)id<ShowProgressViewDelegate>delegate;

@end
