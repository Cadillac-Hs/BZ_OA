//
//  OAFileManager.m
//  SchoolHelper
//
//  Created by 陈林 on 16/8/2.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "OAFileManager.h"
#import "FCFileManager.h"
#import <FMDB/FMDB.h>
#import <MJExtension/MJExtension.h>


@interface OAFileManager()<UIDocumentInteractionControllerDelegate>

{
    UIViewController *_controller; //
}
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation OAFileManager

static FMDatabase *_db;
+ (void)initialize
{
    NSString *fileDirectory = [self fileDirectory];
    // 拼接文件名
    NSString *filePath = [fileDirectory stringByAppendingPathComponent:@"OA.sqlite"];
    // 创建了一个数据库实例
    _db = [FMDatabase databaseWithPath:filePath];
    
    //打开数据库
    if ([_db open]) {
        NSLog(@"打开成功");
    }else{
        NSLog(@"打开失败");
    }
    
    // 创建Data表格
    BOOL flag1 = [_db executeUpdate:@"create table if not exists t_oafile (id integer primary key autoincrement,type text,time_stamp text,dict blob);"];
    if (flag1) {
        //        NSLog(@"创建Data表成功");
    }else{
        //        NSLog(@"创建Data表失败");
    }
    
    
}

+ (instancetype)getInstance {
    static OAFileManager* sharedManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[OAFileManager alloc] init];
    });
    
    return sharedManager;
}


- (OAFileListVC<TCBlobDownloaderDelegate> *)sharedVC {
    
    if (_sharedVC == nil) {
        _sharedVC = [[OAFileListVC alloc] init];
        _sharedVC.downloadArray = self.downloadArray;
        _sharedVC.fileArray = self.fileArray;
        [_sharedVC tableView];

    }
    return _sharedVC;
}
//- (OAFileListVC *)getSharedVC {
//    static OAFileListVC *sharedVC = nil;
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
//            });
//    
//    return sharedVC;
//}


+ (NSString *)fileDirectory {
    
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentPath = [paths objectAtIndex:0];
    
    NSString *fileDirectory = [documentPath stringByAppendingPathComponent:@"/OA"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDirectory withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    return fileDirectory;
}

+ (NSString *)filePathWithPathComponent:(NSString *)pathComponent {
    
    NSString *fileDirectory = [self fileDirectory]; // Get documents folder
    NSString *filePath = [fileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",pathComponent]];
    NSLog(@"%s", __func__);
    NSLog(@"filePath = %@", filePath);
    
    return filePath;
}

- (NSMutableArray *)fileArray {
    
    if (!_fileArray) {
        _fileArray = [[OAFileManager getAllFiles] mutableCopy];
        
        if (!_fileArray) {
            _fileArray = [NSMutableArray array];
        }
        
    }
    
    return _fileArray;
}

- (NSMutableArray *)downloadArray {
    
    if (!_downloadArray) {
        _downloadArray = [NSMutableArray array];
        
    }
    
    return _downloadArray;
}
- (void)downloadFileFromURL:(NSURL *)url {
    
    NSString *path = [OAFileManager fileDirectory];

    TCBlobDownloader *download = [[TCBlobDownloader alloc] initWithURL:url
                                                          downloadPath:path
                                                              delegate:self.sharedVC];
    
    [self.downloadArray addObject:download];
    self.sharedVC.downloadArray = self.downloadArray;
    [self.sharedVC.tableView reloadData];
    
    [[TCBlobDownloadManager sharedInstance] startDownload:download];
    
}



- (void)showActionSheetFronController:(UIViewController *)controller actionTitle:(NSString *)title target:(NSObject *)target action:(nullable SEL)selAction actionParameter:(nullable id)object {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(NSObject) *weakTarget = target;
    
    UIAlertAction* actionOK = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        typeof(NSObject) *strongTarget = weakTarget;

        if ([strongTarget respondsToSelector:selAction]) {
            [strongTarget performSelector:selAction withObject:object];
        }
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
    }];
    
    [alert addAction:actionOK];
    [alert addAction:cancel];
    
    [controller presentViewController:alert animated:YES completion:nil];

}

+ (BOOL)deleteFileAtPah:(NSString *)path {
    
    // 如果移动成功, 同时如果原路径还有文件,删除原文件
    BOOL fileExists=[[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (!fileExists) {
        
    }else {
        //            NSLog(@" file exists");
        return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        
    }
    
    return NO;
}

+ (BOOL)renameFileAtPath:(NSString *)path witnNewName:(NSString *)newName {

    NSString *newPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
    return [[NSFileManager defaultManager] moveItemAtPath:path toPath:newPath error:nil];
}

+ (BOOL)saveFile:(OAFile *)file {
    
    // fbdb 存储部分
    BOOL flag;
    
    NSDictionary *dict = [file mj_keyValues];
    NSString *timeStamp = file.timeStamp;
    NSString *type = file.type;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    
    flag = [_db executeUpdate:@"insert into t_oafile (type, time_stamp, dict) values(?,?,?)", type, timeStamp, data];
    if (flag) {
                NSLog(@"插入文件成功");
    }else{
                NSLog(@"插入文件失败");
    }
    
    return flag;
}


+ (BOOL)deleteFile:(OAFile *)file {
    
    NSString *path = [self filePathWithPathComponent:file.pathComponent];

    BOOL fileExists=[[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!fileExists) {
        
    }else {
        //            NSLog(@" file exists");
        BOOL fileDeleted = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        
        if (fileDeleted == NO) {
            return fileDeleted;
        }
    }
    
    NSString *timeStamp = file.timeStamp;
    
    BOOL flag = [_db executeUpdate:@"delete from t_oafile where time_stamp=?", timeStamp];
    if (flag) {
        //        NSLog(@"删除成功");
    }else{
        //        NSLog(@"删除失败");
    }
    
    return flag;
}

+ (NSArray *)getAllFiles {
    
    // 进入程序第一次获取的查询语句
    FMResultSet *set = [_db executeQuery:@"select * from t_oafile;"];
    NSMutableArray *arrM = [NSMutableArray array];
    while ([set next]) {
        NSData *data = [set dataForColumn:@"dict"];
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        OAFile *file = [OAFile mj_objectWithKeyValues:dict];
        
        NSString *path = [OAFileManager filePathWithPathComponent:file.pathComponent];

        // 查询沙盒中是否存在对应文件, 如果存在, 则加入到数组
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [arrM insertObject:file atIndex:0];

        } else { // 如果不存在, 则直接在数据库中删除掉file对象
            
            [OAFileManager deleteFile:file];
        }
        
    }
    
    return arrM;
}


- (void)openFile:(OAFile *)file fromCurrentController:(UIViewController *)currentController {
    
    _controller = currentController;
    
    NSString *filePath = [OAFileManager filePathWithPathComponent:file.pathComponent];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    
    self.documentInteractionController =[UIDocumentInteractionController interactionControllerWithURL:fileUrl];
    self.documentInteractionController.delegate = self;
    
    CGRect navRect = _controller.view.frame;
    [self.documentInteractionController presentOptionsMenuFromRect:navRect inView:_controller.view animated:YES];
}




#pragma mark - UIDocumentInteractionControllerDelegate

//===================================================================
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return _controller;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return _controller.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return _controller.view.frame;
}




@end
