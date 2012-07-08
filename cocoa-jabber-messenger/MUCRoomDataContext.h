//
//  MUCRoomDataContext.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-31.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUCRoomItem;
@class MUCRoomContactItem;
@interface MUCRoomDataContext : NSManagedObjectContext {
@private
    id lock;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;    
    IBOutlet NSTreeController* roomsTreeController;
}

//返回全部的群组分组（群）
- (NSArray*) fetchGroup;

//插入一个分组
- (void) insertGroup:(NSString*) name;

//返回一个指定名称的分组
- (NSManagedObject*) findGroup:(NSString*) group;

//返回全部的群组
- (NSArray*) fetchRoom;

//更新一个群组信息
- (void) updateRoom:(MUCRoomItem*) room;

//插入一个新的群组
- (void) insertRoom:(MUCRoomItem*) room;

//返回指定群组jid的群组
- (NSManagedObject*) findRoomByJid:(NSString*) roomJid;

//返回指定群组jid的全部联系人
- (NSArray*) getContactsByRoomJid:(NSString*) roomJid;

- (void) updateRoomContact:(MUCRoomContactItem*) contact withRoomJid:(NSString*) roomJid;

//更新指定群组jid的联系人列表
- (void) updateRoomContacts:(NSMutableArray*) mucRoomContacts withRoomJid:(NSString*) roomJid;

//向指定群组jid的群组中插入联系人
- (void) insertRoomContact:(MUCRoomContactItem*) mucRoomContact withRoomJid:(NSString*) roomJid;

- (void) setValue:(id)value forKey:(NSString*)key intoManagedObject:(NSManagedObject*) obj;

//返回群组中联系人数量
- (NSInteger) contactCountInRoom:(NSString*) roomJid;

//返回指定群组jid指定jid的联系人
- (NSManagedObject*) findContactByJid:(NSString*) jid withRoomJid:(NSString*) roomJid;

@end
