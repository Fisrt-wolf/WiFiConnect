//
//  LocationUtil.h
//  WiFiConnect
//
//  Created by IOS on 14-7-3.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@protocol LocationRecievedSuccessfully <NSObject>
@optional
-(void)locationRecievedSuccesfullyWithNewLocation:(CLLocation*)newLocation oldLocation:(CLLocation*)oldLocation;
-(void)addressParsedSuccessfully:(id)address;


@end
@interface LocationUtil : NSObject <CLLocationManagerDelegate> {
    CLLocationManager * locationManager;
    CLGeocoder      * geoCoder;
}

//Properties
@property (nonatomic,strong) id<LocationRecievedSuccessfully> delegate;
-(void)startLocationManager;
@end