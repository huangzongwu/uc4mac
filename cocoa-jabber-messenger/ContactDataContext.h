//
//  ContactDataContext.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/21/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ContactItem;

@interface ContactSortDescriptor : NSSortDescriptor {
@private
    
}
@end

@interface ContactDataContext : NSManagedObjectContext {
@private
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    IBOutlet NSTreeController* treeController;
}
- (NSManagedObject*) findContactByJid:(NSString*) jid;
- (NSMutableArray*) findContactsByPinyin:(NSString*) pinyin;
- (void) updateContact:(ContactItem*) contact intoGroup:(NSString*) group;
- (NSInteger) contactCountInGroup:(NSString*) group;
- (NSString*) groupNameByContact:(ContactItem*) contact;
@end
