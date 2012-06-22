//
//  ContactDataContext.mm
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/21/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "ContactDataContext.h"
#import "ContactItem.h"

@interface NSManagedObject(forContactGroupItem)
- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects;
@end

@implementation NSManagedObject(forContactGroupItem)
#pragma mark *** Key-Value Observing ***
- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects
{
    [super didChangeValueForKey:inKey withSetMutation:inMutationKind usingObjects:inObjects];
    if ([inKey isEqualToString:@"children"]) {
        if ([inObjects count] == 1) {
            //NSLog(@"data added");
        }
    }
}
@end

@implementation ContactSortDescriptor
- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2
{
    if ([object1 isKindOfClass:[NSManagedObject class]]) {
        NSString* value1 = [object1 valueForKey:@"name"];
        NSString* value2 = [object2 valueForKey:@"name"];
        if ([value1 isEqualToString:DEFAULT_GROUP_NAME]) {
            return NSOrderedDescending;
        }
        else if ([value2 isEqualToString:DEFAULT_GROUP_NAME]) {
            return NSOrderedAscending;
        }
        NSComparisonResult result = [value2 compare:value1];
        return result;
    }
    return NSOrderedSame;
}
@end

@implementation ContactDataContext
#pragma mark *** Coredata Management ***
- (void)insertGroup:(NSString*)name
{
    NSDictionary* dic = [NSDictionary dictionaryWithObject:name forKey:@"name"];
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"ContactGroup"
                                                         inManagedObjectContext: self];   
    [obj setValuesForKeysWithDictionary:dic];
    [self insertObject:obj];
    NSError *saveError = nil;   
    [self save:&saveError];
}

- (NSArray*) fetchGroup
{
    NSError *fetchError = nil;   
    NSArray *fetchResults;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactGroup"
                                              inManagedObjectContext: self];
    [fetchRequest setEntity:entity];
    fetchResults = [self executeFetchRequest:fetchRequest error:&fetchError];   
    [fetchRequest release];
    return fetchResults;
}

- (NSManagedObject*) findGroup:(NSString*) group
{
    NSArray *fetchResults = [self fetchGroup];
    for (NSManagedObject* item in fetchResults) {
        if ([[item valueForKey:@"name"]isEqualToString:group] == YES) {
            return item;
            break;
        }
    }
    return nil;
}

- (NSInteger) contactCountInGroup:(NSString*) group
{
    NSManagedObject* obj = [self findGroup:group];
    NSMutableSet* groupContacts = [obj valueForKey:@"children"];
    return [groupContacts count];
}

- (void) updateGroup:(NSString*) name
{
    NSManagedObject* group = [self findGroup:name];
    if (!group) {
        [self insertGroup:name];
    }
}

- (void) insertContact:(ContactItem*) contact intoGroup:(NSString*) group
{
    if (!group) {
        group = DEFAULT_GROUP_NAME;
    } else {
        [self updateGroup:group];
    }
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:[contact name], @"name", [contact pinyin], @"pinyin", [contact jid], @"jid", [contact status], @"status", [NSNumber numberWithInteger:[contact presence]], @"presence", group, @"group", nil];
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                         inManagedObjectContext:self];
    [obj setValuesForKeysWithDictionary:dic];
    NSManagedObject* parent = [self findGroup:group];
    if (!parent) {
        return;
    }
    NSMutableSet *groupContacts = [parent mutableSetValueForKey:@"children"];  
    [groupContacts addObject:obj];
    NSError *saveError = nil;   
    [self save:&saveError];
}

- (NSManagedObject*) findContactByValue:(NSString*) value forKey:(NSString*) key
{
    if (!value || !key) {
        return nil;
    }
    NSError *fetchError = nil;   
    NSArray *fetchResults;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact"
                                              inManagedObjectContext:self];
    [fetchRequest setEntity:entity];
    fetchResults = [self executeFetchRequest:fetchRequest error:&fetchError];    
    [fetchRequest release];
    NSEnumerator* e = [fetchResults objectEnumerator];
    NSManagedObject* item;
    while ((item = [e nextObject])) {
        if ([value isEqualToString:[item valueForKey:key]]) {
            return item;
        }
    }
    return nil;
}

- (NSManagedObject*) findContactByJid:(NSString*) jid
{
    return [self findContactByValue:jid forKey:@"jid"];
}

