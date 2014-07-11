//
//  MainViewCtl.m
//  WiFiConnect
//
//  Created by IOS on 14-6-6.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import "MainViewCtl.h"
#import "MonitorWiFi.h"
#import <CommonCrypto/CommonDigest.h> 
#import "ASIFormDataRequest.h"
#import "APService.h"
#import "Common.h"

@interface MainViewCtl ()

@end

@implementation MainViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _monitorWifi = [[MonitorWiFi alloc] init];
        _monitorWifi.delegate = self;
        _location = [[Location alloc] init];
        _location.delegate = self;
        _wifiInfo = [[NSDictionary alloc] init];

    }
    return self;
}

-(void)handleMaxShowTimer:(NSTimer *)theTimer
{
    MyNSLog(@"handle Max Show Timer");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)monitorWiFi
{
    _monitorWifi.delegate = self;
    [_monitorWifi fetchSSIDInfo];
}


- (void)showShopView:(NSDictionary *)userInfo
{
        if ( nil == _shopViewCtl ) {
            _shopViewCtl = [[ShopViewCtl alloc] initWithNibName:@"ShopInfoView" bundle:nil];
        }
    
        UIViewController * viewCtl = [[self navigationController] visibleViewController];
        if (viewCtl == _shopViewCtl) {
            return;
        }
        _shopViewCtl.hidesBottomBarWhenPushed = NO;
        [[self navigationController] pushViewController:_shopViewCtl animated:YES];
        [[self navigationController] setNavigationBarHidden:NO];
        _shopViewCtl.title = @"商家名称";
}

-(void)loadView
{
    [super loadView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
    SafeRelease(_monitorWifi);
    SafeRelease(_wifiInfo);
    SafeRelease(_location);
}

- (IBAction)downloadConfigFile:(id)sender
{
    [self downloadWiFiConfigFile];
}

#pragma mark -
#pragma mark 下载wifi相关的描述文件
- (void)downloadWiFiConfigFile
{
    if ([WiFiConfigFile isEqualToString:@""]) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WiFiConfigFile]];
}


#pragma mark -
#pragma mark delegate

- (void)wiFiChange:(NSDictionary *)wifiInfo
{
    [wifiInfo retain];
    SafeRelease(_wifiInfo);
    _wifiInfo = wifiInfo;
    
    [self showCurrentWifiInfo];
    if (nil != wifiInfo) {
        [_location location];
    }
    
}

#pragma mark -
#pragma mark location delegate
- (void)getCurrentLocation:(CLLocation *)curLocation
{
    [self uploadData];
    NSString * str = [NSString stringWithFormat:@"current location: %@",curLocation];
    MyNSLog(str);
}

// ---  更新界面上当前WiFi的显示信息  ---

- (void)showCurrentWifiInfo
{
//    NSString * tWifiInfo = [NSString stringWithFormat:@" SSID : %@\n Mac Address : %@\n ",[_wifiInfo objectForKey:@"SSID"],[_wifiInfo objectForKey:@"BSSID"]];
//    [self.wifiInfoView setText:tWifiInfo];
    NSString * tWiFiSSidInfo = [NSString stringWithFormat:@"已连接:%@",[_wifiInfo objectForKey:@"SSID"]];
    if (nil == _wifiInfo) {
        tWiFiSSidInfo = @"未连接";
    }
    [self.connectWiFiLabel setText:tWiFiSSidInfo];
}

// ---  上传数据  ---

- (void)uploadData
{
    long long int  tBassidDecimal = [[Common shareCommon] convertMacAdressToDecimal:[_wifiInfo objectForKey:@"BSSID"]];
    NSString * tRegisterId = [APService registrionID];
    NSString * tRequestUrlStr = [NSString stringWithFormat:@"%@%lld&registration_id=%@&mobile=1",HttpRoot,tBassidDecimal,tRegisterId];
    [self.activityIndicatorView setHidden:NO];
    [self requestWithUrlStr:tRequestUrlStr];
}


#pragma mark -
#pragma mark MD5 加密
- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    
    unsigned char result[16];
    
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    
    return [NSString stringWithFormat:
            
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            
            result[0], result[1], result[2], result[3],
            
            result[4], result[5], result[6], result[7],
            
            result[8], result[9], result[10], result[11],
            
            result[12], result[13], result[14], result[15]
            
            ];
}


#pragma mark -
#pragma mark 提交数据
- (void)requestFinish:(ASIHTTPRequest *)request
{
    
    NSData * data = [request responseData];
    data = [[Common shareCommon] convertXmlDataToUtf8:data];
    NSString * tWifiInfoStr = @"";
    if (nil == data) {
        tWifiInfoStr = @"This WiFi is not recognize;";
    }else{
        NSDictionary *tWifiInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        tWifiInfoStr = [NSString stringWithFormat:@" SSID : %@\n Password : %@\n ",[tWifiInfo objectForKey:@"name"],[tWifiInfo objectForKey:@"pwd"]];
    }
}

- (void)requestWithUrlStr:(NSString *)urlStr{
    
    ASIFormDataRequest * _getCloudFileListRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [_getCloudFileListRequest setStringEncoding:NSUTF8StringEncoding];
    [_getCloudFileListRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
    _getCloudFileListRequest.delegate = self;
    [_getCloudFileListRequest setDidFinishSelector:@selector(requestFinish:)];
    [_getCloudFileListRequest setNumberOfTimesToRetryOnTimeout:3];
    
    [_getCloudFileListRequest startAsynchronous];
}

@end
