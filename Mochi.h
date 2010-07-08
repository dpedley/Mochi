//
//  Mochi.h
//
//  Created by Douglas Pedley on 5/27/10.
//  http://dpedley.com/mochi
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Mochi : NSObject 
{
	// These are from the settings dictionary
	NSString *dataFile;
	NSString *dataModel;
	BOOL disableUndoManager;
	
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;	    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}
@property (nonatomic, retain) NSString *dataFile;
@property (nonatomic, retain) NSString *dataModel;
@property BOOL disableUndoManager;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)defaultDatabaseFromBundle;
-(void)defaultDatabaseFromBundle:(BOOL)overwriteIfExists;
+(void)settingsFromDictionary:(NSDictionary *)settingsDictionary;

+(id)sharedMochi;
+(id)mochiForClass:(Class)mochiClass;

@end

@interface NSManagedObject (Mochi)

+(void)mochiSettingsFromDictionary:(NSDictionary *)settingsDictionary;
+(NSEntityDescription *)mochiEntityDescription;
+(NSString *)indexName;
+(void)setIndexName:(NSString *)value;
+(id)addNew;
+(id)addNewWithIndex:(NSValue *)indexValue;
+(id)withMatchingIndex:(NSValue *)indexValue;
+(id)withAttributeNamed:(NSString *)field matchingValue:(id)value;
+(int)count;
+(NSArray *)allObjects;
+(NSArray *)arrayWithAttributeNamed:(NSString *)field matchingValue:(id)value;
+(void)save;
-(void)remove;
+(void)removeAll;
+(id)findOrCreateWithDictionary:(NSDictionary *)createDict;

@end

