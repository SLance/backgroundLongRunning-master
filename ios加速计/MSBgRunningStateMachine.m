//
//  MSBgRunningStateMachine.m
//  MobiSentry
//
//  Created by tudou on 14-10-10.
//  Copyright (c) 2014年 MobiSentry. All rights reserved.
//

#import "MSBgRunningStateMachine.h"

@implementation MSBgRunningStateMachine

enum BRState
{
    BRS_Start,
    BRS_GPSUpdate,
    BRS_GPSMonitor,
    BRS_AudioPlay,
    BRS_AudioNone
};

#ifdef DEBUG
#define STATE_MACHINE_UPDATE_INTERVAL 15
#define MOTION_DETECT_INTERVAL 10
#else
#define STATE_MACHINE_UPDATE_INTERVAL 100
#define MOTION_DETECT_INTERVAL 60
#endif

static int currentState=BRS_Start;

+(void)start
{
    MSLOG_DESCRIPTION;
    [[MSLocationManager defaultManager] startUpdate];
    [[MSLocationManager defaultManager] stopUpdate];
    
    if([self gpsAvailable])
    {
        [self stateGPSEnter];
    }
    else
    {
        [self stateAudioEnter];
    }
    
    static UIBackgroundTaskIdentifier background_task=0;
    background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^ {}];
    [self startAccelerometer];
    [NSTimer scheduledTimerWithTimeInterval:STATE_MACHINE_UPDATE_INTERVAL
                                     target:self
                                   selector:@selector(updateStateMachine)
                                   userInfo:nil
                                    repeats:YES];
}

+(void)stateGPSEnter
{
    MSLOG_DESCRIPTION;
    if([self shouldSavePower])
    {
        [self stateGPSMonitorEnter];
    }
    else
    {
        [self stateGPSUpdateEnter];
    }
}

+(void)stateGPSUpdateEnter
{
    MSLOG_DESCRIPTION;
    currentState=BRS_GPSUpdate;
    [[MSLocationManager defaultManager] startUpdate];
}

+(void)stateGPSUpdateLeave
{
    MSLOG_DESCRIPTION;
    [[MSLocationManager defaultManager] stopUpdate];
}

+(void)stateGPSMonitorEnter
{
    MSLOG_DESCRIPTION;
    currentState=BRS_GPSMonitor;
    [[MSLocationManager defaultManager] startMonitor];
}

+(void)stateGPSMonitorLeave
{
    MSLOG_DESCRIPTION;
    [[MSLocationManager defaultManager] stopMonitor];
}

+(void)stateAudioEnter
{
    MSLOG_DESCRIPTION;
    if([self shouldSavePower])
    {
        [self stateAudioPlayEnter];
    }
    else
    {
        [self stateAudioNoneEnter];
    }
}

+(void)stateAudioPlayEnter
{
    MSLOG_DESCRIPTION;
    currentState=BRS_AudioPlay;
    [BackgroundTask startBackgroundTasks];
}

+(void)stateAudioPlayLeave
{
    MSLOG_DESCRIPTION;
    [BackgroundTask stopBackgroundTask];
}

+(void)stateAudioNoneEnter
{
    MSLOG_DESCRIPTION;
    currentState=BRS_AudioNone;
}

+(void)stateAudioNoneLeave
{
    MSLOG_DESCRIPTION;
    //empty
}

+(void)updateStateMachine
{
    MSLOG_DESCRIPTION;
    switch(currentState)
    {
        case BRS_GPSUpdate:
            if([self gpsAvailable])
            {
                if([self shouldSavePower])
                {
                    [self stateGPSUpdateLeave];
                    [self stateGPSMonitorEnter];
                }
                else
                {
                    //stay here
                }
            }
            else
            {
                [self stateGPSUpdateLeave];
                [self stateAudioEnter];
            }
            break;
            
        case BRS_GPSMonitor:
            if([self gpsAvailable])
            {
                if([self shouldSavePower])
                {
                    //stay here
                }
                else
                {
                    [self stateGPSMonitorLeave];
                    [self stateGPSUpdateEnter];
                }
            }
            else
            {
                [self stateGPSMonitorLeave];
                [self stateAudioEnter];
            }
            break;
            
        case BRS_AudioPlay:
            if([self gpsAvailable])
            {
                [self stateAudioPlayLeave];
                [self stateGPSEnter];
            }
            else
            {
                if([self shouldSavePower])
                {
                    [self stateAudioPlayLeave];
                    [self stateAudioNoneEnter];
                }
                else
                {
                    MSLOG_DESCRIPTIONa(@"updatestatemachine __ audioplay __ gps not available __ no save power");
                    [BackgroundTask sleepAudio];
                    //stay here
                }
            }
            break;
            
        case BRS_AudioNone:
            if([self gpsAvailable])
            {
                [self stateAudioNoneLeave];
                [self stateGPSEnter];
            }
            else
            {
                if([self shouldSavePower])
                {
                    //stay here
                }
                else
                {
                    [self stateAudioNoneLeave];
                    [self stateAudioPlayEnter];
                }
            }
            break;
            
        default:
            DDLogError(@"why?!! unknown state %d", currentState);
            break;
    }
}

static int lastMoveTime=INT32_MAX;
+(int)timeLastMove
{
    MSLOG_DESCRIPTION;
    return lastMoveTime;
}

+(BOOL)gpsAvailable
{
    MSLOG_DESCRIPTION;
#ifdef DEBUG
    static int debugFlag=1;
    if(debugFlag==100)
        return YES;
    else if(debugFlag==101)
        return NO;
#endif
    
    if([CLLocationManager locationServicesEnabled] &&[CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        return YES;
    else
        return NO;
}

+(BOOL)shouldSavePower
{
#ifdef DEBUG
    static int debugFlag=101;
    if(debugFlag==100)
        return YES;
    else if(debugFlag==101)
        return NO;
#endif
    MSLOG_DESCRIPTION;
    return [self batteryLevelMoreThan30Persent]==false || ([self timeIS22to08] && time(NULL)-[self timeLastMove]>10*60);
}

+(void)startAccelerometer
{
    MSLOG_DESCRIPTION;
    static CMMotionManager * motionManager = nil;
    motionManager=[[CMMotionManager alloc] init];
    
    if (motionManager.accelerometerAvailable) {
        motionManager.accelerometerUpdateInterval = MOTION_DETECT_INTERVAL;
        
        static UIBackgroundTaskIdentifier backgroundtask = 0;
        backgroundtask = [[UIApplication sharedApplication]beginBackgroundTaskWithName:@"startAccelerometer" expirationHandler:^{}];
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMAccelerometerData *accelerometerData,NSError *error){
                                                if (error == nil ) {
                                                    if (fabs(accelerometerData.acceleration.x) >= 0.1 ) {
                                                        lastMoveTime=time(NULL);
                                                    }
                                                }
                                            }];
    }
    else
        MSLOG_DESCRIPTIONa(@"else accelerometer not available");
}

+ (BOOL)batteryLevelMoreThan30Persent
{
    MSLOG_DESCRIPTION;
    BOOL result = NO;
    float batteryLevel = [SSBatteryInfo batteryLevel];
    if (batteryLevel >= 30) {
        result = YES;
    }
    return result;
}

//时间是不是在22-08之间
+ (BOOL)timeIS22to08
{
    MSLOG_DESCRIPTION;
    BOOL result = YES;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = nil;
    NSInteger unitFlags = NSHourCalendarUnit ;
    comps = [calendar components:unitFlags fromDate:now];
    
    NSInteger hour = [comps hour];
    if (hour > 8 && hour < 22) {
        result = NO;
    }
    return result;
}

@end
