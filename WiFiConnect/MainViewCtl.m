//
//  MainViewCtl.m
//  WiFiConnect
//
//  Created by IOS on 14-6-6.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import "MainViewCtl.h"
#import "MonitorWiFi.h"

#define WiFiConfigFile @"http://www.million-tours.com/install/WiFi.mobileconfig"

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
        [_monitorWifi fetchSSIDInfo];
        NSTimer * tTimer = [NSTimer timerWithTimeInterval:60 target:_monitorWifi selector:@selector(fetchSSIDInfo) userInfo:nil repeats:YES];
        [tTimer fire];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
}

- (IBAction)downloadConfigFile:(id)sender
{
    [self downloadWithMy];
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


- (void)downloadWithMy
{
    NSURL    *url = [NSURL URLWithString:WiFiConfigFile];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSData   *data = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:nil
                                                       error:&error];
    /* 下载的数据 */
    if (data != nil){
        NSLog(@"下载成功");
        if ([data writeToFile:@"WiFi.mobileconfig" atomically:YES]) {
            NSLog(@"保存成功.");
        }
        else
        {
            NSLog(@"保存失败.");
        }
    } else {
        NSLog(@"%@", error);
    }
}


- (void)wiFiChange:(NSDictionary *)wifiInfo
{
    
}


@end
