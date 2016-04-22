//
//  MSBGManager.h
//  ios加速计
//
//  Created by li on 9/26/14.
//  Copyright (c) 2014 lch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSBGManager : NSObject

@property (nonatomic,strong) NSTimer *timer;

+ (instancetype)defaultManager;


- (void)backgroundMethod:(id)sender;

@end
