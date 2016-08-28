//
//  OAFileUpLoadListVC.m
//  SchoolHelper
//
//  Created by ShenQiang on 16/8/8.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "OAFileUpLoadListVC.h"
#import "AFNetworking.h"
#import "OAFileManager.h"
#import "OAFile.h"
#import "ShowProgressView.h"
#import "MBProgressHUD+Tools.h"
#import "OA_Tool.h"

#import "BZ_pch.h"

@interface OAFileUpLoadListVC ()<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>
{
    UITableView * _tableView;
}
@property(nonatomic,retain)NSMutableArray * fileCountArray;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;//查看文件 的控制器

@property(nonatomic,retain)UILabel * alertLab;
@end

@implementation OAFileUpLoadListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = BACKCOLOR22;
    self.title = @"请选择文件";

    
    [self addNavSubviews];
    
    [self getDataSource];
    [self initFileListSubviews];
    
     [self addAlertLabForUser];
}
//导航上的内容
- (void)addNavSubviews{
    
    UIView * view  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    view.backgroundColor = OA_NavgationBarBackGroundColor;
    [self.view addSubview:view];
    //左按钮
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 20, 30, 30);
    [button addTarget:self action:@selector(backVC) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"fx_03"] forState:UIControlStateNormal];
    [view addSubview:button];
    
    UILabel *title = [[UILabel alloc] init];
    title.frame = CGRectMake(WIDTH/2-80, 20, 160, 40);
    title.text = @"请选择文件";
    title.font = [UIFont systemFontOfSize:17];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
   
    [view addSubview:title];
    
}

//添加 本地文件的列表
-(void)initFileListSubviews
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT)];
    _tableView.backgroundColor = BACKCOLOR22;
    _tableView.rowHeight = 60;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

-(void)getDataSource
{
    NSArray * array = [OAFileManager getAllFiles];
    self.fileCountArray = [[NSMutableArray alloc]init];

    for (OAFile * model in array) {
               if ([self.fileTypeStr isEqualToString:@"doc"]) {
            
            if ([model.type isEqualToString:@"doc"]) {
                NSLog(@"model.type  : %@----------model.title  %@",model.type,model.title);
                [self.fileCountArray addObject:model];
            }
        }
        
        else if ([self.fileTypeStr isEqualToString:@"pdf"]){
            
            if ([model.type isEqualToString:@"pdf"]){
                NSLog(@"model.type  : %@----------model.title  %@",model.type,model.title);

                [self.fileCountArray addObject:model];
            }
        }else{
            self.fileCountArray = [array mutableCopy];
        }
    }
    
    //self.fileCountArray = [OAFileManager getAllFiles];
    NSLog(@"_获取的fileCountArray____%d",self.fileCountArray.count);
   
}
//当无文件时,提示用户
-(void)addAlertLabForUser
{
    if (self.fileCountArray.count == 0) {
        self.alertLab = [[UILabel alloc]initWithFrame:CGRectMake(0, (HEIGHT-64)/2-20, WIDTH, 40)];
        [_tableView addSubview:self.alertLab];
        self.alertLab.hidden = NO;
        self.alertLab.text = @"暂无可选的文件";
        self.alertLab.textAlignment = NSTextAlignmentCenter;
        self.alertLab.textColor = [UIColor lightGrayColor];
        self.alertLab.font = [UIFont systemFontOfSize:16];
    }else{
        self.alertLab.hidden = YES;
    }
}
#pragma mark - TableViewDetegate 的方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileCountArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    OAFile * model = self.fileCountArray [indexPath.row];
    cell.textLabel.text = model.title;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.text = model.sizeString;

    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showActionSheetFronController:self actionTitle:@"上传文件" actionTitle:@"点击查看" target:self action:@selector(startUploadWithUrlString:) action2:@selector(startSeeFile:) actionParameter:indexPath];
}


- (void)showActionSheetFronController:(UIViewController *)controller actionTitle:(NSString *)title actionTitle:(NSString *)seeFile target:(NSObject *)target action:(nullable SEL)selAction action2:(nullable SEL)selAction2 actionParameter:(nullable id)object {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(NSObject) *weakTarget = target;
    
    UIAlertAction* actionOK = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        typeof(NSObject) *strongTarget = weakTarget;
        
        if ([strongTarget respondsToSelector:selAction]) {
            [strongTarget performSelector:selAction withObject:object];
        }
    }];
    
    UIAlertAction* actionSeeFile = [UIAlertAction actionWithTitle:seeFile style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        typeof(NSObject) *strongTarget = weakTarget;
        
        if ([strongTarget respondsToSelector:selAction2]) {
            [strongTarget performSelector:selAction2 withObject:object];
        }
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
    }];
    
    [alert addAction:actionOK];
    [alert addAction:actionSeeFile];
    [alert addAction:cancel];
    
    [controller presentViewController:alert animated:YES completion:nil];
    
}



#pragma mark - 上传文件点击

- (void)startUploadWithUrlString:(NSIndexPath *)indexPath {
    
    
    NSLog(@"_需要分解url获得参数的url____%@",self.getParametesUrlStr);
    
    NSString * urlString = self.getParametesUrlStr;
    
    if ([urlString containsString:@"?"]&&[urlString containsString:@"="]) {
        
        NSArray * array = [urlString componentsSeparatedByString:@"?"];
        
        NSString * dicStr = array[1];
        NSArray * dicArray = [dicStr componentsSeparatedByString:@"="];
        NSString * keyStr = dicArray[0];
        NSString * valuesStr = dicArray[1];
        
        OAFile * model = self.fileCountArray[indexPath.row];
        
        NSDictionary * dict;
        if ([self.getParametesUrlStr containsString:@"UploadAttach"]) {
            
            dict = @{
                     @"uploadUser"    : [OA_Tool userName],
                     @"name"          :  model.title,
                     keyStr : valuesStr
                     };

            
        }else{
            
            dict = @{
                    keyStr : valuesStr
                    };
        }
        
         NSLog(@"_获取的上传文件的名字____%@",model.title);

        if (self.upLoadUrlStr) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [ShowProgressView upLoadFileFromUrlStr:self.upLoadUrlStr withParametes:dict withOAFileModel:model successBlock:^{
                //TODO: 调用JS方法
                [self.webView stringByEvaluatingJavaScriptFromString:@"finishUploadBydoc();"];
                } errorInfoBlock:^(NSString *error) {
                    if (error.length>0) {
                        [MBProgressHUD showGlobalProgressHUDWithTitle:error hideAfterDelay:1.0];
                    }
                }];
            }];
            
        }else{
            [MBProgressHUD showGlobalProgressHUDWithTitle:@"上传失败" hideAfterDelay:1.0];
        }

        
    }
    
    
}
#pragma mark - 查看文件
-(void)startSeeFile:(NSIndexPath *)indexPath {

     OAFile * model = self.fileCountArray[indexPath.row];
    [[OAFileManager getInstance]openFile:model fromCurrentController:self];

}


-(void)backVC
{
     [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
