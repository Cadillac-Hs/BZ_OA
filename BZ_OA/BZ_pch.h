//
//  BZ_pch.h
//  BZ_OA
//
//  Created by ShenQiang on 16/8/10.
//  Copyright © 2016年 SEN. All rights reserved.
//

#ifndef BZ_pch_h
#define BZ_pch_h

#define kColorWithRGB(r, g, b) [UIColor colorWithRed:(r) / 255.f green:(g) / 255.f blue:(b) / 255.f alpha:1.f]
//导航条的颜色
#define OA_NavgationBarBackGroundColor [UIColor colorWithRed:114/255.0 green:134/255.0 blue:238/255.0 alpha:1.0f]
//背景颜色22
#define BACKCOLOR22 kColorWithRGB(243, 248, 254)//kColorWithRGB(209, 213, 218)//
////基础的url
//#define LOGINBASEURL @"http://192.168.191.1/gz_ssos/IMobileLoginHandler.ashx?"   /

#define WEB_BASE_URL @"http://192.168.0.154/BZWEBAPP.UI/"

//获取本地通知时,请求服务器的url
#define GET_NOTIFICATION_URL @"WebAPI/GetNoticeToPhone"

//进入OA的h5页面时,需要请求的url
#define WEBVIEWURL @"Login/Index?userid=%@&token=%@"

#define WEB_PARAMETESURL      @"WebAPI/UploadMainDoc"      // 上传正文
#define WEB_URL_UPLOAD        @"WebAPI/UploadStandardDoc" //上传正式版
#define WEB_URL_UPLOAD_FUJIAN @"WebAPI/UploadAttachDoc" //上传附件



#define WINDOW [UIScreen mainScreen]

#define WIDTH WINDOW.bounds.size.width
#define HEIGHT WINDOW.bounds.size.height

#define USERDEFAULTS [NSUserDefaults standardUserDefaults]

#endif /* BZ_pch_h */
