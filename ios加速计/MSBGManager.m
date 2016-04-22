//
//  MSBGManager.m
//  ios加速计
//
//  Created by li on 9/26/14.
//  Copyright (c) 2014 lch. All rights reserved.
//

#import "MSBGManager.h"

#define LOCATIONSERVICE_ENABLED ([CLLocationManager locationServicesEnabled] &&[CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)


@implementation MSBGManager

+ (instancetype)defaultManager
{
    static MSBGManager *s_manager = nil;
    @synchronized(self)
    {
        if (s_manager) {
            return s_manager;
        }
        s_manager = [[self alloc]init];
        [s_manager timer];
    }
    return s_manager;
}

- (void)backgroundMethod:(id)sender
{
    NSDictionary *userinfo = [sender userInfo];
    if ( [sender isMemberOfClass:NSClassFromString(@"NSConcreteNotification")]) {
        userinfo = [sender object];
    }
    
    NSString *mode = [userinfo objectForKey:@"mode"];
    if ([mode isEqualToString:@"location"])
    {
        if ([[MSBackgroundTaskManager defaultManager]batteryLevelMoreThan30Persent]) {
            [[MSLocationManager defaultManager]startUpdate];
        }
        else
        {
            [[MSLocationManager defaultManager]startMonitor];
            [[MSLocationManager defaultManager].locationManager stopUpdatingLocation];
        }
        
        MSLOG_DESCRIPTIONa(@"*********************location method *******************************");
        [[MSBackgroundTaskManager defaultManager]stopAudioMode];
    }
    else if ([mode isEqualToString:@"audio"])
    {
//        [self audioMethodProcess];
        [[MSLocationManager defaultManager] stopUpdate];
        if (LOCATIONSERVICE_ENABLED) {
            [[MSBackgroundTaskManager defaultManager]startBackgroundMode];
        }
    }
    else
        DDLogDebug(@"**************************%s   %@",__FUNCTION__,userinfo);
    
}

static int interval = 0;
- (void)audioMethodProcess
{
//    if (interval < 2000) {
//        [NSThread sleepForTimeInterval:1];
//        interval ++;
//        if (interval > 1995)
//            DDLogDebug(@"interval == %d",interval);
//    }
//    else
//    {
//        interval = 0;
//    }
//    DDLogDebug(@"*********************audio method *******************************");
}

@end
