//
//  Mochi.h
//
//  Created by Douglas Pedley on 5/27/10.
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

@end

@interface NSManagedObject (Mochi)

+(NSEntityDescription *)mochiEntityDescription;
+(NSString *)mochiIndexName;
+(void)setMochiIndexName:(NSString *)value;
+(id)mochiCreate;
+(id)mochiCreateWithIndex:(NSValue *)indexValue;
+(id)mochiCreateFromDictionary:(NSDictionary *)dict;
+(id)mochiByIndex:(NSValue *)indexValue;
+(id)mochiWithField:(NSString *)field matchingValue:(id)value;
+(int)mochiCount;
+(NSArray *)mochiAll;
+(NSArray *)mochiAllWithSortDescriptor:(NSSortDescriptor *)sortDescriptor;
+(NSArray *)mochiAllMatchingFieldsAndValuesFromDictionary:(NSDictionary *)dict;
+(NSArray *)mochiAllWithField:(NSString *)field matchingValue:(id)value;
-(NSError *)mochiSave;
+(NSError *)mochiSave;
-(NSError *)mochiDelete;
+(NSError *)mochiDeleteAll;
-(void)mochiCopyAttributes:(NSManagedObject *)sourceObject;
-(void)mochiCopyRelationships:(NSManagedObject *)sourceObject;
-(void)mochiApplyFromDictionary:(NSDictionary *)dict;
-(id)mochiCopy;

@end

