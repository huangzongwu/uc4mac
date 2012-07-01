//
//  MUCRoomListManager.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-3.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomListManager.h"
#import "MUCRoomItem.h"

@implementation MUCRoomGroup
@synthesize info;
@synthesize rooms;

- (void) _init
{
    info = [[MUCRoomItem alloc]init];
    [info setJid:@""];
    rooms = [[NSMutableArray alloc]init];    
}

- (id) init
{
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (id) initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        [self _init];
    }
    [info setName:name];
    return self;
}

- (void) dealloc
{
    [info release];
    [rooms release];
}

- (void) updateRoom:(MUCRoomItem*) item
{
    NSEnumerator* e = [rooms objectEnumerator];
    MUCRoomItem* index;
    while((index = [e nextObject])) {
        if ([[index jid]isEqualToString:[item jid]]) {
            if ([[item name]length]) {
                [index setName:[item name]];
            }
            if ([[item key]length]) {
                [index setKey:[item key]];
            }
            if ([[item image]length]) {
                [index setImage:[item image]];
            }
            return;
        }
    }
    [rooms addObject:[item retain]];
}

- (void) removeRoom:(MUCRoomItem*) item
{
    NSEnumerator* e = [rooms objectEnumerator];
    MUCRoomItem* index;
    while((index = [e nextObject])) {
        if ([[index jid]isEqualToString:[item jid]]) {
            [rooms removeObject:index];
            return;
        }
    }
    return;
}

@end

@implementation MUCRoomGroupManager
@synthesize groups;
- (id) init
{
    self = [super init];
    if (self) {
        groups = [[NSMutableArray alloc]init];
    }
    return self;
}

- (MUCRoomGroup*)groupByName:(NSString*)name
{
    NSEnumerator* e = [groups objectEnumerator];
    MUCRoomGroup* group;
    while ((group = [e nextObject])) {
        if ([[[group info]name]isEqualToString:name]) {
            return group;
        }
    }
    return nil;
}

- (void) updateRoom:(MUCRoomItem*) item
{
    MUCRoomGroup* group = [[MUCRoomGroup alloc]initWithName:@"群组"];
    [groups addObject:group];
    if (!group) {
        return;
    }
    [group updateRoom:item];
}

@end
