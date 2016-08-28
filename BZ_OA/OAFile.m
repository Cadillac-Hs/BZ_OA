//
//  OAFile.m
//  SchoolHelper
//
//  Created by 陈林 on 16/8/2.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "OAFile.h"
#import "FCFileManager.h"
#import "OAFileManager.h"

@implementation OAFile

- (NSString *)timeStamp {
    if (_timeStamp == nil) {
        _timeStamp = kTimestamp;
    }
    
    return _timeStamp;
}

- (NSDate *)date {
    
    if (_date == nil)  _date = [NSDate date];
    
    return _date;
}

- (NSString *)sizeString {
    
    return [FCFileManager sizeFormattedOfFileAtPath:[OAFileManager filePathWithPathComponent:self.pathComponent]];
}

@end
