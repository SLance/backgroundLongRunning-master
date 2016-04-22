//
//  MSBackgroundTaskManager.m
//  ios加速计,后台任务重启模式和定位运行模式结合(为解决永久运行费电的问题)
/*
 
 */
//  Created by li on 9/19/14.
//  Copyright (c) 2014 lch. All rights reserved.
//

#import "MSBackgroundTaskManager.h"

#define LOCATIONSERVICE_ENABLED [CLLocationManager locationServicesEnabled] &&[CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized

@implementation MSBackgroundTaskManager

+ (instancetype)defaultManager
{
    static MSBackgroundTaskManager *s_manager = nil;
    @synchronized(self)
    {
        if (s_manager == nil) {
            s_manager = [[self alloc]init];
        }
    }
    return s_manager;
}

//开启Accelerometer来检测程序是否在使用,1s检测一次,尝试超过175次没motion,后台进入重启模式(现在已经处于后台)
- (BOOL)startAccelerometerWithbackgroundTask:(UIBackgroundTaskIdentifier)bg_task
{
  BOOL accelerometerAvailable = NO;
  self.motionManager = [[CMMotionManager alloc] init];
  
  //加速计是否可用
  if (self.motionManager.accelerometerAvailable) {
    accelerometerAvailable = YES;
    
    //每10s检测一次客户端是否在运动
    self.motionManager.accelerometerUpdateInterval = 10;
    
    //若要startAccelerometer执行,前提要存在后台任务  start Accelerometer
    //startUpdates 175次s,如果没有一次设备motion,app进入无限重启模式
    DDLogDebug(@"accelerometerAvailable===============");
    __block int i=0;//次数标记
    UIBackgroundTaskIdentifier backgroundtask = [[UIApplication sharedApplication]beginBackgroundTaskWithName:@"startAccelerometerWithbackgroundTask" expirationHandler:^{
    }];
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData,NSError *error){
                                               if (error == nil ) {
                                                 NSString *str = [NSString stringWithFormat:@"%.1f",accelerometerData.acceleration.x];
                                                 float value = [str floatValue];
                                                 
                                                 DDLogDebug(@"error = nil, %s",__FUNCTION__);
                                                 //设备有motion,(并且进入UIApplicationStateActive状态)后台进入定位运行模式
                                                 if (abs(value) >= 0.1 ) {
                                                   DDLogDebug(@"  if (value >= 0.1)  true ===============");
                                                   i=0;//重置i的值
                                                   [self startLocationOrAudio];
                                                   
                                                   [self.motionManager stopAccelerometerUpdates];
                                                   [[UIApplication sharedApplication]endBackgroundTask:backgroundtask];
                                                   //开启定位运行模式之后必须return,否则执行下面if(i>175)}{}导致重启模式运行!
                                                   return ;
                                                   
                                                 }
                                               }
                                               else
                                               {
                                                 DDLogDebug(@"如果计时器更新失败,这里不做处理,等i>175时会进入重启模式");
                                                 //[self.motionManager stopAccelerometerUpdates];
                                               }
                                               
                                               //            [NSThread sleepForTimeInterval:10];
                                               i++;
                                               //if(i<20 || i>250)
                                               DDLogDebug(@"---------------%s , i=%d",__FUNCTION__,i);
                                               //尝试超过175次没motion,后台进入重启模式
                                               if (
#ifdef DEBUG
                                                   i>2 ||
#endif
                                                   i>30)
                                               {
                                                 DDLogDebug(@"超过300秒没motion,后台进入默认重启模式 和定位的monitoring");
                                                 [self.motionManager stopAccelerometerUpdates];
                                                 [[MSLocationManager defaultManager]startMonitor];
                                               }
                                             }];
  }
  else
  {
    MSLOG_DESCRIPTIONa(@"else accelerometer not available");
  }
  return accelerometerAvailable;
}

