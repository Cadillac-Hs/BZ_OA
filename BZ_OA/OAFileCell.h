//
//  OAFileCell.h
//  SchoolHelper
//
//  Created by 陈林 on 16/8/2.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OAFile;

@interface OAFileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UIView *progressView;

@property (strong, nonatomic) OAFile *model;

- (void)updateProgressWithTotalBytes:(CGFloat)totalBytes downloadedBytes:(CGFloat)downloadedBytes;

@end
