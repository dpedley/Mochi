//
//  MochiLocation.h
//  MochiTestbedMacOSX
//
//  Created by Douglas Pedley on 7/6/10.
//
//  CoreData access layer from Mochi
//  http://dpedley.com/mochi
//  

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Mochi.h"
#import "MochiLocationObject.h"

@class MochiLocationObject;

@interface MochiLocationObject (MochiLocationUtilities)

-(CLLocationCoordinate2D)renderCLLocationCoordinate2D;
-(void)setAttibutesFromCoreLocation:(CLLocation *)location;

@end

@interface MochiLocation : NSObject <CLLocationManagerDelegate>
{
	CLLocationManager *locationManager;

}
@property (nonatomic, readonly) CLLocationManager *locationManager;

+(void)startRecordingLocation;
+(void)stopRecordingLocation;
+(MochiLocation *)shared;

@end
