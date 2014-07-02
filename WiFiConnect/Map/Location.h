//
//  Location.h
//  WiFiConnect
//
//  Created by IOS on 14-7-1.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationDelegate <NSObject>
- (void)getCurrentLocation:(CLLocation *)curLocation;
@end

@interface Location : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager * _currentLocation;
}

@property(readwrite,assign,nonatomic)id <LocationDelegate> delegate;

/*
 * Describe : 定位当前的位置
 * return   : void
 */
- (void)location;



@end
