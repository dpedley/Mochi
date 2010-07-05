//
//  MochiAudio.h
//
//  Created by Douglas Pedley on 6/27/10.
//  
//  CoreData access layer from Mochi
//  http://dpedley.com/mochi
//  
//  CoreAudio AVAudioRecoder AudioUnit reference
//  http://developer.apple.com/iphone/library/documentation/musicaudio/Conceptual/CoreAudioOverview/CoreAudioEssentials/CoreAudioEssentials.html#//apple_ref/doc/uid/TP40003577-CH10-SW10
//  http://developer.apple.com/iphone/library/documentation/AudioUnit/Reference/AudioUnitPropertiesReference/Reference/reference.html
//  http://developer.apple.com/IPhone/library/documentation/AVFoundation/Reference/AVAudioRecorder_ClassReference/Reference/Reference.html
//  
//  Singleton logic
//  http://stackoverflow.com/questions/145154/what-does-your-objective-c-singleton-look-like
//  
//  Audio Recording abstracted from
//  http://stackoverflow.com/questions/1010343/how-do-i-record-audio-on-iphone-with-avaudiorecorder
//  
//  
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "MochiAudioObject.h"

@class MochiAudio;

@interface MochiAudioObject (CoreAudioDataExtensions)
-(void)playRecording;
-(void)playRecordingLoopForever;
-(void)playRecordingLoop:(NSUInteger)loopCount; // -1 is infinite
-(void)stopPlayback;
-(void)pausePlayback;
-(void)resumePlayback;

-(void)writeToURL:(NSURL *)url;

@end

@interface MochiAudio : NSObject <AVAudioRecorderDelegate>
{
	AVAudioRecorder *recorder;
	AVAudioPlayer *player;
}
@property (nonatomic, retain) AVAudioRecorder *recorder;
@property (nonatomic, retain) AVAudioPlayer *player;

+(void)setDefaultAudio:(NSData *)defaultAudio;
+(void)startRecording;
+(void)stopRecording;
+(void)playRecording;
+(void)playRecordingLoopForever;
+(void)playRecordingLoop:(NSUInteger)loopCount; // -1 is infinite
+(void)stopPlayback;
+(void)pausePlayback;
+(void)resumePlayback;
+(void)clearRecording;

+(void)writeRecordingToURL:(NSURL *)url;

+(MochiAudio *)sharedInstance;

+(MochiAudioObject *)saveRecordingWithName:(NSString *)recordingName;
+(MochiAudioObject *)loadRecordingByName:(NSString *)recordingName;
+(void)deleteRecordingByName:(NSString *)recordingName;
+(NSArray *)recordings;
+(NSArray *)recordingNames;

@end
