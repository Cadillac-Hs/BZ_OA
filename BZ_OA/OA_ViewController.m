//
//  OA_ViewController.m
//  SchoolHelper
//
//  Created by ShenQiang on 16/7/18.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "OA_ViewController.h"
//#import "FirstViewController.h"
#import "OAFileBarButton.h"
#import "OAFileManager.h"
#import "OA_Tool.h"
#import "OAFileUpLoadListVC.h"

//#import "WLCircleProgressView.h"

#import "ShowProgressView.h"

#import "BZ_pch.h"
#import "OANotificationTool.h"
#import "AppDelegate.h"
@interface OA_ViewController ()<UIWebViewDelegate>

@property(nonatomic,strong)UIWebView * webView;
@property(nonatomic,copy)NSString * currentURL,*currentHTML;
@property(nonatomic,retain)UIButton * button;
@property(nonatomic,retain)UIButton * button2;

@property(nonatomic,strong)ShowProgressView * progressView;
//@property(nonatomic,strong)UIView * backView;
//@property(nonatomic,strong)WLCircleProgressView *circleProgress1;
//@property (nonatomic, strong) WLCircleProgressView *progressView1;

@end

@implementation OA_ViewController
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"123456" object:nil];
}

+(void)addLocalNotification :(NSString *)num
{
    UILocalNotification * noti = [[UILocalNotification alloc]init];
    NSDate * fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
    
    noti.fireDate = fireDate;
    noti.alertBody = [NSString stringWithFormat:@"您有%@条消息未读",num];
    noti.applicationIconBadgeNumber = [num intValue];
    
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"1" forKey:@"OA"];
    noti.userInfo = userDict;
    
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
        //        noti.repeatInterval = NSCalendarUnitDay;
    } else {
        // 通知重复提示的单位，可以是天、周、月
        //        noti.repeatInterval = NSDayCalendarUnit;
    }
    
    [USERDEFAULTS setObject:@"保存通知" forKey:@"saveNoti"];
    
    // 执行通知注册   docx
    [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
    
}
#pragma mark 取消本地通知
-(void)cancleNSNotification
{
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //便利这个数组 根据 key 拿到我们想要的 UILocalNotification
    for (UILocalNotification * loc in array) {
        if ([[loc.userInfo objectForKey:@"OA"] isEqualToString:@"1"]) {
            //取消 本地推送
            [[UIApplication sharedApplication] cancelLocalNotification:loc];
        }
    }
}

-(void)once
{
    static int a = 0;
    if (a==0) {
        UILocalNotification * noti = [[UILocalNotification alloc]init];
        
        // ios8后，需要添加这个注册，才能得到授权
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            // 通知重复提示的单位，可以是天、周、月
            //        noti.repeatInterval = NSCalendarUnitDay;
        } else {
            // 通知重复提示的单位，可以是天、周、月
            //        noti.repeatInterval = NSDayCalendarUnit;
        }
        
        // 执行通知注册
        [[UIApplication sharedApplication] scheduleLocalNotification:noti];
    }
    a++;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden = NO;
    
    self.view.backgroundColor = BACKCOLOR22;
    //添加通知
    [self once];
    
    if ([OA_Tool userId]) {
        
        [USERDEFAULTS setObject:@"开启通知" forKey:@"KaiQi"];
        [USERDEFAULTS synchronize];
        
    }
    
   
    
    [self cancleNSNotification];
    [OANotificationTool stopFetchingNotification];
    
    
    self.webView =[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    //去掉webview 上的 滚动条
    for (UIView * views in [self.webView subviews]) {
        if ([views isKindOfClass:[UIScrollView class]]) {
            //去掉水平方向的滑动条
            [(UIScrollView *)views setShowsHorizontalScrollIndicator:NO];
            //去掉垂直方向的滑动条
            [(UIScrollView *)views setShowsVerticalScrollIndicator:NO];
            for (UIView * inScrollView in views.subviews) {
                if ([inScrollView isKindOfClass:[UIImageView class]]) {
                    //隐藏上下滚动出边界时的黑色的图片
                    inScrollView.hidden = YES;
                }
            }
        }
    }
    NSLog(@"__WEB=userId--------__%@",[OA_Tool userId]);

    if ([OA_Tool userId].length>0 && [OA_Tool userId].length>0) {
        
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:[WEB_BASE_URL stringByAppendingString:WEBVIEWURL],[OA_Tool userId],[OA_Tool token]]];
        NSLog(@"__WEB--------__%@",url);
        NSURLRequest * urlRequest = [[NSURLRequest alloc]initWithURL:url];
        [self.webView loadRequest:urlRequest];
        self.webView.delegate = self;
        [self.view addSubview:self.webView];
        
    }
    //增加导航栏的内容
    [self addNavSubviews];


    
    [OAFileManager getInstance].sharedVC.badgeBlock = ^(NSInteger count) {
        
        [self updateRightBarButtonBadgeCount:count];
    };
}
//导航上的内容
- (void)addNavSubviews{
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //左按钮
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 20, 30, 30);
    [self.button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.button setImage:[UIImage imageNamed:@"fx_03"] forState:UIControlStateNormal];
    UIBarButtonItem * leftBtn = [[UIBarButtonItem alloc]initWithCustomView:self.button];
    self.button.hidden = YES;
    
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    self.title = @"移动办公";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    self.navigationController.navigationBar.barTintColor = kColorWithRGB(97, 120, 243);

    OAFileBarButton *rightItem = [OAFileBarButton fileBarButton];
    [rightItem addTarget:self action:@selector(clickSeeDownLoadList) forControlEvents:UIControlEventTouchUpInside];
    [rightItem setIconImage:[UIImage imageNamed:@"xiazai"]];
    

    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rightItem];

    self.navigationItem.rightBarButtonItem = rightBtn;
}

