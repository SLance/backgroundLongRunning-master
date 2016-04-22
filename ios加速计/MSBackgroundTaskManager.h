//
//  MSBackgroundTaskManager.h
//  ios加速计
//
//  Created by li on 9/19/14.
//  Copyright (c) 2014 lch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "BackgroundTask.h"
#import "MSBgRunningStateMachine.h"


@interface MSBackgroundTaskManager : NSObject

//代理调用的方法
- (void)didFinishLaunching;

//- (void)applicationDidBecomeActive;



//自己调用的相关方法

@property (nonatomic,strong)BackgroundTask *bgtask;

@property (nonatomic,assign)UIBackgroundTaskIdentifier background_task;

@property (nonatomic,strong) CMMotionManager *motionManager;

+ (instancetype)defaultManager;
 
- (void)startLocationMode;

//判断入口
- (void)startBackgroundMode;
 
- (void)startAudioMode;
- (void)stopAudioMode;

//电量是否小于30%
- (BOOL)batteryLevelMoreThan30Persent;

- (void)startLocationOrAudio;

@end
