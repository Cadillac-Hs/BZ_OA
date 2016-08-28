//
//  OAFileListVC.m
//  SchoolHelper
//
//  Created by 陈林 on 16/8/2.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "OAFileListVC.h"
#import "OAFileManager.h"
#import "OAFileCell.h"

#import "MBProgressHUD+Tools.h"
#import "BZ_pch.h"

@interface OAFileListVC ()<UITableViewDelegate, UITableViewDataSource, TCBlobDownloaderDelegate>

{
    UIBarButtonItem *_edit;
    UIBarButtonItem *_selectAll;
    UIBarButtonItem *_delete;
    UIBarButtonItem *_cancel;
}
@property (strong, nonatomic) NSMutableArray <OAFile *> *deleteArray;
@end

@implementation OAFileListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = BACKCOLOR22;
//    [self tableView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(setEdit)];
//    for (TCBlobDownloader *downoader in self.downloadArray) {
//        downoader.delegate = self;
//    }
    
    _edit = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(setEdit)];
    _cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(setEdit)];
    _delete = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteFile)];
    _selectAll = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll)];
    
    self.navigationItem.rightBarButtonItems = @[_edit];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.editing) {
        
        [self setEdit];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEdit {
    
    [self setEditing:!self.editing];
    [self.tableView setEditing:self.editing animated:YES];
    
    if (self.editing) {
        self.navigationItem.rightBarButtonItems = @[_cancel, _selectAll, _delete];
        
    } else {
        
        self.navigationItem.rightBarButtonItems = @[_edit];
        
        if (self.deleteArray.count > 0) {
            [self.deleteArray removeAllObjects];
        }
    }

}

#pragma mark - TCBlobDownloader Delegate


- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSuccess:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    //NSLog(@"FINISHED");
    NSInteger index = [self.downloadArray indexOfObject:blobDownload];
    
    OAFileCell *cell = (OAFileCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    
    OAFile *file = cell.model;
    
    if (file == nil) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
        });
    }
    
    if (file == nil) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [OAFileManager deleteFileAtPah:pathToFile];
            
        });
        
        [MBProgressHUD showGlobalProgressHUDWithTitle: @"文件保存失败, 请尝试重新下载!" hideAfterDelay:1.f];
        
        return;
    }
    // 保存OAFile对象到数据库中
    if ([OAFileManager saveFile:file]) {
        
        [self.downloadArray removeObject:blobDownload];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        
        
        [self.fileArray insertObject:file atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            BOOL flag = [OAFileManager renameFileAtPath:pathToFile witnNewName:file.title];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (flag) {
                    
                } else { // 如果保存失败, 删除下载的文件, 并提示用户重新下载
                    
                    [OAFileManager deleteFileAtPah:pathToFile];

                    [MBProgressHUD showGlobalProgressHUDWithTitle: @"文件保存失败, 请尝试重新下载!" hideAfterDelay:1.f];
                }
            });
        });

        
    }
    
    if (_badgeBlock) {
        
        _badgeBlock(self.downloadArray.count);
    }
    
}

- (void)setBadgeBlock:(BadgeBlock)badgeBlock {
    
    _badgeBlock = badgeBlock;
}

- (void)download:(TCBlobDownloader *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength
        progress:(float)progress
{
    NSInteger index = [self.downloadArray indexOfObject:blobDownload];
    
    OAFileCell *cell = (OAFileCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell updateProgressWithTotalBytes:totalLength downloadedBytes:receivedLength];
}

- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
    NSInteger index = [self.downloadArray indexOfObject:blobDownload];
    
    OAFileCell *cell = (OAFileCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                              inSection:0]];
    NSString *suggestedName = [response.suggestedFilename stringByRemovingPercentEncoding];
    
    NSInteger count = 0;
    
    NSString *type = [suggestedName pathExtension];
    
    for (OAFile *file in self.fileArray) {
        
        if ([file.title containsString:[suggestedName stringByDeletingPathExtension]]) {
            
            count ++;
            
            
        }
        
        
        
        
    }
    
    
    if (count > 0) {
        
        NSString *nameBeforePathExtension = [[suggestedName stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@"(%ld).", (long)count]];;
        
        suggestedName = [nameBeforePathExtension stringByAppendingString:type];
        //        //文件类型
        //        type = [suggestedName pathExtension];;
        
    }
    
    OAFile *file = [[OAFile alloc] init];
    
    file.title = suggestedName;
    file.pathComponent = suggestedName;
    [file date];
    file.type = type;
    cell.model = file;

}

- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
    NSInteger index = [self.downloadArray indexOfObject:blobDownload];
    
    OAFileCell *cell = (OAFileCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
}
//
- (void)selectAll {
    
    for (int i = 0; i < self.fileArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    [self.deleteArray addObjectsFromArray:self.fileArray];
}

- (void)deleteFile {
    
    for (OAFile *file in self.deleteArray) {
        
        //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.fileArray indexOfObject:file] inSection:1];
        
        [self.fileArray removeObject:file];
        [OAFileManager deleteFile:file];
        
        //        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - UITableView Delegate & Datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    OAFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];
    
    if (indexPath.section == 0) {
        
        [cell.progressView setHidden:NO];
        
    }
    if (indexPath.section == 1) {
        
        OAFile *file = self.fileArray[indexPath.row];
        [cell setModel:file];
        [cell.progressView setHidden:YES];
    }

    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.downloadArray.count;
    }
    return self.fileArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"下载中";
    }
    return @"已下载";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ([tableView.dataSource tableView:self.tableView numberOfRowsInSection:section] == 0) {
        return 0;
    }
    
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    OAFile *file = self.fileArray[indexPath.row];
    
    if (self.tableView.isEditing) {
        
        if ([self.deleteArray containsObject:file] == NO) {
            
            [self.deleteArray addObject:file];
        }
        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (indexPath.section == 1) {
            
            [[OAFileManager getInstance] openFile:file fromCurrentController:self];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return NO;
    }
    
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        OAFile *file = self.fileArray[indexPath.row];
//        [self.fileArray removeObject:file];
//        [OAFileManager deleteFile:file];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}
//取消选中
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableView.isEditing) {
        OAFile *file = self.fileArray[indexPath.row];
        
        if ([self.deleteArray containsObject:file]) {
            
            [self.deleteArray removeObject:file];
        }
        
    }
}


#pragma mark - 数据懒加载

- (NSMutableArray *)fileArray {
    
    if (!_fileArray) {
        _fileArray = [[OAFileManager getAllFiles] mutableCopy];
        
        if (!_fileArray) {
            _fileArray = [NSMutableArray array];
        }
        
    }
    
    return _fileArray;
}

- (NSMutableArray *)deleteArray {
    
    if (!_deleteArray) {
        _deleteArray = [NSMutableArray array];
        
    }
    
    return _deleteArray;
}

- (NSMutableArray *)downloadArray {
    
    if (!_downloadArray) {
        _downloadArray = [NSMutableArray array];
        
    }
    
    return _downloadArray;
}

#pragma mark 控件懒加载

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        [self.view addSubview:_tableView];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        _tableView.backgroundColor = [UIColor clearColor];
        
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundView = [UIView new];
        
        [_tableView registerNib:[UINib nibWithNibName:@"OAFileCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"fileCell"];
        _tableView.rowHeight = 80;
        
    }
    
    return _tableView;
}

@end
