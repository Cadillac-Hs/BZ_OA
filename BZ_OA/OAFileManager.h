//
//  OAFileManager.h
//  SchoolHelper
//
//  Created by 陈林 on 16/8/2.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAFile.h"
#import <TCBlobDownload/TCBlobDownload.h>
#import "OAFileListVC.h"


#import <AFNetworking/AFNetworking.h>



@interface OAFileManager : NSObject

@property (strong, nonatomic) OAFileListVC *sharedVC;

@property (nonatomic, strong) NSMutableArray *downloadArray;

@property (nonatomic, strong) NSMutableArray *fileArray;

+ (instancetype)getInstance;

//- (OAFileListVC *)getSharedVC;
+ (BOOL)saveFile:(OAFile *)file;

+ (BOOL)renameFileAtPath:(NSString *)path witnNewName:(NSString *)newName;

+ (NSString *)fileDirectory;

+ (NSString *)filePathWithPathComponent:(NSString *)pathComponent;

- (void)downloadFileFromURL:(NSURL *)url;

+ (BOOL)deleteFile:(OAFile *)file;

+ (BOOL)deleteFileAtPah:(NSString *)path;

+ (NSArray *)getAllFiles;

- (void)openFile:(OAFile *)file fromCurrentController:(UIViewController *)currentController;

- (void)showActionSheetFronController:(UIViewController *)controller actionTitle:(NSString *)title target:(NSObject *)target action:(nullable SEL)selAction actionParameter:(nullable id)object;

@end
