//
//  MainViewCtl.h
//  WiFiConnect
//
//  Created by IOS on 14-6-6.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MonitorWiFi.h"

@interface MainViewCtl : UIViewController<MonitorWiFiDelegate>
{
    MonitorWiFi * _monitorWifi;
}

@property(strong,nonatomic)IBOutlet UILabel * wifiInfoLabel;

- (IBAction)downloadConfigFile:(id)sender;


@end
