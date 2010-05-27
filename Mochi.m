//
//  Mochi.m
//
//  Created by Douglas Pedley on 5/27/10.
//

#import "Mochi.h"

#define MOCHI_DOCUMENTS_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

static Mochi *sharedMochi = nil;

@implementation Mochi

@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator, dataFile, dataModel, disableUndoManager;

#pragma mark Initial settings
+(void)settingsFromDictionary:(NSDictionary *)settingsDictionary
{
	NSString *database  = [[settingsDictionary valueForKey:@"database"] stringByAppendingString:@".sqlite"];
	NSString *model = [settingsDictionary valueForKey:@"model"];
	NSNumber *bDisableUndoManager = [settingsDictionary valueForKey:@"disableUndoManager"];
	
	Mochi *mochi = [Mochi sharedMochi];
	mochi.dataFile = database;
	mochi.dataModel = model;
	
	if (bDisableUndoManager!=nil) 
	{
		mochi.disableUndoManager = [bDisableUndoManager boolValue];
	}
	else 
	{
		mochi.disableUndoManager = NO;
	}
}

-(void)defaultDatabaseFromBundle
{
	[self defaultDatabaseFromBundle:NO];
}

-(void)defaultDatabaseFromBundle:(BOOL)overwriteIfExists
{
    NSString *toDB = [MOCHI_DOCUMENTS_DIRECTORY stringByAppendingPathComponent:self.dataFile];
    NSString *fromDB = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:self.dataFile];
	
	// Only copy the default database if it doesn't already exist
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (!overwriteIfExists && [fileManager fileExistsAtPath:toDB]) 
	{
		return;
	}
	
	
    NSError *error;
    if (![fileManager copyItemAtPath:fromDB toPath:toDB error:&error]) 
	{
        NSLog(@"Couldn't copy database from application bundle \n[%@].", [error localizedDescription]);
    }
}

#pragma mark NSManagedObjectContext, NSPersistentStoreCoordinator, NSManagedObjectModel property accessors  

-(NSManagedObjectContext *)managedObjectContext 
{
    if (managedObjectContext!=nil) 
	{
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	
	if (coordinator!=nil) 
	{
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
		if (disableUndoManager) { [managedObjectContext setUndoManager:nil]; }
    }
	
    return managedObjectContext;
}

-(NSManagedObjectModel*)managedObjectModel 
{
	if (managedObjectModel) 
	{
		return managedObjectModel;
	}
	
	NSURL *momFile = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[Mochi class]] pathForResource:self.dataModel ofType:@"mom"]];
	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momFile];
	return managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (persistentStoreCoordinator != nil) 
	{
        return persistentStoreCoordinator;
    }
	
    NSURL *pscUrl = [NSURL fileURLWithPath:[MOCHI_DOCUMENTS_DIRECTORY stringByAppendingPathComponent: self.dataFile]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSError *error;
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:pscUrl options:nil error:&error]) 
	{
		NSLog(@"Error adding persistant store coordinator %@", [error localizedDescription]);
    }
	
    return persistentStoreCoordinator;
}

-(void)dealloc 
{
	[managedObjectModel release];
	[managedObjectContext release];
	[persistentStoreCoordinator release];
	
    [super dealloc];
}

#pragma mark Singleton Helpers

+(Mochi *)sharedMochi 
{ 
	@synchronized(self) 
	{ 
		if (sharedMochi == nil) 
		{ 
			sharedMochi = [[self alloc] init]; 
		} 
	} 
	
	return sharedMochi; 
} 

+(id)allocWithZone:(NSZone *)zone 
{
	@synchronized(self)
	{
		if (sharedMochi == nil)
		{
			sharedMochi = [super allocWithZone:zone];
			return sharedMochi;
		}
	}
	return nil; 
} 

-(id)copyWithZone:(NSZone *)zone 
{ 
	return self; 
} 

-(id)retain 
{ 
	return self; 
} 

