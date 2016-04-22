//
//  MSLocationManager.h
//  ios加速计
//
//  Created by li on 9/22/14.
//  Copyright (c) 2014 lch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MSLocationManager : NSObject<CLLocationManagerDelegate>
{
    id _target;
    SEL _selector;
}
@property (nonatomic,strong)CLLocationManager *locationManager;
@property (nonatomic)float latitude;
@property (nonatomic)float longitude;
@property (nonatomic) bool bLocationUpdated;

+ (instancetype)defaultManager;

- (void)startUpdate;

- (void)stopUpdate;

//地理定位服务是否打开
+ (BOOL)locationEnabled;

- (void)refreshLocation;

+ (BOOL)isLocationUpdated;

- (void)startMonitor;
- (void)stopMonitor;

@end