- (NSMutableArray*) findContactsByPinyin:(NSString*) pinyin
{
    if (!pinyin) {
        return nil;
    }
    NSError* fetchError = nil;   
    NSArray* fetchResults;
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact"
                                              inManagedObjectContext:self];
    [fetchRequest setEntity:entity];
    fetchResults = [self executeFetchRequest:fetchRequest error:&fetchError];    
    [fetchRequest release];
    NSEnumerator* e = [fetchResults objectEnumerator];
    NSManagedObject* item;
    while (item = [e nextObject]) {
        NSString* name = [item valueForKey:@"pinyin"];
        int i = 0;
        do {
            NSUInteger location = [name rangeOfString:[NSString stringWithFormat:@"%c", [pinyin characterAtIndex:i]] options:NSCaseInsensitiveSearch].location;
            if (location == NSNotFound) {
                break;
            }
            name = [name substringFromIndex:location+1];
            if (++i >= pinyin.length) {
                [ret addObject:item];
                break;
            }
        } while (true);
    }
    return ret;
}

- (void) setValue:(id)value forKey:(NSString*)key intoManagedObject:(NSManagedObject*) obj
{
    if (value && [value length]) {
        [obj setValue:value forKey:key];
    }
}

- (NSInteger) setPresence:(NSInteger) presence intoManagedObject:(NSManagedObject*) obj
{
    NSNumber* oldPresence = [obj valueForKey:@"presence"];
    if ( presence == PRESENCE_UNKNOWN ) {
        return[oldPresence integerValue];
    }
    
    NSString* groupInto;
    groupInto = [obj valueForKey:@"group"];
    
    NSManagedObject* parent = [obj valueForKey:@"parent"];
    NSString* parentName = [parent valueForKey:@"name"];
    
    [obj setValue:[NSNumber numberWithInteger:presence] forKey:@"presence"];
    
    if ([groupInto isEqualToString:parentName])
    {
        // group is not changed. so return
        return[oldPresence integerValue];
    }
    
    NSManagedObject* parentObj = [self findGroup:groupInto];
    if (!parentObj) {
        [NSException raise:@"group object not found" format:@"findGroup: @% failed", groupInto];
    }
    NSMutableSet *groupContacts = [parentObj mutableSetValueForKey:@"children"];        
    [groupContacts addObject:obj];
    return[oldPresence integerValue];
}

- (NSString*) groupNameByContact:(ContactItem*) contact
{
    NSManagedObject* obj = [self findContactByJid:[contact jid]];
    if (!obj) {
        return [NSString stringWithString:DEFAULT_GROUP_NAME];
    }
    NSManagedObject* parent = [obj valueForKey:@"parent"];
    return [parent valueForKey:@"name"];
}

- (void) updateContact:(ContactItem*) contact intoGroup:(NSString*) group
{
    NSManagedObject* obj = [self findContactByJid:[contact jid]];
    if (!obj) {
        [self insertContact:contact intoGroup:group];
        return;
    }
    [self setValue:[contact name] forKey:@"name" intoManagedObject:obj];
    [self setValue:[contact status] forKey:@"status" intoManagedObject:obj];
    [self setValue:[contact photo] forKey:@"image" intoManagedObject:obj];
    [self setValue:[contact pinyin] forKey:@"pinyin" intoManagedObject:obj];
    [self setValue:group forKey:@"group" intoManagedObject:obj];
    NSInteger oldPresence = [self setPresence:[contact presence] intoManagedObject:obj];
    
	if([NSApp isActive]) {
        return;
    }
    if ([contact presence] == PRESENCE_UNKNOWN) {
        return;
    }
    BOOL notify = NO;
    if ((oldPresence == PRESENCE_OFFLINE || oldPresence == PRESENCE_UNKNOWN)) {
        if ( [contact presence] != PRESENCE_OFFLINE ) {
            notify = YES;
        }
    } else if ([contact presence] == PRESENCE_OFFLINE ) {
        notify = YES;
    }
    if (notify) {
        if (![[contact name]length]) {
            [contact setName:[obj valueForKey:@"name"]];
        }
        if (![[contact name]length]) {
            [contact setName:[obj valueForKey:@"jid"]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactStatus" object:contact] ;
    }
}


#pragma mark -

/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle and all of the 
 framework bundles.
 */

- (NSManagedObjectModel*) managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSMutableSet *allBundles = [[NSMutableSet alloc] init];
    [allBundles addObject: [NSBundle mainBundle]];
    [allBundles addObjectsFromArray: [NSBundle allFrameworks]];
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
    [allBundles release];
    return managedObjectModel;
}

/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "CoreDataOutlineView" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"UC4Mac"];
}

/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"ContactsCoreData.xml"]];
    if (![fileManager removeItemAtURL:url error:&error]) {
        NSLog(@"Fail to clean contacts");
    };
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }
    return persistentStoreCoordinator;
}

- (void) awakeFromNib
{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        [self setPersistentStoreCoordinator: coordinator];
    }
    ContactSortDescriptor* sortDescriptor = [[ContactSortDescriptor alloc] init];
    NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [treeController setSortDescriptors:sortDescriptors];
    [sortDescriptor release];
}

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) dealloc
{
    [persistentStoreCoordinator release];
    [super dealloc];
}
#pragma mark -
@end

