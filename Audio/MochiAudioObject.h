//
//  MochiAudioObject.h
//  HelloBaby
//
//  Created by Douglas Pedley on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface MochiAudioObject :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSData * audio;
@property (nonatomic, retain) NSNumber * orderIndex;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * duration;

@end



