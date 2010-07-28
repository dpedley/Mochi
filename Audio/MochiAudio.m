//
//  MochiAudio.m
//
//  Created by Douglas Pedley on 6/27/10.
//

#import "MochiAudio.h"
#import "Mochi.h"
#import "MochiAudioObject.h"

static NSMutableDictionary *sharedCoreAudioDictionary = nil;
#define COREAUDIODATA_TEMP_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

@interface MochiAudioObject (CoreAudioDataExtensionsPrivateFunctions)
@property (readonly)MochiAudio *cad;
@end

@implementation MochiAudioObject (CoreAudioDataExtensions)

// This is an atomic propery because it uses the sharedDictionary
// It is recommended to grab a local copy of the self.cad if using
// multiple times in a method.
-(MochiAudio *)cad
{
	MochiAudio *returnCad = nil;
	if (!sharedCoreAudioDictionary)
	{
		returnCad = [[[MochiAudio alloc] init] autorelease];
		sharedCoreAudioDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:returnCad, self.name, nil];
	}
	
	// If this isn't a first time create, try to find it in the dictionary
	if (!returnCad)
	{
		returnCad = [sharedCoreAudioDictionary objectForKey:self.name];
	}
	
	// If it's not found in the dictionary, create and add it to the dictionary
	if (!returnCad)
	{
		returnCad = [[[MochiAudio alloc] init] autorelease];
		[sharedCoreAudioDictionary setObject:returnCad forKey:self.name];
	}
	
	return returnCad;
}

-(void)setupPlayer
{
	MochiAudio *cad = self.cad;
	NSError *err = nil;
	AVAudioPlayer *plr = [[AVAudioPlayer alloc] initWithData:self.audio error:&err];
	
	if (err!=nil)
	{
		NSLog(@"Core Audio Data - playRecording initWithURL: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
		return;
	}
	
	cad.player = plr;
	[plr release];
}

-(void)playRecording
{
	MochiAudio *cad = self.cad;
	
	if (cad.player==nil)
	{
		[self setupPlayer];
	}
	[cad.player setNumberOfLoops:0];
	[cad.player play];
}

-(void)playRecordingLoopForever
{
	MochiAudio *cad = self.cad;
	
	if (cad.player==nil)
	{
		[self setupPlayer];
	}
	[cad.player setNumberOfLoops:-1];	
	[cad.player play];
}

-(void)playRecordingLoop:(NSUInteger)loopCount
{
	MochiAudio *cad = self.cad;
	
	if (cad.player==nil)
	{
		[self setupPlayer];
	}
	[cad.player setNumberOfLoops:loopCount];
	[cad.player play];
}

-(void)stopPlayback
{
	[[self.cad player] stop];
}

-(void)pausePlayback
{
	[[self.cad player] pause];
}

-(void)resumePlayback
{
	[self playRecording];
}

-(void)writeToURL:(NSURL *)url
{
	[self.audio writeToURL:url atomically:YES];
}

@end


@interface MochiAudio (CoreAudioDataExtensionsPrivateFunctions)

+(NSString *)transientAudioFilePath;
+(NSDictionary *)recordingSettings;

@end

static MochiAudio *sharedInstance = nil;

@implementation MochiAudio

@synthesize recorder, player;

+(MochiAudio *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
		{
			sharedInstance = [[MochiAudio alloc] init];
			[MochiAudioObject mochiSettingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
							   @"MochiAudio", @"database",
							   @"MochiAudio", @"model", nil]];	
			 
		}
    }
    return sharedInstance;
}

+(NSString *)transientAudioFilePath
{
	return [(NSString *)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] 
			stringByAppendingPathComponent:@"currentRecoring.audioFile"];
}

+(void)setDefaultAudio:(NSData *)defaultAudio
{
	[MochiAudio stopRecording];
	[MochiAudio stopPlayback];
	NSURL *url = [NSURL fileURLWithPath:[MochiAudio transientAudioFilePath]];
	[defaultAudio writeToURL:url atomically:YES];
}

+(NSDictionary *)recordingSettings
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
			[NSNumber numberWithFloat:44100.0], AVSampleRateKey,
			[NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
			[NSNumber numberWithInt:16], AVLinearPCMBitDepthKey, 
			[NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey, 
			[NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey, nil];
}

+(void)startRecording
{
	MochiAudio *cad = [MochiAudio sharedInstance];
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];

	if (!audioSession.inputIsAvailable)
	{
		UIAlertView *cantRecordAlert = [[UIAlertView alloc] initWithTitle: @"Warning"
			message: @"Audio input hardware not available"
			delegate: nil
			cancelButtonTitle:@"OK"
			otherButtonTitles:nil];
		[cantRecordAlert show];
		[cantRecordAlert release]; 
		return;
	}
	
	NSError *err = nil;
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
	
	if (err!=nil)
	{
		NSLog(@"Core Audio Data - startRecording audioSession (setCategory:AVAudioSessionCategoryPlayAndRecord): %@ %d %@", [err domain], [err code], [[err userInfo] description]);
		return;
	}
	
	err = nil;
	[audioSession setActive:YES error:&err];
	
	if (err!=nil)
	{
		NSLog(@"Core Audio Data - startRecording audioSession (setActive): %@ %d %@", [err domain], [err code], [[err userInfo] description]);
		return;
	}

	NSURL *url = [NSURL fileURLWithPath:[MochiAudio transientAudioFilePath]];
	err = nil;
	
	AVAudioRecorder *rec = [[AVAudioRecorder alloc] initWithURL:url settings:[MochiAudio recordingSettings] error:&err];
	if (rec==nil)
	{
		NSLog(@"Core Audio Data - startRecording audioSession (AVAudioRecorder init): %@ %d %@", [err domain], [err code], [[err userInfo] description]);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning"
			message: [err localizedDescription]
			delegate: nil
			cancelButtonTitle:@"OK"
			otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}

	cad.recorder = rec;
	[rec release];

	//prepare to record
	[cad.recorder setDelegate:self];
	[cad.recorder prepareToRecord];
	cad.recorder.meteringEnabled = YES;

	// start recording
	[cad.recorder recordForDuration:(NSTimeInterval) 60];
}

