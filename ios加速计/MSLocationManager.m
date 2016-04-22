//
//  MSLocationManager.m
//  ios加速计
//
//  Created by li on 9/22/14.
//  Copyright (c) 2014 lch. All rights reserved.
//

#import "MSLocationManager.h"
#import "MSBackgroundTaskManager.h"

@interface MSLocationManager()
@property (nonatomic,strong)NSTimer *locationTimer;


@end

@implementation MSLocationManager

+ (instancetype)defaultManager
{
    static MSLocationManager *s_manager = nil;
    @synchronized(self)
    {
        if (s_manager) {
            return s_manager;
        }
        s_manager = [[self alloc]init];
    }
    return s_manager;
}

- (void)startUpdate
{
  self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
  self.locationManager.distanceFilter= 1;
  self.locationManager.pausesLocationUpdatesAutomatically = NO;
  self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
  [self.locationManager startUpdatingLocation];
}

- (void)stopUpdate
{
  [self.locationManager stopUpdatingLocation];
}

-(id)init
{
    self = [super init];
    if (self) {
        _longitude = 0.0;
        _latitude = 0.0;
        _bLocationUpdated=NO;
        
        [self locationManager];
    }
    return self;
}

- (void)startMonitor
{
    //先开启monitoring 再关闭updating,防止killed
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    self.longitude = newLocation.coordinate.longitude;
    self.latitude = newLocation.coordinate.latitude;
    [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:1800];
#ifdef DEBUG
    DDLogInfo(@"updateToLocaton: %f, %f", self.longitude, self.latitude);
    self.longitude=37.61763300;
    self.latitude=55.75578600;
#endif
    _bLocationUpdated=YES;

     
    DDLogInfo(@"LM updated");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  //    DDLogInfo(@"用户没有允许定位: error %@  == start audio",error);
  //    [[MSBackgroundTaskManager defaultManager]startAudioMode];
}

+ (BOOL)locationEnabled
{
    if ([CLLocationManager locationServicesEnabled] == NO || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        return false;
    }
    else
    {
        return true;
    }
}

- (void)stopMonitor
{
  [self.locationManager stopMonitoringSignificantLocationChanges];
}

+ (BOOL)isLocationUpdated
{
    return [[MSLocationManager defaultManager] bLocationUpdated];
}

@end
