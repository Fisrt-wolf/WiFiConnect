//
//  Location.m
//  WiFiConnect
//
//  Created by IOS on 14-7-1.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import "Location.h"

@implementation Location
@synthesize delegate;

- (void)location
{
    if ( nil == _currentLocation ) {
        _currentLocation = [[[CLLocationManager alloc] init] retain];
    }
    _currentLocation.delegate = self;
    _currentLocation.desiredAccuracy = kCLLocationAccuracyBest;
    [_currentLocation startUpdatingLocation];
    locationFlag = YES;
}


#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLGeocoder *geocoder;
    geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         MyNSLog(newLocation);
         if (nil != delegate && [delegate respondsToSelector:@selector(getCurrentLocation:)] ) {
             if (locationFlag == YES) {
                 [delegate getCurrentLocation:newLocation];
                 locationFlag = NO;
             }
             
         }
         [_currentLocation stopUpdatingLocation];
         
     }];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    MyNSLog(error);
    MyNSLog(@"location error");
}


@end
