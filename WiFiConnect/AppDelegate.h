//
//  AppDelegate.h
//  WiFiConnect
//
//  Created by IOS on 14-6-6.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationUtil.h"
#import "ScheduledLocationManager.h"

@class MainViewCtl;

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,LocationRecievedSuccessfully,ScheduledLocationManagerDelegate>
{
    MainViewCtl * _mainViewCtl;
    NSTimeInterval _backgroundRunningTimeInterval;
    UIBackgroundTaskIdentifier _bgTask;
    UIBackgroundTaskIdentifier bgTask;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocationManager *paperboyLocationManager;
@property (strong, nonatomic) LocationUtil * locationUtil;
@property (strong, nonatomic) ScheduledLocationManager *slm;

@end
