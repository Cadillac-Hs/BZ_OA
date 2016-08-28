//
//  OAFileCell.m
//  SchoolHelper
//
//  Created by 陈林 on 16/8/2.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "OAFileCell.h"
#import "RMDownloadIndicator.h"
#import "OAFile.h"
#import "NSString+Tools.h"

#import "BZ_pch.h"

@interface OAFileCell()

@property (strong, nonatomic) RMDownloadIndicator *progressIndicator;

@end

@implementation OAFileCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.progressIndicator = [[RMDownloadIndicator alloc] initWithFrame:self.progressView.bounds type:kRMMixedIndictor];
    [self.progressView addSubview:self.progressIndicator];
    
    [self.progressIndicator setBackgroundColor:[UIColor whiteColor]];
    [self.progressIndicator setFillColor:OA_NavgationBarBackGroundColor];
    [self.progressIndicator setStrokeColor:[UIColor whiteColor]];
    self.progressIndicator.radiusPercent = 0.45;
    [self.progressIndicator loadIndicator];
}

- (void)updateProgressWithTotalBytes:(CGFloat)totalBytes downloadedBytes:(CGFloat)downloadedBytes {
    
    if (self.progressView.hidden == YES) {
        self.progressView.hidden = NO;
    }
    
    [self.progressIndicator updateWithTotalBytes:totalBytes downloadedBytes:downloadedBytes];
    
}

- (void)setModel:(OAFile *)model {
    
    _model = model;
    
    self.titleLabel.text = model.title;
    self.sizeLabel.text = model.sizeString;
    self.timeLabel.text = [NSString getDateString:model.date];
}

@end