-(NSUInteger)retainCount 
{ 
	return NSUIntegerMax; 
} 

-(void)release 
{ 
} 

-(id)autorelease 
{ 
	return self; 
}



@end



/*
 
 These are the Mochi Managed Object Category Additions
 they are helpers to do the common database load, save, search type of functionality
 
 */

static NSMutableDictionary *mochiClassIDs = nil;
static NSError *mochiLastError;

@implementation NSManagedObject (Mochi)

+(NSEntityDescription *)mochiEntityDescription
{
	return [NSEntityDescription entityForName:[self description] inManagedObjectContext:[[Mochi sharedMochi] managedObjectContext]];
}

+(NSString *)mochiIndexName
{
	return [mochiClassIDs valueForKey:[self description]];
}

+(void)setMochiIndexName:(NSString *)value
{
	if (mochiClassIDs==nil) 
	{
		mochiClassIDs = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[value retain], [self description], nil];
	}
	else 
	{
		[mochiClassIDs setValue:[value retain] forKey:[self description]];
	}
}

+(id)mochiCreate 
{
	return [NSEntityDescription insertNewObjectForEntityForName:[self description] inManagedObjectContext:[[Mochi sharedMochi] managedObjectContext]];
}

+(id)mochiCreateWithIndex:(NSNumber *)ID 
{
	id newObject = [self mochiCreate];
	NSString *fieldNameID = [self mochiIndexName];
	if (fieldNameID!=nil)
	{
		[(NSManagedObject *)newObject setValue:ID forKey:fieldNameID];
	}
	return newObject;
}

+(id)mochiByIndex:(NSValue *)indexValue
{
	NSString *ndxName = [self mochiIndexName];
	if (ndxName!=nil)
	{
		return [self mochiWithField:ndxName matchingValue:indexValue];
	}
	return nil;
}

+(int)mochiCount
{
	NSFetchRequest *req = [[[NSFetchRequest alloc] init] autorelease];
	req.entity = [self mochiEntityDescription];
	NSUInteger fetchCount = [[[Mochi sharedMochi] managedObjectContext] countForFetchRequest:req error:&mochiLastError];
	return fetchCount;
}

+(id)mochiAll
{
	return [self mochiAllWithSortDescriptor:nil];
}

