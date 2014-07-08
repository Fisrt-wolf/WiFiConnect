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

- (id)fetchSSIDInfo
{
    NSLog(@"-=-=-=-=-");
    NSArray *ifs = (id)CNCopySupportedInterfaces();
//    _currentWiFiBssid = [self getCurrentWiFiMacAddress];
    id info = nil;

    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info == nil) {
            SafeRelease(_currentWiFiBssid);
            _currentWiFiBssid = [@"NULL" retain];
            [self updateWiFiMacAddress:_currentWiFiBssid];
            break;
        }
        NSLog(@"current WiFi info : %@",info);
        if (![[info objectForKey:@"BSSID"] isEqualToString:_currentWiFiBssid]) {
            SafeRelease(_currentWiFiBssid);
            _currentWiFiBssid = [[info objectForKey:@"BSSID"] retain];
            [self updateWiFiMacAddress:_currentWiFiBssid];
            [self wifiChange:info];
            
        }
        
        if (info && [info count]) {
            break;
        }
        
        [info release];
    }
    [ifs release];
    return [info autorelease];
    
}


- (void)wifiChange:(NSDictionary *)wifiInfo
{
    NSString * tWiFiBssid = [[wifiInfo objectForKey:@"BSSID"] retain];
    SafeRelease(_preWiFiBssid);
    _preWiFiBssid = tWiFiBssid ;
//    NSLog(@"_preWiFiBssid : %@",_preWiFiBssid);
    sleep(3);
    [self fetchSSIDInfo];
    if ([_currentWiFiBssid isEqualToString:_preWiFiBssid]) {
//        [self currentWiFiChange:wifiInfo];
        [self performSelectorOnMainThread:@selector(currentWiFiChange:) withObject:wifiInfo waitUntilDone:NO];
    }
}


- (void)currentWiFiChange:(NSDictionary *)wifiInfo
{
    [delegate wiFiChange:wifiInfo];
}

- (NSString *)getCurrentWiFiMacAddress
{
    NSString * tCurrentWiFiMacAddress = @"";
    tCurrentWiFiMacAddress = [NSString stringWithContentsOfFile:WiFiFilePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"tCurrentWiFiMacAddress %@",tCurrentWiFiMacAddress);
    return tCurrentWiFiMacAddress;
}

- (void)updateWiFiMacAddress:(NSString *)macAddress
{
    [macAddress writeToFile:WiFiFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSString * str = [NSString stringWithContentsOfFile:WiFiFilePath encoding:NSUTF8StringEncoding error:nil];
}

@end
