//
//  BackgroundTask.m
//  AUDIO + VOIP
//
//  Created by Ravishanker Kusuma on 12/31/13.
//

#import "BackgroundTask.h"
#import <AVFoundation/AVFoundation.h>
#import "SSProcessInfo.h"

void interruptionListenerCallback (void *inUserData, UInt32 interruptionState);

@implementation BackgroundTask
static  AVAudioPlayer *player;
static UIBackgroundTaskIdentifier bgTask;

-(id) init
{
    self = [super init];
    if(self)
    {
        bgTask =UIBackgroundTaskInvalid;
    }
    return  self;
}

+(void) startBackgroundTasks
{
    if(player != nil && [player isPlaying]){
        return;
    }
    [self initBackgroudTask];
    MSLOG_DESCRIPTION;
}

+(void) initBackgroudTask
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       if([self running])
                           [self stopAudio];
                       
                       while([self running])
                       {
                           [NSThread sleepForTimeInterval:1]; //wait for finish
                       }
                       [self playAudio];
                   });
}


+(void) audioInterrupted:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSNumber *interuptionType = [interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    if([interuptionType intValue] == 1)
    {
        [self initBackgroudTask];
    }
}

void interruptionListenerCallback (void *inUserData, UInt32 interruptionState)
{
    if (interruptionState == kAudioSessionBeginInterruption)
    {
        /// [self initBackgroudTask];
    }
}

+(void) playAudio
{
    MSLOG_DESCRIPTION;
    UIApplication * app = [UIApplication sharedApplication];
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if([version floatValue] >= 6.0f)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    else
    {
        AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, nil);
    }
  bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
    [app endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
    [player stop];
    DDLogInfo(@"###############Background Task Expired.");
    // [self playMusic];
  }];
  
    __block BackgroundTask *safeself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *resourceName = @"alarm";
#ifndef LCH
        resourceName = @"silence";
#endif
        NSURL* fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:resourceName ofType:@"mp3"]];
        
        OSStatus osStatus;
        NSError * error;
        if([version floatValue] >= 6.0f)
        {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
            [[AVAudioSession sharedInstance] setActive: YES error: &error];
        }
        else
        {
            osStatus = AudioSessionSetActive(true);
            UInt32 category = kAudioSessionCategory_MediaPlayback;
            osStatus = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
            
            UInt32 allowMixing = true;
            osStatus = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (allowMixing), &allowMixing );
        }
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        player.volume = 1;
        player.numberOfLoops = -1; //Infinite
  
        [player prepareToPlay];
        [player playAtTime:2];
     });
}

+ (void)sleepAudio
{
    if (player.isPlaying) {
        [player stop];
        MSLOG_DESCRIPTIONa(@"isplaying -----");
    }
    else
    {
        MSLOG_DESCRIPTIONa(@"else -------------");
        [player prepareToPlay];
        [player play];
    }
}

+(void) stopAudio
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    
    if([version floatValue] >= 6.0f)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    }
  
    if(player != nil && [player isPlaying])
    {
        [player stop];
    }
    
    if(bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}
+(BOOL) running
{
    if(bgTask == UIBackgroundTaskInvalid)
        return FALSE;
    return TRUE;
}

+(void) stopBackgroundTask
{
    [self stopAudio];
}

+ (void)threadId
{
    NSString *thread = [[NSThread currentThread] description];
    thread = [[thread componentsSeparatedByString:@","]lastObject];
    thread = [[thread componentsSeparatedByString:@"="]lastObject];
    DDLogInfo(@"playAudio{%d,%@++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ",[SSProcessInfo processID],thread);
}

@end
