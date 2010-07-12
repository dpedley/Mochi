//
//  MochiLocation.m
//  MochiTestbedMacOSX
//
//  Created by Douglas Pedley on 7/6/10.
//
// Adapted from sources such as:
// http://developer.apple.com/iphone/library/documentation/DataManagement/Conceptual/iPhoneCoreData01/Articles/04_Adding.html


#import "MochiLocation.h"

@implementation MochiLocationObject (MochiLocationUtilities)

-(CLLocationCoordinate2D)renderCLLocationCoordinate2D
{
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = [self.latitude doubleValue];
	coordinate.latitude = [self.latitude doubleValue];
	return coordinate;
}

-(void)setAttibutesFromCoreLocation:(CLLocation *)location
{
	CLLocationCoordinate2D coordinate = [location coordinate];
	[self setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
	[self setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
	[self setDatestamp:[NSDate date]];
}

@end





static MochiLocation *sharedInstance = nil;

@implementation MochiLocation

#pragma mark -
#pragma mark class instance methods

#pragma mark -
#pragma mark Singleton methods

@synthesize locationManager;
-(CLLocationManager *)locationManager 
{
	
    if (locationManager != nil) {
        return locationManager;
    }
	
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
	
    return locationManager;
}

-(void)dealloc 
{
    [locationManager release];
    [super dealloc];
}

+(MochiLocation *)shared
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[MochiLocation alloc] init];
			[MochiLocationObject mochiSettingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
														   @"MochiLocation", @"database",
														   @"MochiLocation", @"model", nil]];	
    }
    return sharedInstance;
}

