//
//  MochiLocationObject.h
//  MochiTestbedMacOSX
//
//  Created by Douglas Pedley on 7/6/10.
//

#import <CoreData/CoreData.h>


@interface MochiLocationObject :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * datestamp;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;

@end



