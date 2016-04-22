//
//  MSLogUtil.h
//  ios加速计
//
//  Created by li on 9/22/14.
//  Copyright (c) 2014 lch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSLogUtil : NSObject

/**
 * @brief 线程ID
 */
+ (NSString *)threadId;

/**
 * @brief 后台任务剩余的时间
 */
+ (NSString *)remainTime;
 
@end