+(void)stopRecording
{
	[[[MochiAudio sharedInstance] recorder] stop];
}

+(void)setupPlayer
{
	MochiAudio *cad = [MochiAudio sharedInstance];
	NSURL *url = [NSURL fileURLWithPath:[MochiAudio transientAudioFilePath]];
	NSError *err = nil;
	AVAudioPlayer *plr = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
	
	if (err!=nil)
	{
		NSLog(@"Core Audio Data - playRecording initWithURL: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
		return;
	}
	
	cad.player = plr;
	[plr release];
}

+(void)playRecording
{
	MochiAudio *cad = [MochiAudio sharedInstance];
	if (cad.player==nil) 
	{
		[self setupPlayer];
	}
	[cad.player setNumberOfLoops:0];
	[cad.player play];	
}

+(void)playRecordingLoopForever
{
	MochiAudio *cad = [MochiAudio sharedInstance];
	
	if (cad.player==nil)
	{
		[self setupPlayer];
	}
	[cad.player setNumberOfLoops:-1];
	[cad.player play];
}

+(void)playRecordingLoop:(NSUInteger)loopCount
{
	MochiAudio *cad = [MochiAudio sharedInstance];
	
	if (cad.player==nil)
	{
		[self setupPlayer];
	}
	[cad.player setNumberOfLoops:loopCount];
	[cad.player play];
}

+(void)stopPlayback
{
	[[[MochiAudio sharedInstance] player] stop];
}

+(void)pausePlayback
{
	[[[MochiAudio sharedInstance] player] pause];
}

+(void)resumePlayback
{
	[[[MochiAudio sharedInstance] player] play];
}

+(void)clearRecording
{
	[[[MochiAudio sharedInstance] recorder] deleteRecording];
}

+(void)writeRecordingToURL:(NSURL *)url
{
	NSURL *origURL = [NSURL fileURLWithPath:[MochiAudio transientAudioFilePath]];
	NSFileManager *fileMgr = [[NSFileManager alloc] init];
	[fileMgr copyItemAtPath:[origURL path] toPath:[url path] error:nil];
}

+(MochiAudioObject *)saveRecordingWithName:(NSString *)recordingName
{
	MochiAudio *cad = [MochiAudio sharedInstance];
	MochiAudioObject *recording = [MochiAudioObject withAttributeNamed:@"name" matchingValue:recordingName];
	if (recording==nil)
	{
		recording = [MochiAudioObject addNew];
		recording.name = recordingName;
	}
	
	NSURL *url = [NSURL fileURLWithPath:[MochiAudio transientAudioFilePath]];
	NSError *err = nil;
	AVAudioPlayer *plr = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
	
	if (err==nil)
	{
		recording.duration = [NSNumber numberWithInt:plr.duration];
	}
	[plr release];
	err=nil;
	
	NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
	if(!audioData)
	{
		NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
	}
	else 
	{
		[recording setAudio:[NSData dataWithContentsOfURL:url]];       
	}
	recording.dateCreated = [NSDate date];
	[MochiAudioObject save];

	[cad.recorder deleteRecording];
	
/*	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	err = nil;
	[fm removeItemAtPath:[url path] error:&err];
	if(err)
	{
		NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
	}
 */
	return recording;
}

+(MochiAudioObject *)loadRecordingByName:(NSString *)recordingName
{
	return [MochiAudioObject withAttributeNamed:@"name" matchingValue:recordingName];
}

+(void)deleteRecordingByName:(NSString *)recordingName
{
	MochiAudioObject *recording = [MochiAudioObject withAttributeNamed:@"name" matchingValue:recordingName];
	[recording remove];
}

+(NSArray *)recordings
{
	NSArray *allRecordings = [MochiAudioObject allObjects];
	return allRecordings;
}

#pragma mark Note this routinue is suboptimal with the assumption that the list size and memory footprint is within acceptable limits.
+(NSArray *)recordingNames
{
	NSArray *allRecordings = [MochiAudio recordings];
	NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[allRecordings count]];
	for (MochiAudioObject *recording in allRecordings)
	{
		[mutableArray addObject:[NSString stringWithString:recording.name]];
	}
	return [NSArray arrayWithArray:mutableArray];
}

#pragma mark AVAudioRecorderDelegate (ALL OPTIONAL)

-(void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags
{
}

@end
