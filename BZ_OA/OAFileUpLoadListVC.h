//
//  OAFileUpLoadListVC.h
//  SchoolHelper
//
//  Created by ShenQiang on 16/8/8.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OAFile;

typedef void (^ReturnShowProgressBlock)(CGFloat showProgress);


@interface OAFileUpLoadListVC : UIViewController

@property(nonatomic,retain)UIWebView * webView;

@property(nonatomic,copy)NSString * getParametesUrlStr;
@property(nonatomic,copy)NSString * upLoadUrlStr;
@property(nonatomic,copy)NSString * fileTypeStr;
@property(nonatomic,retain)OAFile * oaFile;

@property (nonatomic, copy) ReturnShowProgressBlock returnProgressBlock;
@property(nonatomic,copy)NSString * progressValue;

- (void)returnText:(ReturnShowProgressBlock)block;
@end
