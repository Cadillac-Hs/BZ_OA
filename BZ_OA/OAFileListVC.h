//
//  OAFileListVC.h
//  SchoolHelper
//
//  Created by 陈林 on 16/8/2.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TCBlobDownloader, OAFile;

@interface OAFileListVC : UIViewController

typedef void (^BadgeBlock)(NSInteger count);

// 正在下载的任务
@property (strong, nonatomic) NSMutableArray <TCBlobDownloader *> *downloadArray;

// 已经完成下载的文件
@property (strong, nonatomic) NSMutableArray <OAFile *> *fileArray;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) BadgeBlock badgeBlock;

@end
