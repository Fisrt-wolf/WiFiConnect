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

@interface MainViewCtl : UIViewController<MonitorWiFiDelegate,UIWebViewDelegate,LocationDelegate,CLLocationManagerDelegate>
{
    MonitorWiFi * _monitorWifi;
    NSTimer     * _timer;
    Location    * _location;
    NSDictionary* _wifiInfo;
}

@property(strong,nonatomic)IBOutlet UITextView * wifiInfoView;
@property(strong,nonatomic)IBOutlet UITextView * wifiRequestInfoView;
@property(strong,nonatomic)IBOutlet UIWebView  * webView ;
@property(strong,nonatomic)IBOutlet UIActivityIndicatorView * activityIndicatorView;
@property (strong, nonatomic) CLLocationManager* locationManager;

- (void)monitorWiFi;
- (IBAction)downloadConfigFile:(id)sender;


@end
