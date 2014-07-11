//
//  MainViewCtl.h
//  WiFiConnect
//
//  Created by IOS on 14-6-6.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MonitorWiFi.h"
#import "Location.h"
#import "ShopViewCtl.h"

@interface MainViewCtl : UIViewController<MonitorWiFiDelegate,UIWebViewDelegate,LocationDelegate>
{
    MonitorWiFi * _monitorWifi;
    NSTimer     * _timer;
    Location    * _location;
    NSDictionary* _wifiInfo;
    ShopViewCtl * _shopViewCtl;
}

@property(strong,nonatomic)IBOutlet UILabel    * connectWiFiLabel;
@property(strong,nonatomic)IBOutlet UITextView * wifiInfoView;
@property(strong,nonatomic)IBOutlet UIWebView  * webView ;
@property(strong,nonatomic)IBOutlet UIActivityIndicatorView * activityIndicatorView;

- (void)monitorWiFi;
- (void)showShopView:(NSDictionary *)userInfo;
- (IBAction)downloadConfigFile:(id)sender;



@end
