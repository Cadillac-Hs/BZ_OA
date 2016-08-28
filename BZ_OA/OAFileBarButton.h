//
//  OAFileBarButton.h
//  SchoolHelper
//
//  Created by 陈林 on 16/8/3.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OAFileBarButton : UIButton

@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *IconView;

+ (instancetype)fileBarButton;

- (void)setIconImage:(UIImage *)image;

- (void)setBadgeCount:(int)count;

@end