+(id)mochiAllWithSortDescriptor:(NSSortDescriptor *)sortDescriptor 
{
	NSFetchRequest *req = [[[NSFetchRequest alloc] init] autorelease];
	req.entity = [self mochiEntityDescription];
	if (sortDescriptor)
	{
		[req setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}
	
	NSArray *fetchResponse = [[[Mochi sharedMochi] managedObjectContext] executeFetchRequest:req error:&mochiLastError];
	return [fetchResponse mutableCopy];	
}

+(id)mochiAllMatchingFieldsAndValuesFromDictionary:(NSDictionary *)dict 
{
	NSFetchRequest *req = [[[NSFetchRequest alloc] init] autorelease];
	req.entity = [self mochiEntityDescription];
	
	NSMutableDictionary *predicateValuesDictionary = [NSMutableDictionary dictionaryWithCapacity:[dict count]];
	NSString *predicateString = @"";
	NSString *predicateSeparator = @"";
	NSEnumerator *e = [dict keyEnumerator];
	
	NSMutableString *dictKey = nil;
	while ((dictKey = [e nextObject])) 
	{
		NSString *replaceDictKey = [[dictKey uppercaseString] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
		predicateString = [predicateString stringByAppendingFormat:@"%@(%@ = $%@)", predicateSeparator, dictKey, replaceDictKey];
		predicateSeparator = @" AND ";
		[predicateValuesDictionary setValue:[dict valueForKey:dictKey] forKey:replaceDictKey];
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
	predicate = [predicate predicateWithSubstitutionVariables:predicateValuesDictionary];
	[req setPredicate:predicate];
	
	NSArray *fetchResponse = [[[Mochi sharedMochi] managedObjectContext] executeFetchRequest:req error:&mochiLastError];
	
	if ((fetchResponse != nil) || ([fetchResponse count]>0))
	{
		id retArray = [fetchResponse mutableCopy];
		return retArray;
	}
	return nil;
}

+(id)mochiAllWithField:(NSString *)field matchingValue:(id)value
{
	NSFetchRequest *req = [[[NSFetchRequest alloc] init] autorelease];
	req.entity = [self mochiEntityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = $VALUE", field, nil]];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:value forKey:@"VALUE"]];
	[req setPredicate:predicate];
	
	NSArray *fetchResponse = [[[Mochi sharedMochi] managedObjectContext] executeFetchRequest:req error:&mochiLastError];
	if ((fetchResponse != nil) || ([fetchResponse count]>0))
	{
		id retArray = [fetchResponse mutableCopy];
		return retArray;
	}
	return nil;
}


+(id)mochiWithField:(NSString *)field matchingValue:(id)value
{
	if ((field==nil) || (value==nil)) { return nil; }
	NSFetchRequest *req = [[[NSFetchRequest alloc] init] autorelease];
	req.entity = [self mochiEntityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = $VALUE", field, nil]];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:value forKey:@"VALUE"]];
	[req setPredicate:predicate];
	
	NSError *error;
	NSArray *fetchResponse = [[[Mochi sharedMochi] managedObjectContext] executeFetchRequest:req error:&error];

	if ((fetchResponse==nil) || ([fetchResponse count]==0)) 
	{
		return nil;
	}

	return [fetchResponse objectAtIndex:0];
}

+(id)mochiCreateFromDictionary:(NSDictionary *)dict 
{
	NSString *ndxName = [self mochiIndexName];
	
	NSManagedObject *ret = nil;
	
	if (ndxName!=nil) 
	{
		NSNumber *ndxValue = [dict valueForKey:ndxName];
		
		if (ndxValue!=nil) 
		{
			ret = [self mochiByIndex:ndxValue];
		}
		else 
		{
			ret = [self mochiCreateWithIndex:ndxValue];
		}

	}
	
	if (!ret) 
	{
		ret = [self mochiCreate];
	}
	
	[ret mochiApplyFromDictionary:dict];
	return ret;
}

-(NSError *)mochiSave 
{
	NSError *error;
	[[self managedObjectContext] save:&error];
	return error;
}

+(NSError *)mochiSave 
{
	return [[Mochi sharedMochi] mochiSave];
}

-(NSError *)mochiDelete
{
    NSError *error;
	Mochi *mochi = [Mochi sharedMochi];
	[mochi.managedObjectContext deleteObject:self];
	[mochi.managedObjectContext save:&error];
	return error;
}

+(NSError *)mochiDeleteAll
{
    NSError *error;
	Mochi *mochi = [Mochi sharedMochi];
	
	NSArray *all = [self mochiAll];
	
	NSEnumerator *e = [all objectEnumerator];
	id currentObject;
	while (currentObject = [e nextObject]) 
	{
		[mochi.managedObjectContext deleteObject:currentObject];
	}
	
	[mochi.managedObjectContext save:&error]; 
	return error;
}

-(void)mochiApplyFromDictionary:(NSDictionary *)dict 
{
	NSDictionary *entityDict = [[self entity] attributesByName];
	NSArray *names=[entityDict allKeys];
	unsigned long i;
	
	for (i=0;i<[names count];i++) {
		NSString *name=[names objectAtIndex:i];
		NSValue *val = [dict valueForKey:name];
		
		if ((val!=nil) && (![val isKindOfClass:[NSNull class]])) 
		{
			NSAttributeDescription *attributeDescription = [entityDict valueForKey:name];
			switch ([attributeDescription attributeType]) 
			{
				case NSBooleanAttributeType: 
				{
					if ([[(NSString *)val lowercaseString] isEqualToString:@"true"]) 
					{
						[self setValue:[NSNumber numberWithBool:YES] forKey:name];
					}
					else 
					{
						[self setValue:[NSNumber numberWithBool:NO] forKey:name];
					}
				}
					break;
				case NSDateAttributeType: 
				{
					NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
					[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
					[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
					[self setValue:[dateFormatter dateFromString:(NSString *)val] forKey:name];
				}
					break;
				case NSDecimalAttributeType: 
				case NSInteger16AttributeType: 
				case NSInteger32AttributeType: 
				{
					if (![val isKindOfClass:[NSString class]]) 
					{
						[self setValue:val forKey:name];
					}
				}
					break;
				default:
					[self setValue:val forKey:name];
					break;
			}
		}
	}
	[self mochiSave];
	
	NSDictionary *entityRelationships=[[self entity] relationshipsByName];
	names=[entityRelationships allKeys];
	
	for (i=0;i<[names count];i++)
	{
		NSString *name=[names objectAtIndex:i];
		NSObject *val = [dict valueForKey:name];
		
		if (val!=nil) 
		{ // The dict won't have a value for any inverseRelationship keys, so we don't have to worry about infinite recursion.
			NSRelationshipDescription *relationshipDescription = [entityRelationships objectForKey:name];
			NSEntityDescription *relationshipEntity = [relationshipDescription destinationEntity];
			
			Class entityClass = objc_getClass([[relationshipEntity managedObjectClassName] UTF8String]);
			if (![relationshipDescription isToMany]) 
			{
				if ([val isKindOfClass:[NSDictionary class]]) 
				{
					id newMochiObject = [entityClass performSelector:@selector(mochiCreate)];
					[self setValue:newMochiObject forKey:name];
					[newMochiObject mochiApplyFromDictionary:(NSDictionary *)val];
					[self mochiSave];
				}
			} 
			else 
			{
				if ([val isKindOfClass:[NSArray class]]) 
				{
					NSEnumerator *subDictionaries = [(NSArray *)val objectEnumerator];
					NSDictionary *subDictionary = nil;
					
					NSString *addSelectorString = [NSString stringWithFormat:@"add%@%@Object:", [[name substringToIndex:1] uppercaseString], [name substringFromIndex:1]];
					SEL addSel = NSSelectorFromString(addSelectorString);
					
					while ((subDictionary = [subDictionaries nextObject])) 
					{
						id newMochiObject = [entityClass performSelector:@selector(createNewObject)];
						[self performSelector:addSel withObject:newMochiObject];
						[newMochiObject mochiApplyFromDictionary:(NSDictionary *)subDictionary];
						[self mochiSave];
					}
				}
			}
		}
	}
}


-(void)mochiCopyAttributes:(NSManagedObject *)mochiSource 
{
	NSArray *attributeNames=[[[mochiSource entity] attributesByName] allKeys];
	NSString *indexName = [[self class] mochiIndexName];
	for (int i=0;i<[attributeNames count];i++)
	{
		NSString *name=[attributeNames objectAtIndex:i];
		if (![indexName isEqualToString:name])
		{
			[self setValue:[mochiSource valueForKey:name] forKey:name];
		}
	}
	[self mochiSave];
}

-(void)mochiCopyRelationships:(NSManagedObject *)sourceObject 
{
	NSDictionary *relationships=[[sourceObject entity] relationshipsByName];
	NSArray *names=[relationships allKeys];
	for (int i=0; i<[names count]; i++)
	{
		NSString *name=[names objectAtIndex:i];
		if (![[relationships objectForKey: name] isToMany] || ![[relationships objectForKey:name] inverseRelationship])
		{
			[self setValue:[sourceObject valueForKey:name] forKey:name];
		}
	}
	[self mochiSave];
}

-(id)mochiCopy
{
	NSManagedObject *newMochi = [[self class] mochiCreate];
	[newMochi mochiCopyAttributes:self];
	[newMochi mochiCopyRelationships:self];
	return newMochi;
}

@end