// 选择后台运行方式
- (void)startBackgroundMode
{
    //电量<30%,直接保持重启模式和locationMonitoring省电,否则(22-08点)检测设备是否在使用
    if ([self batteryLevelMoreThan30Persent]) {
        MSLOG_DESCRIPTION;
        [self startCheckAtRightTime];
    }
    else
    {
        [[MSLocationManager defaultManager]startMonitor];
        
        [self stopAudioMode];
        [[MSLocationManager defaultManager].locationManager stopUpdatingLocation];
        //电量小于30不做处理,默认backgroundtask重启模式
        DDLogDebug(@"battery level less than 30-------------");
    }
}


//(22-08点)检测设备是否在使用,电量充足
- (void)startCheckAtRightTime
{
    DDLogDebug(@"%s",__FUNCTION__);
    //电量充足的状态下,在22-08时间里,(不动重启,动就定位运行)
    if ([self  timeIS22to08]) {
        //是晚上,电量充足
        BOOL accelerometerAccessible = [self startAccelerometerWithbackgroundTask:self.background_task];
        //motion 检测不到保持重启模式
        if (!accelerometerAccessible ) {
            //accelerometer 不可用,(选重启模式)
            DDLogDebug(@"accelerometer is not Accessible !!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        }
    }
    else   //电量充足的状态下,不在22-08时间里,(定位运行)在前台就选择location或audio
          [self startLocationOrAudio];
}

//选择location or audio
- (void)startLocationOrAudio
{
    MSLOG_DESCRIPTION;
    //location优先选择,如果用户没有打开定位就执行一次定位(第一次会弹窗询问是否允许定位)和选择audio模式,如果打开了定位就执行定位
    if (!LOCATIONSERVICE_ENABLED) {
        [self startAudioMode];
    }
    else
    {
        [self startLocationMode];
    }
 
}

 
//开启重启模式
- (void)startRestartMode
{
    DDLogDebug(@"%s",__FUNCTION__);
}


//开启定位运行模式
- (void)startLocationMode
{
    if ([self batteryLevelMoreThan30Persent]) {
        [[MSLocationManager defaultManager]startUpdate];
    }
    else{
        [[MSLocationManager defaultManager]startMonitor];
    }
}


- (void)startAudioMode
{
    MSLOG_DESCRIPTION;
    [BackgroundTask startBackgroundTasks];
}

- (void)stopAudioMode
{
    [BackgroundTask stopBackgroundTask];
    MSLOG_DESCRIPTION;
}

//------------appdelegate中调用的入口
- (void)didFinishLaunching
{
    MSLOG_DESCRIPTION;
    //默认开启重启模式
//    self.background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^ {
//        //开启重启模式
//    }];
//    
//    //选择后台任务方式
//    [self startBackgroundMode];
    [MSBgRunningStateMachine start];
}

//- (void)applicationDidBecomeActive
//{
//    //第一次打开程序的时候定位,弹窗是否允许定位
//    if ([CLLocatio nManager authoriz ationStatus] != kCLAuthorizati onStatusAuthorized) {
//        [[MSLoca tionManager default Manager] locat ionManager];
//    }
//    else
//    {
//        [[MSLocatio nManager defaul tManager]stopL ocation];
//        [[MSBackground TaskManager defa ultManager]stop AudioMode];
//    }
//}

//电量是否大于30%
- (BOOL)batteryLevelMoreThan30Persent
{
    BOOL result = NO;
    float batteryLevel = [SSBatteryInfo batteryLevel];
    if (batteryLevel >= 30) {
        result = YES;
    }
    MSLOG_DESCRIPTION;
    //log1,log2=no  log3,log4=yes
#ifdef LCH
    return YES;
#else
    return result;
#endif
}

//时间是不是在22-08之间
- (BOOL)timeIS22to08
{
    BOOL result = YES;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSHourCalendarUnit ;
    comps = [calendar components:unitFlags fromDate:now];
    
    NSInteger hour = [comps hour];
    if (hour > 8 && hour < 22) {
        result = NO;
    }
    MSLOG_DESCRIPTION;
    //log1=no,log2=yes  log3=yes,log4=no
#ifdef LCH
    return YES;
#else
    return result;
#endif
}



@end
