//
//  AppDelegate.m
//  ios加速计
//
//  Created by li on 9/19/14.
//  Copyright (c) 2014 lch. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

//设计思路:
// 程序开启或是自动重启都自动打开后台任务,确保重启情况下维持重启状态
// applicationWillResignActive 将进入后台时选择后台任务(location因必须在前台才能启动,在applicationDidBecomeActive开启)
// applicationDidEnterBackground 将进入前台时关闭后台任务
// applicationDidBecomeActive 程序active时,如果第一次安装弹窗询问是否允许定位
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    [DDLog addLogger:fileLogger];
    [MSLogUtil threadId];
 
    DDLogInfo(@"\n");
    MSLOG_DESCRIPTION;
    
    [[MSBackgroundTaskManager defaultManager]didFinishLaunching];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
     DDLogInfo(@"+++++++++++++++++++%s",__FUNCTION__);
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //将进入前台时关闭所有后台任务,打开地理定位任务
    DDLogInfo(@"++++++++++++++++++++++++++++%s",__FUNCTION__);
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //程序进入前台执行定位,但是active情况之后才弹窗.
     // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    MSLOG_DESCRIPTION;
    [application beginBackgroundTaskWithExpirationHandler:^ {
        //打开后台运行任务
    }];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
