//
//  PhoneLoginVC.m
//  SchoolHelper
//
//  Created by ShenQiang on 16/7/27.
//  Copyright © 2016年 SEN. All rights reserved.
//

#import "PhoneLoginVC.h"
#import "MJ_HttpManager.h"
#import "MBProgressHUD+Tools.h"
#import "BZ_pch.h"
#import "Tool.h"
#import "OA_ViewController.h"
//#import "TAHTTPManager.h"

//线的颜色
#define  lineBackColor [Tool getColor:@"a5a5a5"]

@interface PhoneLoginVC ()<UITextFieldDelegate>
{
    MBProgressHUD * HUD,*HUD2;
    
    BOOL        isExist;
    
    NSTimer * timer;
    long   seconds;
    BOOL isPhoneLogin;
    
    UIButton * button;
    UIButton * phoneBtn;
}
@property(nonatomic,retain)UITextField * phoneField;
@property(nonatomic,retain)UITextField * textField;
//@property(nonatomic,retain)UIButton * button;
@property(nonatomic,retain)UIButton * loginBtn;
@end

@implementation PhoneLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKCOLOR22;
    self.navigationController.navigationBar.hidden = YES;
    
    
    
    //自定义导航标题
    UILabel *title = [[UILabel alloc] init];
    title.backgroundColor = [UIColor clearColor];
    title.frame = CGRectMake(WIDTH/2-80, 25, 160, 18);//[FrameAutoScaleLFL CGLFLMakeX:0 Y:20 width:WIDTH height:44];
    title.textColor = kColorWithRGB(44, 135, 250);
    title.font = [UIFont systemFontOfSize:17];
    title.textAlignment = NSTextAlignmentCenter;
    //    title.textColor = [UIColor whiteColor];//kColorWithRGB(80, 80, 80);
    [self.view addSubview:title];
    title.text = @"手机验证登录";

    //自定义导航返回按钮
    UIImageView * imgBack = [[UIImageView alloc]initWithFrame: CGRectMake(15, 24, 12, 20)];
    imgBack.image = [UIImage imageNamed:@"fx_301"];