-(void)clickSeeDownLoadList
{
    OAFileListVC * vc = [OAFileManager getInstance].sharedVC;
    
    [self.navigationController pushViewController:vc animated:YES];
}


//用苹果自带的返回键按钮处理如下(自定义的返回按钮)
- (void)back:(UIBarButtonItem *)btn
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        
    }else{
        [self.view resignFirstResponder];
//        [self.navigationController popViewControllerAnimated:YES];
    }
}


//如果是H5页面里面自带的返回按钮处理如下:
#pragma mark - webViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString * requestString = [[request URL] absoluteString];
    requestString = [requestString stringByRemovingPercentEncoding];
     NSLog(@"___----__进入webview了------%@",requestString);
    
         NSLog(@"这个字符串中有----------**********a");
        if ([requestString containsString:@"DownLoadStanderDoc"] || [requestString containsString:@"DownLoadMainDoc"] || [requestString containsString:@"FileServlet"]) {
            
            if ([requestString containsString:@"Temp"]) {
                
                [[OAFileManager getInstance] showActionSheetFronController:self actionTitle:@"下载文件" target:self action:@selector(startDownloadWithUrlString:) actionParameter:[requestString stringByReplacingOccurrencesOfString:@"Temp" withString:@""]];
            }

        return NO;
    }
    //上传正文
    if ([requestString containsString:@"UploadZW"]) {
        
        OAFileUpLoadListVC * vc = [[OAFileUpLoadListVC alloc]init];
        vc.getParametesUrlStr = requestString;
        vc.upLoadUrlStr = [WEB_BASE_URL stringByAppendingString:WEB_PARAMETESURL];
        vc.webView = self.webView;
        vc.fileTypeStr = @"doc";
        [self presentViewController:vc animated:YES completion:nil];
        return NO;
        
    }
    //上传板式正文
    if ([requestString containsString:@"UploadBSZW"]) {
        
        OAFileUpLoadListVC * vc = [[OAFileUpLoadListVC alloc]init];
        vc.getParametesUrlStr = requestString;
        vc.upLoadUrlStr = [WEB_BASE_URL stringByAppendingString:WEB_URL_UPLOAD];//;
        vc.webView = self.webView;
        vc.fileTypeStr = @"pdf";
        [self presentViewController:vc animated:YES completion:nil];
        return NO;
        
    }
    //上传附件
    if ([requestString containsString:@"UploadAttach"]) {
        
        OAFileUpLoadListVC * vc = [[OAFileUpLoadListVC alloc]init];
        vc.getParametesUrlStr = requestString;
        vc.upLoadUrlStr = [WEB_BASE_URL stringByAppendingString:WEB_URL_UPLOAD_FUJIAN];//;
        vc.webView = self.webView;
        vc.fileTypeStr = @"allType";
        [self presentViewController:vc animated:YES completion:nil];
        return NO;
        
    }
    
    //监听是否点击了退出界面
    if ([requestString containsString:@"LoginOut"]) {
        
        
        [self outGoLogin];
        return NO;
        
    }
    
    //获取H5页面里面按钮的操作方法,根据这个进行判断返回是内部的还是push的上一级页面
    if ([requestString hasPrefix:@"goback:"]) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self.webView goBack];
        
    }
    if ([requestString containsString:@"Home/Index"]) {
        self.button.hidden = YES;
    }else{
        self.button.hidden = NO;
    }
    
    return YES;
}

- (void)startDownloadWithUrlString:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    [[OAFileManager getInstance] downloadFileFromURL:url];
    
    [self updateRightBarButtonBadgeCount:[OAFileManager getInstance].downloadArray.count];
   
}

- (void)updateRightBarButtonBadgeCount:(NSInteger)count {
    
    OAFileBarButton *rightItem = (OAFileBarButton *)self.navigationItem.rightBarButtonItem.customView;
    
    [rightItem setBadgeCount:(int)count];

}

#pragma mark - 退出登录
//-(void)loginOut{
//
//
//    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"是否退出登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction * cancel              = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [alertController addAction:cancel];
//    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//        //删除 OA 的存储的信息
//        [OA_Tool delegateOA_Path];
//    
//    }];
//    [alertController addAction:ok];
//    [self presentViewController:alertController animated:YES completion:nil];
//    
//
//}
// 退出到登录最初界面
-(void)outGoLogin
{
    //删除 OA 的存储的信息
    [OA_Tool delegateOA_Path];
    [(AppDelegate *)[UIApplication sharedApplication].delegate switchVCToLogin];
   
}
//获取当前页面的title和url
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    NSString * title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];//获取当前页面的title
    self.title = title;
    //获取当前网页的html
    self.currentURL = webView.request.URL.absoluteString;
    NSLog(@"title-%@--url-%@--",self.title,self.currentURL);
    NSString *lJs = @"document.documentElement.innerHTML";
    self.currentHTML = [webView stringByEvaluatingJavaScriptFromString:lJs];
    
//    NSLog(@"___html___%@",self.currentHTML);

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
