//
//  AppDelegate.m
//  WiFiConnect
//
//  Created by IOS on 14-6-6.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewCtl.h"
#import "APService.h"
#import "BackgroundRunner.h"
#import "Common.h"

@implementation AppDelegate
@synthesize locationManager;

- (void)initWidght
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    if (_mainViewCtl == nil) {
        _mainViewCtl = [[MainViewCtl alloc] initWithNibName:@"MainView" bundle:nil];
    }
    _mainViewCtl.title = @"WiFi Auto Connect";
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:_mainViewCtl];
    self.window.rootViewController = navigation;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
}


#pragma mark -
#pragma mark 极光推送
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    _backgroundRunningTimeInterval = 0;

    [self initWidght];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kAPNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kAPNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kAPNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kAPNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kAPNetworkDidReceiveMessageNotification
                        object:nil];
    
    // Required
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    // Required
    [APService setupWithOption:launchOptions];
    [_mainViewCtl monitorWiFi];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self regionLocation];
    [self performSelectorInBackground:@selector(runningInBackground) withObject:nil];
    
    return YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [[BackgroundRunner shared] stop];
    
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"test  121212");
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"%@",userInfo);
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"通知" message:@"我的信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    
    [alert show];
    
    [alert release];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
    
    NSLog(@"%@", userInfo);
}

#pragma mark -
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [@"" writeToFile:WiFiFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


- (void)dealloc
{
    [super dealloc];
    SafeRelease(_mainViewCtl);
}

- (void)networkDidSetup:(NSNotification *)notification {

    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {

    NSLog(@"未连接。。。");
}

- (void)networkDidRegister:(NSNotification *)notification {

    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {

    NSLog(@"已登录");
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    [dateFormatter release];
}

#pragma mark -
#pragma mark 后台运行代码
- (void)runningInBackground
{
    while (1) {
        [NSThread sleepForTimeInterval:1];
        [_mainViewCtl monitorWiFi];
        _backgroundRunningTimeInterval++;
        NSLog(@"%d",(int)_backgroundRunningTimeInterval);
    }
}

#pragma mark -
#pragma mark --

static int bgCount = 0;

- (void)applicationDidEnterBackground:(UIApplication *)application

{
    
    if ([self isMultitaskingSupported])
        
    {
        [self performSelectorOnMainThread:@selector(keepAlive:) withObject:[NSNumber numberWithInt:10] waitUntilDone:YES];
        
        BOOL backgroundAccepted = [application setKeepAliveTimeout:600 handler:^{
            
            NSLog(@"setKeepAliveTimeout:%d",bgCount);
            
            //[gDeviceNetworker disConnectToHost];
            
            if (_bgTask == UIBackgroundTaskInvalid && bgCount) {
                
                [self performSelectorOnMainThread:@selector(keepAlive:) withObject:[NSNumber numberWithInt:50] waitUntilDone:YES];
                
                bgCount = 0;
                
            }
            
        }];
        
        if (backgroundAccepted) {
            
            NSLog(@"backgrounding accepted");
            
        }
        
    }
    
}

- (BOOL) isMultitaskingSupported{
    
    BOOL result = NO;
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
        
    {
        
        result = [[UIDevice currentDevice]  isMultitaskingSupported];
        
    }
    
    return result;
    
}

- (void)keepAlive:(NSNumber *)Num {
    
    _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        NSLog(@"beginBackgroundTaskWithExpirationHandler:%d",1);
        
        [[UIApplication sharedApplication]  endBackgroundTask:_bgTask];
        
        _bgTask = UIBackgroundTaskInvalid;
        
        bgCount += 1;
        
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (1) {
            
            if (_bgTask == UIBackgroundTaskInvalid) {
                
                break;
                
            }
            
            //运行的方法
            
            NSLog(@"BackgroundTaskWithExpiration");
            
            NSTimeInterval remainingTime = [UIApplication sharedApplication].backgroundTimeRemaining;
            
            if (remainingTime < 10) {
                
                break;
                
            }
            
            //NSLog(@”BackgroundTaskWithExpiration:%f”,remainingTime);
            
            sleep(1);
            
        }
        
        NSLog(@"beginBackgroundTaskWithExpirationHandler:%d",2);
        
        [[UIApplication sharedApplication]  endBackgroundTask:_bgTask];
        
        _bgTask = UIBackgroundTaskInvalid;
        
        bgCount += 1;
        
    });
    
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
    [[Common shareCommon] regionLocations:tLocationAry managerObj:self];
//    [self regionLocations:tLocationAry];
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


@end
