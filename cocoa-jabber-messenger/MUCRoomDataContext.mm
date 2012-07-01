//
//  MUCRoomDataContext.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-31.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomDataContext.h"
#import "MUCRoomItem.h"
#import "MUCRoomContactItem.h"

@interface NSManagedObject(forMUCRoomGroupItem)
- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects;
@end

@implementation NSManagedObject(forMUCRoomGroupItem)
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

@implementation MUCRoomDataContext

- (NSArray*) fetchGroup
{
    NSError *fetchError = nil;   
    NSArray *fetchResults;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RoomGroup"
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
        if ([[item valueForKey:@"name"] isEqualToString:group] == YES) {
            return item;
            break;
        }
    }
    return nil;
}

- (void) insertGroup:(NSString*) name
{
    NSDictionary* dic = [NSDictionary dictionaryWithObject:name forKey:@"name"];
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"RoomGroup"
                                                         inManagedObjectContext: self];   
    [obj setValuesForKeysWithDictionary:dic];
    [self insertObject:obj];
    NSError *saveError = nil;   
    [self save:&saveError];
}

- (NSArray*) fetchRoom
{
    NSError *fetchError = nil;   
    NSArray *fetchResults;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Room"
                                              inManagedObjectContext: self];
    [fetchRequest setEntity:entity];
    fetchResults = [self executeFetchRequest:fetchRequest error:&fetchError];   
    [fetchRequest release];
    return fetchResults;
}

- (void) updateRoom:(MUCRoomItem*) room
{
    NSManagedObject* obj = [self findRoomByJid:[room jid]];
    if (!obj) {
        [self insertRoom:room];
    }
    //更新群组信息
}

- (void) insertRoom:(MUCRoomItem*) room
{
    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:[room name], @"name", [room intro], @"intro", [room jid], @"jid", nil];
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Room"
                                                         inManagedObjectContext:self];
    [obj setValuesForKeysWithDictionary:dic];
    [dic release];
    NSManagedObject* parent = [self findGroup:@"群组"];
    if (!parent) {
        return;
    }
    NSMutableSet *groupRooms = [parent mutableSetValueForKey:@"children"];
    //[groupRooms setValue:obj forKey:[obj valueForKey:@"jid"]];
    [groupRooms addObject:obj];
    NSError *saveError = nil;   
    [self save:&saveError];
}

- (NSManagedObject*) findRoomByJid:(NSString*) roomJid
{
    NSError *fetchError = nil;   
    NSArray *fetchResults;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Room"
                                              inManagedObjectContext:self];
    [fetchRequest setEntity:entity];
    fetchResults = [self executeFetchRequest:fetchRequest error:&fetchError];    
    [fetchRequest release];
    /*NSManagedObject* item = [fetchResults valueForKey:roomJid];
    return item;*/
    NSManagedObject* item;
    NSEnumerator* e = [fetchResults objectEnumerator];
    while ((item = [e nextObject])) {
        if ([roomJid isEqualToString:[item valueForKey:@"jid"]]) {
            return item;
        }
    }
    return nil;
}

- (NSArray*) getContactsByRoomJid:(NSString*) roomJid
{
    NSManagedObject* obj = [self findRoomByJid:roomJid];
    if (!obj) {
        return nil;
    } else {
        return [[obj valueForKey:@"children"] allObjects];
    }
}

- (void) updateRoomContact:(MUCRoomContactItem*) contact withRoomJid:(NSString*) roomJid
{
    NSManagedObject* obj = [self findContactByJid:[contact jid] withRoomJid:roomJid];
    [obj setValue:[NSNumber numberWithLong:[contact presence]] forKey:@"presence"];
}

- (void) updateRoomContacts:(NSMutableArray*) mucRoomContacts withRoomJid:(NSString*) roomJid
{
    NSManagedObject* room = [self findRoomByJid:roomJid];
    if (!room) {
        return;
    }
    for (NSDictionary* contactInfo in mucRoomContacts) {
        NSString* jid = [[NSString alloc ] initWithFormat:@"%@", [contactInfo valueForKey:@"uid"]];
        NSManagedObject* obj = [self findContactByJid:jid withRoomJid:roomJid];
        if (!obj) {
            MUCRoomContactItem* item = [[MUCRoomContactItem alloc] init];
            [item setName:[contactInfo valueForKey:@"nickname"]];
            [item setJid:jid];
            [self insertRoomContact:item withRoomJid:roomJid];
            [item release];
        }
        [jid release];
    }
}

- (void) setValue:(id)value forKey:(NSString*)key intoManagedObject:(NSManagedObject*) obj
{
    if (value && [value length]) {
        [obj setValue:value forKey:key];
    }
}

- (void) insertRoomContact:(MUCRoomContactItem*) contact withRoomJid:(NSString*) roomJid
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:[contact name], @"name", [contact jid], @"jid", [NSNumber numberWithInteger:[contact presence]], @"presence", nil];
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"RoomContact" inManagedObjectContext:self];
    [obj setValuesForKeysWithDictionary: dic];
    NSManagedObject* parent = [self findRoomByJid: roomJid];
    if (!parent) {
        return;
    }
    NSMutableSet *roomContacts = [parent mutableSetValueForKey:@"children"];
    [roomContacts addObject: obj];
    NSError *saveError = nil;
    [self save: &saveError];
}

- (NSInteger) contactCountInRoom:(NSString*) roomJid
{
    NSManagedObject* room = [self findRoomByJid:roomJid];
    return [[room valueForKey:@"children"] count];
}

- (NSManagedObject*) findContactByJid:(NSString*) jid withRoomJid:(NSString*) roomJid
{
    NSArray* contacts = [self getContactsByRoomJid: roomJid];
    NSEnumerator* e = [contacts objectEnumerator];
    NSManagedObject* item;
    while ((item = [e nextObject])) {
        if ([jid hasPrefix:[item valueForKey:@"jid"]]) {
            return item;
        }
    }
    return nil;
}

/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle and all of the 
 framework bundles.
 */

- (NSManagedObjectModel *)managedObjectModel {
    
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

- (NSString *) applicationSupportFolder {
    
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
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"MUCRoomsCoreData.xml"]];
    /*if (![fileManager removeItemAtURL:url error:&error]) {
        NSLog(@"Fail to clean mucrooms");
    };*/
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
        if (![self findGroup:@"群组"]) {
            [self insertGroup:@"群组"];
        }
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [persistentStoreCoordinator release];
    [super dealloc];
}
#pragma mark -
@end
