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
@synthesize locationManager;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _monitorWifi = [[MonitorWiFi alloc] init];
        _monitorWifi.delegate = self;
        [self.wifiRequestInfoView setHidden:YES];
        _location = [[Location alloc] init];
        _location.delegate = self;
        _wifiInfo = [[NSDictionary alloc] init];
//        [self regionLocation];
//        locationManager = [[CLLocationManager alloc] init];
//        locationManager.delegate = self;
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return self;
}

-(void)handleMaxShowTimer:(NSTimer *)theTimer
{
    NSLog(@"handle Max Show Timer");
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
    SafeRelease(locationManager);
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
    [_location location];
}

#pragma mark -
#pragma mark location delegate
- (void)getCurrentLocation:(CLLocation *)curLocation
{
    [self uploadData];
    NSLog(@"current location: %@",curLocation);
}

// ---  更新界面上当前WiFi的显示信息  ---

- (void)showCurrentWifiInfo
{
    NSString * tWifiInfo = [NSString stringWithFormat:@" SSID : %@\n Mac Address : %@\n ",[_wifiInfo objectForKey:@"SSID"],[_wifiInfo objectForKey:@"BSSID"]];
    [self.wifiInfoView setText:tWifiInfo];
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
    [self.activityIndicatorView setHidden:YES];
    [self.wifiRequestInfoView setHidden:NO];
    
    NSData * data = [request responseData];
    data = [[Common shareCommon] convertXmlDataToUtf8:data];
    NSString * tWifiInfoStr = @"";
    if (nil == data) {
        tWifiInfoStr = @"This WiFi is not recognize;";
    }else{
        NSDictionary *tWifiInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        tWifiInfoStr = [NSString stringWithFormat:@" SSID : %@\n Password : %@\n ",[tWifiInfo objectForKey:@"name"],[tWifiInfo objectForKey:@"pwd"]];
    }
    
    [self.wifiRequestInfoView setText:tWifiInfoStr];
    [self loadWebView];
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

#pragma mark -
#pragma mark webview
- (void)loadWebView
{
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    path = @"http://life.qq.com/weixin/dish/list?qrcode=q1385302068332&code=00c2ee5dbc7bd96e2eaab2be2f50b1bc&ticket=00c2ee5dbc7bd96e2eaab2be2f50b1bc&ticketSource=&from=weixin.dish.menu#wechat_webview_type=1";
    
    NSURL* url = [NSURL URLWithString:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
//    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
//    [self.webView loadHTMLString:html baseURL:baseURL];
}


- (void)regionLocation
{
    NSMutableArray * tLocationAry = [NSMutableArray array];
    CLLocation * tLocation = [[CLLocation alloc] initWithLatitude:22.81258011 longitude:108.33669662];
    [tLocationAry addObject:tLocation];
    tLocation = [[CLLocation alloc] initWithLatitude:22.80870333 longitude:108.32918644];
    [tLocationAry addObject:tLocation];
    tLocation = [[CLLocation alloc] initWithLatitude:22.79750752 longitude:108.36544991];
    [tLocationAry addObject:tLocation];
    tLocation = [[CLLocation alloc] initWithLatitude:22.77272907 longitude:108.31570029];
    [tLocationAry addObject:tLocation];
//    [[Common shareCommon] performSelectorInBackground:@selector(regionLocations:) withObject:self];
//    [[Common shareCommon] regionLocations:tLocationAry managerObj:self];
    [self regionLocations:tLocationAry];
}


- (void)regionLocations:(NSArray *)locationsAry
{
    NSMutableArray *geofences = [NSMutableArray array];
    
    for(CLLocation *location in locationsAry) {
        NSString* identifier = [NSString stringWithFormat:@"%f%f", location.coordinate.latitude, location.coordinate.longitude];
        
        CLRegion* geofence = [[CLRegion alloc] initCircularRegionWithCenter:location.coordinate
                                                                     radius:300
                                                                 identifier:identifier];
        [geofences addObject:geofence];
    }
    
    if (geofences.count > 0) {
        for (CLRegion * geofence in geofences) {
            [locationManager startMonitoringForRegion:geofence];
        }
    }
}


#pragma mark -
#pragma mark Location delegate
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    int count = 0;
    while (1) {
        NSString * str = [NSString stringWithFormat:@"%d",count];
        [str writeToFile:WiFiFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        sleep(1);
        count++;
    }
    [self locationChanged];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    int count = 0;
    while (1) {
        NSString * str = [NSString stringWithFormat:@"%d",count];
        [str writeToFile:WiFiFilePathExit atomically:YES encoding:NSUTF8StringEncoding error:nil];
        sleep(1);
        count++;
    }
    [self locationChanged];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    int count = 0;
    while (1) {
        NSString * str = [NSString stringWithFormat:@"%d",count];
        [str writeToFile:regionChange atomically:YES encoding:NSUTF8StringEncoding error:nil];
        sleep(1);
        count++;
    }
}

-(void)locationChanged
{
    /*
     * There is a bug in iOS that causes didEnter/didExitRegion to be called multiple
     * times for one location change (http://openradar.appspot.com/radar?id=2484401).
     * Here, we rate limit it to prevent performing the update twice in quick succession.
     */
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:@"BSSID",@"14:e6:e4:fe:e6:50",@"SSID", nil];
    static long timestamp;
    
    if (timestamp == 0) {
        timestamp = [[NSDate date] timeIntervalSince1970];
    } else {
        if ([[NSDate date] timeIntervalSince1970] - timestamp < 10) {
            return;
        }
    }
    
}



@end
