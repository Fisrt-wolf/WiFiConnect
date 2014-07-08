
#import "LocationUtil.h"

@implementation LocationUtil{
    
}
@synthesize delegate;

-(void)startLocationManager{
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager setPausesLocationUpdatesAutomatically:YES];//Utkarsh 20sep2013
    //[locationManager setActivityType:CLActivityTypeFitness];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingLocation];
    
    //Reverse Geocoding.
    geoCoder=[[CLGeocoder alloc] init];
    
    //set default values for reverse geo coding.
}

//for iOS<6
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //call delegate Method
    [delegate locationRecievedSuccesfullyWithNewLocation:newLocation oldLocation:oldLocation];
    
    NSLog(@"did Update Location");
}

//for iOS>=6.

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations objectAtIndex:0];
    CLLocation *oldLocation = [locations objectAtIndex:0];
    
    [delegate locationRecievedSuccesfullyWithNewLocation:newLocation oldLocation:oldLocation];
    NSLog(@"did Update Locationsssssss");
}
@end