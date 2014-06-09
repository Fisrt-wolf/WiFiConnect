//
//  AppDelegate.h
//  WiFiConnect
//
//  Created by IOS on 14-6-6.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainViewCtl;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MainViewCtl * _mainViewCtl;
}

@property (strong, nonatomic) UIWindow *window;

@end
