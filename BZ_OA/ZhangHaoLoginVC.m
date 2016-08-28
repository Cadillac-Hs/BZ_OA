//
//  ZhangHaoLoginVC.m
//  SchoolHelper
//
//  Created by ShenQiang on 16/7/27.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "ZhangHaoLoginVC.h"
#import "PhoneLoginVC.h"
#import "OA_ViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "MJ_HttpManager.h"
#import "MBProgressHUD+Tools.h"

#import "Tool.h"
#import "BZ_pch.h"

#define MARGIN_KEYBOARD 20

//线的颜色
#define  lineBackColor [Tool getColor:@"a5a5a5"]

@interface ZhangHaoLoginVC ()<UITextFieldDelegate>
{
    
    UIButton * seeCode;
}
@property(nonatomic,retain)UITextField * userNameTextField;
@property(nonatomic,retain)UITextField * passwordTextField;

@property(nonatomic,retain)UIButton * loginBtn;
@end

@implementation ZhangHaoLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = NO;

    
    self.view.backgroundColor = BACKCOLOR22;
    self.navigationController.navigationBar.hidden = YES;
    
    
    
    //上部的图片- 协同办公
    UIImageView * imgViewTop = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2-50.5, 52, 101, 68)];
    imgViewTop.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:imgViewTop];
    
    //下部的图片- 协同办公
    UIImageView * imgViewBottom = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2-89, HEIGHT-HEIGHT/12.2, 178, 23)];
    imgViewBottom.image = [UIImage imageNamed:@"xietongbangong"];
    [self.view addSubview:imgViewBottom];

    UILabel * lineLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 54+68+HEIGHT/5.8, WIDTH-30, 1)];
    lineLab.backgroundColor = lineBackColor;
    [self.view addSubview:lineLab];
    
    UILabel * lineLab2 = [[UILabel alloc]initWithFrame:CGRectMake(15, 54+68+HEIGHT/5.8+156/2, WIDTH-30, 1)];
    lineLab2.backgroundColor = lineBackColor;
    [self.view addSubview:lineLab2];
    
    
    UILabel * userNameLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 54+68+HEIGHT/5.8-60-1, 60, 60)];
    userNameLab.text = @"账号";
    userNameLab.textColor = [UIColor blackColor];
    userNameLab.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:userNameLab];
    
    self.userNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(36+6.5+26, 54+68+HEIGHT/5.8-60, WIDTH-(36+6.5+26)-15, 60)];
    self.userNameTextField.placeholder = @"请输入账号";
    self.userNameTextField.delegate = self;
    self.userNameTextField.clearButtonMode = UITextFieldViewModeAlways;
    [self.userNameTextField setValue:[Tool getColor:@"a5a5a5"] forKeyPath:@"_placeholderLabel.textColor"];
    [self.userNameTextField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:self.userNameTextField];
    
    

    
    UILabel * passwordLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 54+68+HEIGHT/5.8+156/2-60-1, 60, 60)];
    passwordLab.text = @"密码";
    passwordLab.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:passwordLab];
    
    self.passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(36+6.5+26, 54+68+HEIGHT/5.8+156/2-60, WIDTH-(36+6.5+26)-40-10, 60)];
   
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.passwordTextField.placeholder = @"请输入密码";
    [self.passwordTextField setValue:lineBackColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordTextField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:self.passwordTextField];
    
    //是否查看密码
    
    CGFloat x = CGRectGetMaxX(self.passwordTextField.frame) + 20;
    
    seeCode = [UIButton buttonWithType:UIButtonTypeCustom];
    seeCode.bounds = CGRectMake(0, 0, 40, 30);
    seeCode.center = CGPointMake(x, self.passwordTextField.center.y);
    [seeCode setImage:[[UIImage imageNamed:@"biyan"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [seeCode setImage:[[UIImage imageNamed:@"eye"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [seeCode addTarget:self action:@selector(selectShowCode) forControlEvents:UIControlEventTouchUpInside];
    seeCode.tintColor = kColorWithRGB(44, 135, 250);
    [self.view addSubview:seeCode];
    
    //登录按钮
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn.layer.cornerRadius = 3.0;
    self.loginBtn.clipsToBounds = YES;
    self.loginBtn.frame = CGRectMake(30, 54+68+HEIGHT/5.8+156/2+146/2, WIDTH-60, 50);
    self.loginBtn.backgroundColor = kColorWithRGB(44, 135, 250);
//    self.loginBtn.backgroundColor = [RequestTools getColor:@"dfdfdf"];
    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginBtn addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginBtn];
    
    
    UIButton * phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneBtn.frame = CGRectMake(WIDTH-120, 54+68+HEIGHT/5.8+156/2+10, 120-30, 40);
    [phoneBtn setTitle:@"手机验证登录" forState:UIControlStateNormal];
    phoneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [phoneBtn setTitleColor:kColorWithRGB(44, 135, 250) forState:UIControlStateNormal];
    [self.view addSubview:phoneBtn];
    [phoneBtn addTarget:self action:@selector(phoneLogin) forControlEvents:UIControlEventTouchUpInside];
   
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;

}
//点击查看密码 及隐藏密码
-(void)selectShowCode
{
    seeCode.selected = !seeCode.selected;
    [self.passwordTextField endEditing:YES];
    self.passwordTextField.secureTextEntry = !seeCode.selected;
    [self.passwordTextField becomeFirstResponder];
}
-(void)phoneLogin
{
    PhoneLoginVC * vc = [[PhoneLoginVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)loginClick{
    
    if (self.userNameTextField.text.length ==0) {
        
        [MBProgressHUD showGlobalProgressHUDWithTitle:@"请输入账号" hideAfterDelay:1.f];
        
    }else if (self.passwordTextField.text.length==0){
    
        [MBProgressHUD showGlobalProgressHUDWithTitle:@"请输入密码" hideAfterDelay:1.f];
        
    }else{
        
        [MBProgressHUD showGlobalProgressHUDWithTitle:@"正在登录..."];
        
        NSString * userName =  self.userNameTextField.text;
        NSString * password =  self.passwordTextField.text;
        
        if (userName) {
            if (password) {
               
                //GET 方法
                NSDictionary * dic = @{
                                       @"loginType" : @"4",
                                       @"userName" :  userName,
                                       @"password" :  password
                                       
                                       };
                
                [self loginClick2:dic];

                
            }
        }
        
        
        
    }
    
}
//教师登录的时候
-(void)loginClick2:(NSDictionary *)dic
{
    [[MJ_HttpManager getSingleClass] loginAuthorizationWithTeacherParameters:dic resultBlock:^(int isSuccess, NSString *message, NSError *error) {
        
        [MBProgressHUD dismissGlobalHUD];
        
        if (isSuccess==0) {
            
           NSNumber * time =  [Tool currentTimestampWithLongLongFormat];
            NSLog(@"时间戳 : %@",time);
            
            OA_ViewController * vc  =[[OA_ViewController alloc]init];
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:vc];
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = nav;
            
        } if (isSuccess== -1) {
            
            [MBProgressHUD showGlobalProgressHUDWithTitle:message hideAfterDelay:1.f];
        }
        if (isSuccess== -100){
             [MBProgressHUD showGlobalProgressHUDWithTitle:@"请求失败" hideAfterDelay:1.f];
        }

    }];
}
-(void)backVC
{
    [self.navigationController popViewControllerAnimated:YES];
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
