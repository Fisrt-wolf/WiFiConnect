//
//  MonitorWiFi.m
//  WiFiConnect
//
//  Created by IOS on 14-6-6.
//  Copyright (c) 2014年 IOS. All rights reserved.
//
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MonitorWiFi.h"

@implementation MonitorWiFi

@synthesize delegate;

#pragma mark -
#pragma mark 获取当前连接的wifi信息
- (id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    
    id info = nil;
//    [self performSelectorOnMainThread:@selector(currentWiFiChange:) withObject:info waitUntilDone:NO];
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        
        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        
        if ([[info objectForKey:@""] isEqualToString:_currentWiFiBssid]) {
            [self performSelectorOnMainThread:@selector(currentWiFiChange:) withObject:info waitUntilDone:NO];
        }
        
        _currentWiFiBssid = [info objectForKey:@""];
        
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}


- (void)currentWiFiChange:(NSDictionary *)wifiInfo
{
    [delegate wiFiChange:wifiInfo];
}
@end
