//
//  BackgroundAudoTask.h
//  AUDIO + VOIP
//
//  Created by Ravishanker Kusuma on 12/31/13.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@interface BackgroundTask : NSObject

+(void) startBackgroundTasks;
+(void) stopBackgroundTask;

+ (void)sleepAudio;

+ (void)threadId;
@end
