//
//  MSLogUtil.m
//  ios加速计
//
//  Created by li on 9/22/14.
//  Copyright (c) 2014 lch. All rights reserved.
//

#import "MSLogUtil.h"

@implementation MSLogUtil
 
//start log 相关 -------------------------------------------------
+ (NSString *)threadId
{
    NSString *thread = [[NSThread currentThread] description];
    thread = [[thread componentsSeparatedByString:@","]lastObject];
    thread = [[thread componentsSeparatedByString:@"="]lastObject];
    return thread;
}
 
+ (NSString *)remainTime
{
    NSString *result;
    NSTimeInterval rt = [[UIApplication sharedApplication]backgroundTimeRemaining];
    if (rt>pow(10,300)) {
        rt = rt/pow(10, 300);
        result = [NSString stringWithFormat:@"%f E+308",rt];
    }
    else result = [NSString stringWithFormat:@"%f",rt];
    
    return result;
}
//end log 相关 ---------------------------------------------------

@end
