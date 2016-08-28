//
//  ShowProgressView.m
//  SchoolHelper
//
//  Created by ShenQiang on 16/8/9.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "ShowProgressView.h"
#import "OAFileManager.h"
#import "MBProgressHUD+Tools.h"
#import "BZ_pch.h"
#import <AFNetworking/AFNetworking.h>

@implementation ShowProgressView
//
//+(ShowProgressView *)getSingleClass{
//    
//    static ShowProgressView * progressView = nil;
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
//        
//        progressView =[[ShowProgressView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
////        progressView.backgroundColor = [UIColor blackColor];
////        progressView.alpha = 0.3;
//        
//    });
//    
//    return progressView;
//}

+ (instancetype)progressView {
    
    return [[self alloc] init];
}

+ (instancetype)progressViewWithFrame:(CGRect)frame {
    
    return [[self alloc] initWithFrame:(CGRect)frame ];
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        [self initSubviews];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self initSubviews];
    }
    
    return self;
}

- (void)initSubviews {
    
    self.backgroundColor = [UIColor clearColor];
    _cover = [[UIView alloc] initWithFrame:self.frame];
    [self addSubview:_cover];
    _cover.backgroundColor = [UIColor blackColor];
    _cover.alpha = 0.4f;
    
    //         UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.circleProgress1 =[WLCircleProgressView viewWithFrame:CGRectMake(WIDTH/2-50, HEIGHT/2-50, 100, 100)
                                                  circlesSize:CGRectMake(30, 5, 30, 5)];
    self.circleProgress1.layer.cornerRadius = 10;
    self.circleProgress1.progressValue = 0.2;
//    self.circleProgress1.backgroundColor = [UIColor blueColor];
    
    [self addSubview:self.circleProgress1];
//    self.progressView1 = self.circleProgress1;
    
    
    self.progressLab = [[UILabel alloc]init];
    self.progressLab.bounds = CGRectMake(0, 0, 30, 20);

    self.progressLab.font = [UIFont systemFontOfSize:9];
    self.progressLab.textColor = [UIColor whiteColor];
    self.progressLab.textAlignment = NSTextAlignmentCenter;

    [self addSubview:_progressLab];
    self.progressLab.center = self.circleProgress1.center;
//    NSLog(@"labelCenter = %@", NSStringFromCGPoint(self.progressLab.center));
//    NSLog(@"circleCenter = %@", NSStringFromCGPoint(self.circleProgress1.center));
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 3.0f;
    btn.clipsToBounds = YES;
    btn.frame = CGRectMake(30, HEIGHT-70, WIDTH-60, 50);
    [btn addTarget:self action:@selector(dismissProgressViewClick) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = kColorWithRGB(255, 255, 255);
    [btn setTitle:@"取消上传" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn setTitleColor:kColorWithRGB(64, 150, 252) forState:UIControlStateNormal];
    [self addSubview:btn];

}

- (void)updateProgress:(CGFloat)progress {
    
    self.circleProgress1.progressValue = progress;

    self.progressLab.text = [NSString stringWithFormat:@"%.0f%%",(progress*100)];
    
    if (progress >= 1) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissView];
            [MBProgressHUD showGlobalProgressHUDWithTitle:@"文件上传成功!" hideAfterDelay:1.0f];
        });
    }
}



- (void)setCancelBlock:(void (^)())cancelBlock {
    
    _cancelBlock = cancelBlock;
}


+ (void)upLoadFileFromUrlStr:(NSString *)urlStr withParametes:(NSDictionary *)dic withOAFileModel:(OAFile *)fileModel  successBlock:(void (^)())sucessBlock errorInfoBlock:(void (^)(NSString * error))errorInfoBlock{
    
    NSString *filePath = [OAFileManager filePathWithPathComponent:fileModel.pathComponent];
    
    NSData  * data = [NSData dataWithContentsOfFile:filePath];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:urlStr parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:fileModel.title fileName:fileModel.title mimeType:fileModel.type];
    } error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"上传成功");
                                         NSString * proResult = [responseObject objectForKey:@"ProResult"];
                                 
                                         if (proResult.intValue == 0) {
                                             if (sucessBlock) {
                                                 sucessBlock();
                                             }
                                         }else{
                                             
                                              NSString * Msg = [responseObject objectForKey:@"Msg"];
                                             
                                             if (errorInfoBlock) {
                                                 errorInfoBlock(Msg);
                                             }

                                         }
                                       
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        
                                         NSLog(@"上传失败");
                                         NSLog(@"Failure______++++ %@", error.description);
                                     }];
    
    // 4. Set the progress block of the operation.
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    ShowProgressView *progressView = [ShowProgressView progressViewWithFrame:window.frame];

    [window addSubview:progressView];
    [progressView setCancelBlock:^{
        [operation cancel];
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
//        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
        
        //        if (self.returnProgressBlock != nil) {
        
        CGFloat progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        
//        NSLog(@"OAFileUpLoad_________%lf",progress);
        
        //            self.returnProgressBlock(progress);
        [progressView updateProgress:progress];
        
        
        //        }
    }];
    
    // 5. Begin!
    [operation start];
    
}


-(void)view:(UIView *)view addupdateProgress:(CGFloat)progressValue
{
    if (self.circleProgress1 == nil) {
//         UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        self.circleProgress1 =[WLCircleProgressView viewWithFrame:CGRectMake(WIDTH/2-50, HEIGHT/2-50, 100, 100)
                                                                               circlesSize:CGRectMake(30, 5, 30, 5)];
        self.circleProgress1.layer.cornerRadius = 10;
        self.circleProgress1.progressValue = 0.2;
        [view addSubview:self.circleProgress1];
//        self.progressView1 = self.circleProgress1;
        
        if (_progressLab) {
            
            self.progressLab = [[UILabel alloc]init];
            self.progressLab.center = self.circleProgress1.center;
            self.progressLab.bounds = CGRectMake(0, 0, 20, 20);
            self.progressLab.text = @"12";
//            if (self.progressLabValue <=0) {
//                int Value = 0;
//                self.progressLab.text = [NSString stringWithFormat:@"%d%@",Value,@"%"];
//                
//            }else{
//                self.progressLab.text = [NSString stringWithFormat:@"%.0f%%",progressValue];
//                
//            }
            self.progressLab.font = [UIFont systemFontOfSize:9];
            self.progressLab.textColor = [UIColor whiteColor];
            self.progressLab = self.progressLab;
            
            [self.circleProgress1 addSubview:_progressLab];
        }
    }
    self.circleProgress1.progressValue = progressValue;
//    self.progressLabValue = progressValue;
//    self.progressLab22.text = [NSString stringWithFormat:@"%.0f%%",progressValue];
}



-(void)dismissProgressViewClick
{
//    [_delegate dismissProgressView];
    if (_cancelBlock) {
        _cancelBlock();
    }
    [self dismissView];
    [MBProgressHUD showGlobalProgressHUDWithTitle:@"取消上传成功!" hideAfterDelay:1.0f];
    
}

- (void)dismissView {
    
    if (self.superview) {
        [self removeFromSuperview];
    }
}


@end
