//
//  MUCRoomListManager.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-3.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUCRoomItem;

@interface MUCRoomGroup :NSObject
{
@private
    const NSMutableArray* rooms;
    const MUCRoomItem* info;
}
@property (assign) MUCRoomItem* info;
@property (assign) NSMutableArray* rooms;

- (void) updateRoom:(MUCRoomItem*) item;
- (void) removeRoom:(MUCRoomItem*) item;
@end


@interface MUCRoomGroupManager : NSObject {
@private
    NSMutableArray* groups;
}
@property (assign) NSMutableArray* groups;

- (MUCRoomGroup*)groupByName:(NSString*) name;
- (void) updateRoom:(MUCRoomItem*) item;
@end