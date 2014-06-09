//
//  MonitorWiFi.h
//  WiFiConnect
//
//  Created by IOS on 14-6-6.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

@protocol MonitorWiFiDelegate <NSObject>

- (void)wiFiChange:(NSDictionary *)wifiInfo;

@end

#import <Foundation/Foundation.h>


@interface MonitorWiFi : NSObject
{
    NSString * _currentWiFiBssid;
}

@property(strong,nonatomic)id<MonitorWiFiDelegate> delegate;

- (id)fetchSSIDInfo;

@end
