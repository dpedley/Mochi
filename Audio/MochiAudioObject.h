//
//  DataRecording.h
//  Wombilizer
//
//  Created by Douglas Pedley on 6/28/10.
//

#import <CoreData/CoreData.h>


@interface MochiAudioObject :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSData * audio;
@property (nonatomic, retain) NSNumber * orderIndex;
@property (nonatomic, retain) NSString * name;

@end



