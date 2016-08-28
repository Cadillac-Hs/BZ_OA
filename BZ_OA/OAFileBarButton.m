//
//  OAFileBarButton.m
//  SchoolHelper
//
//  Created by 陈林 on 16/8/3.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "OAFileBarButton.h"

@implementation OAFileBarButton

+ (instancetype)fileBarButton {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"OAFileBarButton" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.badgeLabel.hidden = YES;
    self.badgeLabel.layer.cornerRadius = 8.f;
    self.badgeLabel.clipsToBounds = YES;
    self.badgeLabel.hidden = YES;
    self.IconView.tintColor = [UIColor whiteColor];

}

- (void)setIconImage:(UIImage *)image {
    
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.IconView setImage:image];
}

- (void)setBadgeCount:(int)count {
    
    self.badgeLabel.hidden = (count == 0);
    
    self.badgeLabel.text = [NSString stringWithFormat:@"%d", (count > 99 ? 99 : count)];
    
    CGRect orignalBounds = CGRectMake(0, 0, 16, 16);;
    CGRect newBounds = CGRectMake(0, 0, orignalBounds.size.width*2.f, orignalBounds.size.height*2.f);

    
    [UIView animateWithDuration:0.1f animations:^{
        self.badgeLabel.layer.cornerRadius = 16.f;
        self.badgeLabel.bounds = newBounds;

        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1f animations:^{
            
            self.badgeLabel.layer.cornerRadius = 8.f;
            self.badgeLabel.bounds = orignalBounds;

        }];
    }];
}


@end