+(id)allocWithZone:(NSZone *)zone 
{
    @synchronized(self) 
	{
        if (sharedInstance == nil) 
		{
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(id)retain 
{
    return self;
}

-(unsigned)retainCount 
{
    return UINT_MAX;  // denotes an object that cannot be released
}

-(void)release 
{
    //do nothing
}

-(id)autorelease 
{
    return self;
}


#pragma mark -
#pragma mark CLLocationManagerDelegate methods

+(void)startRecordingLocation
{
	[[[self shared] locationManager] startUpdatingLocation];
}

+(void)stopRecordingLocation
{
	[[[self shared] locationManager] stopUpdatingLocation];
}



/*
 - (void)locationManager:(CLLocationManager *)managerdidEnterRegion:(CLRegion *)region
 Parameters
 manager
 The location manager object reporting the event.
 region
 An object containing information about the region that was entered.
 Discussion
 Because regions are a shared application resource, every active location manager object delivers this message to its associated delegate. It does not matter which location manager actually registered the specified region. And if multiple location managers share a delegate object, that delegate receives the message multiple times.
 
 The region object provided may not be the same one that was registered. As a result, you should never perform pointer-level comparisons to determine equality. Instead, use the region’s identifier string to determine if your delegate should respond.
 
 Availability
 Available in iPhone OS 4.0 and later.
 Declared In
 CLLocationManagerDelegate.h
 locationManager:didExitRegion:
 Tells the delegate that the user left the specified region.
- (void)locationManager:(CLLocationManager *)managerdidEnterRegion:(CLRegion *)region
{
}
 */


/*
 - (void)locationManager:(CLLocationManager *)managerdidExitRegion:(CLRegion *)region
 Parameters
 manager
 The location manager object reporting the event.
 region
 An object containing information about the region that was exited.
 Discussion
 Because regions are a shared application resource, every active location manager object delivers this message to its associated delegate. It does not matter which location manager actually registered the specified region. And if multiple location managers share a delegate object, that delegate receives the message multiple times.
 
 The region object provided may not be the same one that was registered. As a result, you should never perform pointer-level comparisons to determine equality. Instead, use the region’s identifier string to determine if your delegate should respond.
 
 Availability
 Available in iPhone OS 4.0 and later.
 Declared In
 CLLocationManagerDelegate.h
 locationManager:didFailWithError:
 Tells the delegate that the location manager was unable to retrieve a location value.
- (void)locationManager:(CLLocationManager *)managerdidExitRegion:(CLRegion *)region
{
}
 */
	
/*
 - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
 Parameters
 manager
 The location manager object that was unable to retrieve the location.
 error
 The error object containing the reason why the location or heading could not be retrieved.
 Discussion
 Implementation of this method is optional. You should implement this method, however.
 
 If the location service is unable to retrieve a location fix right away, it reports a kCLErrorLocationUnknown error and keeps trying. In such a situation, you can simply ignore the error and wait for a new event.
 
 If the user denies your application’s use of the location service, this method reports a kCLErrorDenied error. Upon receiving such an error, you should stop the location service.
 
 If a heading could not be determined because of strong interference from nearby magnetic fields, this method returns kCLErrorHeadingFailure.
 
 Availability
 Available in iPhone OS 2.0 and later.
 See Also
 CLError
 Declared In
 CLLocationManagerDelegate.h
 locationManager:didUpdateHeading:
 Tells the delegate that the location manager received updated heading information.
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	//kCLErrorDenied - set application user denied count.
	//kCLErrorLocationUnknown - should continue to try
}
	
/*
 - (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
 Parameters
 manager
 The location manager object that generated the update event.
 newHeading
 The new heading data.
 Discussion
 Implementation of this method is optional but expected if you start heading updates using the startUpdatingHeading method.
 
 The location manager object calls this method after you initially start the heading service. Subsequent events are delivered when the previously reported value changes by more than the value specified in the headingFilter property of the location manager object.
 
 Availability
 Available in iPhone OS 3.0 and later.
 Declared In
 CLLocationManagerDelegate.h
 locationManager:didUpdateToLocation:fromLocation:
 Tells the delegate that a new location value is available.
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
}
 */
	
/*
 - (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
 Parameters
 manager
 The location manager object that generated the update event.
 newLocation
 The new location data.
 oldLocation
 The location data from the previous update. If this is the first update event delivered by this location manager, this parameter is nil.
 Discussion
 Implementation of this method is optional. You should implement this method, however.
 
 By the time this message is delivered to your delegate, the new location data is also available directly from the CLLocationManager object. The newLocation parameter may contain the data that was cached from a previous usage of the location service. You can use the timestamp property of the location object to determine how recent the location data is.
 
 Availability
 Available in iPhone OS 2.0 and later.
 Declared In
 CLLocationManagerDelegate.h
 locationManager:monitoringDidFailForRegion:withError:
 Tells the delegate that a region monitoring error occurred.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	MochiLocationObject *loc = [MochiLocationObject addNew];
	[loc setAttibutesFromCoreLocation:newLocation];
	[MochiLocationObject save];
}
	
/*
 - (void)locationManager:(CLLocationManager *)managermonitoringDidFailForRegion:(CLRegion *)regionwithError:(NSError *)error
	Parameters
	manager
	The location manager object reporting the event.
	region
	The region for which the error occurred.
	error
	An error object containing the error code that indicates why region monitoring failed.
	Discussion
	If an error occurs while trying to monitor a given region, the location manager sends this message to its delegate. Region monitoring might fail because the region itself cannot be monitored or because there was a more general failure in configuring the region monitoring service.

	Although implementation of this method is optional, it is recommended that you implement it if you use region monitoring in your application.

	Availability
	Available in iPhone OS 4.0 and later.
	Declared In
	CLLocationManagerDelegate.h
	locationManagerShouldDisplayHeadingCalibration:
	Asks the delegate whether the heading calibration alert should be displayed.
- (void)locationManager:(CLLocationManager *)managermonitoringDidFailForRegion:(CLRegion *)regionwithError:(NSError *)error
{
}
 */

/*
 - (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
 
 Parameters
 manager
 The location manager object coordinating the display of the heading calibration alert.
 Return Value
 YES if you want to allow the heading calibration alert to be displayed or NO if you do not.
 
 Discussion
 Core Location may call this method in an effort to calibrate the onboard hardware used to determine heading values. Typically, Core Location calls this method at the following times:
 
 The first time heading updates are ever requested
 When Core Location observes a significant change in magnitude or inclination of the observed magnetic field
 If you return YES from this method, Core Location displays the heading calibration alert on top of the current window immediately. The calibration alert prompts the user to move the device in a particular pattern so that Core Location can distinguish between the Earth’s magnetic field and any local magnetic fields. The alert remains visible until calibration is complete or until you explicitly dismiss it by calling the dismissHeadingCalibrationDisplay method. In this latter case, you can use this method to set up a timer and dismiss the interface after a specified amount of time has elapsed.
 
 Note: The calibration process is able to filter out only those magnetic fields that move with the device. To calibrate a device that is near other sources of magnetic interference, the user must either move the device away from the source or move the source in conjunction with the device during the calibration process.
 If you return NO from this method or do not provide an implementation for it in your delegate, Core Location does not display the heading calibration alert. Even if the alert is not displayed, calibration can still occur naturally when any interfering magnetic fields move away from the device. However, if the device is unable to calibrate itself for any reason, the value in the headingAccuracy property of any subsequent events will reflect the uncalibrated readings.
 
 Availability
 Available in iPhone OS 3.0 and later.
 Declared In
 CLLocationManagerDelegate.h
 */
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
	return NO;
}

#pragma mark -

@end
