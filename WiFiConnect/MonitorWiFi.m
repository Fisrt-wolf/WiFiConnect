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
- (id)init
{
    self = [super init];
    if (self != nil) {
        _currentWiFiBssid = [[NSString alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    SafeRelease(_currentWiFiBssid);
}

- (void)fetchSSIDInfo
{
    NSDictionary * tWiFiInfo = [self getWiFiInfo];
    MyNSLog(tWiFiInfo);
    _currentWiFiBssid = [self getCurrentWiFiMacAddress];
    NSString * tWiFiSSid = [tWiFiInfo objectForKey:@"BSSID"];
    if (nil == tWiFiInfo) {
        tWiFiSSid = @"";
    }
    if (![tWiFiSSid isEqualToString:_currentWiFiBssid]) {
        
        [self updateWiFiMacAddress:tWiFiSSid];
        
        [self wifiChange:tWiFiInfo];
    }
}


// ---  获取当前连接上得wifi信息  ---
- (id)getWiFiInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    id info = nil;
    
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        
        if (info && [info count]) {
            break;
        }
    }
    [ifs release];
    return [info autorelease];
}


- (void)wifiChange:(NSDictionary *)wifiInfo
{
    NSString * tWiFiBssid = [[wifiInfo objectForKey:@"BSSID"] retain];
    sleep(3);
    NSString * tCurrentWiFiBssid = [[self getWiFiInfo] objectForKey:@"BSSID"];
    
    if ([tCurrentWiFiBssid isEqualToString:tWiFiBssid])
    {
        [self performSelectorOnMainThread:@selector(currentWiFiChange:) withObject:wifiInfo waitUntilDone:NO];
    }
    else if (tCurrentWiFiBssid == nil && nil == tWiFiBssid)
    {
        [self performSelectorOnMainThread:@selector(currentWiFiChange:) withObject:wifiInfo waitUntilDone:NO];
    }
    
    if (nil == tCurrentWiFiBssid) {
        tCurrentWiFiBssid = @"";
    }
    
    [self updateWiFiMacAddress:tCurrentWiFiBssid];
}


- (void)currentWiFiChange:(NSDictionary *)wifiInfo
{
    [delegate wiFiChange:wifiInfo];
}

- (NSString *)getCurrentWiFiMacAddress
{
    NSString * tCurrentWiFiMacAddress = @"";
    tCurrentWiFiMacAddress = [NSString stringWithContentsOfFile:WiFiFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString * str = [NSString stringWithFormat:@"tCurrentWiFiMacAddress %@",tCurrentWiFiMacAddress];
    MyNSLog(str);
    return tCurrentWiFiMacAddress;
}

- (void)updateWiFiMacAddress:(NSString *)macAddress
{
    [macAddress writeToFile:WiFiFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSString * str = [NSString stringWithContentsOfFile:WiFiFilePath encoding:NSUTF8StringEncoding error:nil];
}

@end