//    UIImage *loginImg = [UIImage imageNamed:@"形状-12"];
//    loginImg = [loginImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    imgBack.image =  loginImg;
    [self.view addSubview:imgBack];
    
    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 24, 40, 20);
    [backBtn setImage:[UIImage imageNamed:@"fx_031"] forState:UIControlStateNormal];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn addTarget:self action:@selector(backVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    
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
    
    
    
    
    self.phoneField = [[UITextField alloc]initWithFrame:CGRectMake(30, 54+68+HEIGHT/5.8-60, 200, 60)];
    self.phoneField.placeholder = @"请输入手机号";
    self.phoneField.delegate = self;
    self.phoneField.tag = 100;
    self.phoneField.keyboardType = UIKeyboardTypeNumberPad;
    //    self.userNameTextField.textAlignment = NSTextAlignmentCenter;
    [self.phoneField setValue:[Tool getColor:@"a5a5a5"] forKeyPath:@"_placeholderLabel.textColor"];
    [self.phoneField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:self.phoneField];
    
    //获取验证码
    phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneBtn.bounds = CGRectMake(0, 0, 100-30, 30);
    phoneBtn.center =CGPointMake(WIDTH-30-30, self.phoneField.center.y);
    phoneBtn.layer.borderWidth = 0.5;
    phoneBtn.layer.borderColor = [kColorWithRGB(44, 135, 250) CGColor];
    phoneBtn.layer.cornerRadius = 3.0;
    phoneBtn.clipsToBounds = YES;
    [phoneBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    phoneBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [phoneBtn setTitleColor:kColorWithRGB(44, 135, 250) forState:UIControlStateNormal];
    [self.view addSubview:phoneBtn];
    [phoneBtn addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField = [[UITextField alloc]initWithFrame:CGRectMake(15+15, 54+68+HEIGHT/5.8+156/2-60, 200, 60)];
    //    self.passwordTextField.textAlignment = NSTextAlignmentCenter;
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.textField.delegate = self;
    self.textField.tag = 101;
    self.textField.placeholder = @"请输入验证码";
    [self.textField setValue:[Tool getColor:@"a5a5a5"] forKeyPath:@"_placeholderLabel.textColor"];
    [self.textField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:self.textField];
    
    
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

}
#pragma mark - 获取验证码
-(void)getCode
{
    if (_phoneField.text.length !=11 ) {
        
        [MBProgressHUD showGlobalProgressHUDWithTitle:@"手机号有误" hideAfterDelay:1.0];
        
    }else{
        //改变验证码的状态
        //发送验证码时的倒计时-----点击后就会有倒计时
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        seconds = 60;
        
        
        NSDictionary * dict = @{
                                @"loginType" : @"0" ,
                                @"userTel" : _phoneField.text,
                                };
        [self requestGetCode:dict];
    }
}

#pragma mark  验证码的请求方法
-(void)requestGetCode:(NSDictionary *)dic{
    [[MJ_HttpManager getSingleClass] loginAuthorizationWithTeacherGetPhoneCodeParameters:dic resultBlock:^(int isSuccess, NSString *message, NSError *error) {
        
        if (isSuccess == 0) {
            [MBProgressHUD showGlobalProgressHUDWithTitle:@"验证码已发送" hideAfterDelay:1.5];
            
        }
         if (isSuccess== -1){
            [MBProgressHUD showGlobalProgressHUDWithTitle:@"此号码未绑定身份"  hideAfterDelay:1.5];
        }
//
        if (isSuccess== -100){
            [MBProgressHUD showGlobalProgressHUDWithTitle:@"请求失败" hideAfterDelay:1.f];
        }
    }];
}


#pragma mark  登录
-(void)loginClick
{
    if (_phoneField.text.length !=11 ) {
        
        [MBProgressHUD showGlobalProgressHUDWithTitle:@"手机号有误" hideAfterDelay:1];
        
    }else if (_textField.text.length !=6){
        [MBProgressHUD showGlobalProgressHUDWithTitle:@"验证码有误" hideAfterDelay:1];
    }else{
        
        [MBProgressHUD showGlobalProgressHUDWithTitle:@"正在登录..."];
        
        NSDictionary * dict = @{
                                @"loginType" : @"1" ,
                                @"userTel" : _phoneField.text,
                                @"checkCode" : _textField.text
                                };
        [self requestLogin:dict];
    }
    
}
#pragma mark 登录请求
-(void)requestLogin:(NSDictionary *)dic
{
    [[MJ_HttpManager getSingleClass] loginAuthorizationWithTeacherPhoneLoginParameters:dic resultBlock:^(int isSuccess, NSString *message, NSDictionary *dic, NSError *error) {
        [MBProgressHUD dismissGlobalHUD];
        if (isSuccess == 0) {
            
            OA_ViewController * vc  =[[OA_ViewController alloc]init];
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:vc];
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = nav;
        }
        if (isSuccess == -1){
            [MBProgressHUD showGlobalProgressHUDWithTitle:@"登录失败" hideAfterDelay:1.5f];
        }
        if (isSuccess == -100){
            [MBProgressHUD showGlobalProgressHUDWithTitle:@"请求失败" hideAfterDelay:1.5f];
        }
        
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark---delegate--TextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 100) {
        if (_phoneField.text.length>10 && range.length!=1) {
            NSString * sss =[_phoneField.text stringByReplacingCharactersInRange:range withString:string];
            _phoneField.text =[sss substringToIndex:11];
            return NO;
            
        }
    }else{
        if(_textField.text.length>5 && range.length!=1){
            NSString * sss =[_textField.text stringByReplacingCharactersInRange:range withString:string];
            _textField.text =[sss substringToIndex:6];
            return NO;
        }
    }
    
    return YES;
}
//输入的内容必须是 0-9 的数字
- (BOOL)validateRange:(NSRange)range Number:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}
//倒计时方法验证码实现倒计时60秒，60秒后按钮变换开始的样子
-(void)timerFireMethod:(NSTimer *)theTimer {
    if (seconds == 1) {
        isExist = NO;
        [theTimer invalidate];
        seconds = 60;
        phoneBtn.layer.borderWidth = 0.5;
        phoneBtn.layer.borderColor = [kColorWithRGB(44, 135, 250) CGColor];
        phoneBtn.layer.cornerRadius = 3.0;
        phoneBtn.clipsToBounds = YES;
        phoneBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [phoneBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [phoneBtn setTitleColor:kColorWithRGB(44, 135, 250) forState:UIControlStateNormal];
        phoneBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        phoneBtn.backgroundColor = [UIColor clearColor];
        [phoneBtn setEnabled:YES];
        
    }else{
        isExist = YES;
        seconds=seconds-1;
        NSString *title = [NSString stringWithFormat:@"%ld秒后请重试",seconds];
        phoneBtn.backgroundColor = [UIColor grayColor];
        phoneBtn.titleLabel.font = [UIFont systemFontOfSize:9];
//        phoneBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [phoneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [phoneBtn setEnabled:NO];
        [phoneBtn setTitle:title forState:UIControlStateNormal];
    }
}
//如果登陆成功，停止验证码的倒数，
- (void)releaseTImer {
    if (timer) {
        if ([timer respondsToSelector:@selector(isValid)]) {
            if ([timer isValid]) {
                [timer invalidate];
                seconds = 60;
            }
        }
    }
}

//登录按钮
//-(void)loginClick
//{
//    //验证码已发送，取消掉
//    [HUD removeFromSuperview];
//    
//    //    if (self.schoolStr.length<1) {
//    //        HUD2.labelText = @"请选择您要进入的单位";
//    //        HUD2.labelColor =kColorWithRGB(200, 200, 200);
//    //        HUD2.mode = MBProgressHUDModeText;
//    //        HUD2.yOffset = 100.0f;
//    //        [HUD2 showAnimated:YES whileExecutingBlock:^{
//    //            sleep(2);
//    //        } completionBlock:^{
//    //            [HUD2 removeFromSuperview];
//    //            //            HUD = nil;
//    //        }];
//    //
//    //    }
//    //[tool isMobileNumber:_phoneField.text]==NO
//        
//        if ([tool isMobileNumber:_phoneField.text]==NO&&![_phoneField.text isEqualToString:@"99991111111"]&&![_phoneField.text isEqualToString:@"99992222222"]&&![_phoneField.text isEqualToString:@"99990000000"]) {
//            [self userID];
//        }
//        else  if (_textField.text.length==0) {
//            [self password];
//        }else{
//            [self dengluYanZheng];
//        }
//}
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
