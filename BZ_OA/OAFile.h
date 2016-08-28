//
//  OAFile.h
//  SchoolHelper
//
//  Created by 陈林 on 16/8/2.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOriginalTimaStamp     [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

#define kTimestamp             [kOriginalTimaStamp stringByReplacingOccurrencesOfString:@"." withString:@""]


@interface OAFile : NSObject

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) NSString *timeStamp;

@property (strong, nonatomic) NSString *pathComponent;

@property (strong, nonatomic) NSDate *date;

@property (strong, nonatomic) NSString *sizeString;



@end
