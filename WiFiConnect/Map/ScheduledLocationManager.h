//
//  ScheduledLocationManager.h
//  WiFiConnect
//
//  Created by IOS on 14-7-3.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ScheduledLocationManagerDelegate <NSObject>

-(void)scheduledLocationManageDidFailWithError:(NSError*)error;
-(void)scheduledLocationManageDidUpdateLocations:(NSArray*)locations;

@end

@interface ScheduledLocationManager : NSObject <CLLocationManagerDelegate>
@property(readwrite,retain,nonatomic)id <ScheduledLocationManagerDelegate> delegate;
-(void)getUserLocationWithInterval:(int)interval;

@end
