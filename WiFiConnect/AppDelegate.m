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
#define START_FETCH_LOCATION @"sdfsdfsd"

@implementation AppDelegate
@synthesize locationManager;

- (void)initWidght
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    if (_mainViewCtl == nil) {
        _mainViewCtl = [[MainViewCtl alloc] initWithNibName:@"MainView" bundle:nil];
    }
    _mainViewCtl.title = NSLocalizedString(@"title", @"title");
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:_mainViewCtl];
    self.window.rootViewController = navigation;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [@"" writeToFile:WiFiFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}


#pragma mark -
#pragma mark 极光推送
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _backgroundRunningTimeInterval = 0;

    [self initWidght];
    
    [self initAPService:launchOptions];
    
    [_mainViewCtl monitorWiFi];
    
    [self performSelectorInBackground:@selector(runningInBackground) withObject:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startFetchingLocationsContinously) name:START_FETCH_LOCATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:START_FETCH_LOCATION object:nil];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate startUpdatingDataBase];
    
    self.slm = [[ScheduledLocationManager alloc]init];
    self.slm.delegate = self;
    [self.slm getUserLocationWithInterval:60];
    return YES;
}


// ---  初始化极光推送的相关内容  ---
- (void)initAPService:(NSDictionary *)dic
{
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
    [APService setupWithOption:dic];
}

#pragma mark - Location Update
-(void)startFetchingLocationsContinously{
    MyNSLog(@"start Fetching Locations");
    self.locationUtil = [[LocationUtil alloc] init];
    [self.locationUtil setDelegate:self];
    [self.locationUtil startLocationManager];
}

-(void)locationRecievedSuccesfullyWithNewLocation:(CLLocation*)newLocation oldLocation:(CLLocation*)oldLocation{
    NSString * s = [NSString stringWithFormat:@"location received successfullly in app delegate for Laitude: %f and Longitude:%f, and Altitude:%f, and Vertical Accuracy: %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude,newLocation.altitude,newLocation.verticalAccuracy];
    MyNSLog(s);
    
    NSString * str = [NSString stringWithContentsOfFile:lastTest encoding:NSUTF8StringEncoding error:nil];
    str = [NSString stringWithFormat:@"%@\n%@",str,[self getStr]];
    [str writeToFile:lastTest atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    [_mainViewCtl monitorWiFi];
}

-(void)startUpdatingDataBase{
    UIApplication*    app = [UIApplication sharedApplication];
    
    bgTask = UIBackgroundTaskInvalid;
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^(void){
        [app endBackgroundTask:bgTask];
    }];
    
    NSTimer * timer =  [NSTimer scheduledTimerWithTimeInterval:300
                                                            target:self selector:@selector(startFetchingLocationsContinously) userInfo:nil repeats:YES];
    [timer fire];
}

-(void)scheduledLocationManageDidFailWithError:(NSError *)error
{
    MyNSLog(error);
}

-(void)scheduledLocationManageDidUpdateLocations:(NSArray *)locations
{
    // You will receive location updates every 60 seconds (value what you set with getUserLocationWithInterval)
    // and you will continue to receive location updates for 3 seconds (value of kTimeToGetLocations).
    // You can gather and pick most accurate location
    MyNSLog(locations);
    NSString * str = [NSString stringWithContentsOfFile:lastTest1 encoding:NSUTF8StringEncoding error:nil];
    str = [NSString stringWithFormat:@"%@\n%@",str,[self getStr]];
    [str writeToFile:lastTest1 atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)getStr
{
    NSDate * date;
    date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    [[BackgroundRunner shared] stop];
    SafeRelease(locationManager);
    
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [_mainViewCtl showShopView:userInfo];
    MyNSLog(userInfo);
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [_mainViewCtl showShopView:userInfo];
    // Required
    [APService handleRemoteNotification:userInfo];
    
    MyNSLog(userInfo);
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

    MyNSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {

    MyNSLog(@"未连接。。。");
}

- (void)networkDidRegister:(NSNotification *)notification {

    MyNSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {

    MyNSLog(@"已登录");
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {

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
        NSString * str = [NSString stringWithFormat:@"%d",(int)_backgroundRunningTimeInterval];
        MyNSLog(str);
    }
}

#pragma mark -
#pragma mark --

static int bgCount = 0;

- (void)applicationDidEnterBackground:(UIApplication *)application

{
//    locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//    [self regionLocation];

    
//    if ([self isMultitaskingSupported])
//        
//    {
//        [self performSelectorOnMainThread:@selector(keepAlive:) withObject:[NSNumber numberWithInt:10] waitUntilDone:YES];
//        
//        BOOL backgroundAccepted = [application setKeepAliveTimeout:600 handler:^{
//            
//            NSLog(@"setKeepAliveTimeout:%d",bgCount);
//            
//            //[gDeviceNetworker disConnectToHost];
//            
//            if (_bgTask == UIBackgroundTaskInvalid && bgCount) {
//                
//                [self performSelectorOnMainThread:@selector(keepAlive:) withObject:[NSNumber numberWithInt:50] waitUntilDone:YES];
//                
//                bgCount = 0;
//                
//            }
//            
//        }];
//        
//        if (backgroundAccepted) {
//            
//            NSLog(@"backgrounding accepted");
//            
//        }
//        
//    }
    
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
            
            MyNSLog(@"BackgroundTaskWithExpiration");
            
            NSTimeInterval remainingTime = [UIApplication sharedApplication].backgroundTimeRemaining;
            
            if (remainingTime < 10) {
                
                break;
                
            }
            
            //NSLog(@”BackgroundTaskWithExpiration:%f”,remainingTime);
            
            sleep(1);
            
        }
        NSString * str = [NSString stringWithFormat:@"beginBackgroundTaskWithExpirationHandler:%d",2];
        MyNSLog(str);
        
        [[UIApplication sharedApplication]  endBackgroundTask:_bgTask];
        
        _bgTask = UIBackgroundTaskInvalid;
        
        bgCount += 1;
        
    });
    
}

#pragma mark -
#pragma mark Location

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
    [[Common shareCommon] regionLocations:tLocationAry managerObj:locationManager];
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
    
//    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:@"BSSID",@"14:e6:e4:fe:e6:50",@"SSID", nil];
    MyNSLog(@"location changed");
    
}

@end
