//
//  MUCRoomContactViewController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-6.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomContactViewController.h"
#import "ContactItem.h"
#import "MUCRoomContactItem.h"
#import "XMPPMUCRoom.h"
#import "XMPP.h"
#import "MUCRoomDataContext.h"

@implementation MUCRoomContactViewController
@synthesize room;
@synthesize contacts;

- (void) awakeFromNib
{
    [contactList setIntercellSpacing:NSMakeSize(0,0)];
    [contactList setTarget:self];
    [contactList setDoubleAction:@selector(onDoubleClick:)];
    [contactList setDelegate:self];
    [contactList setDataSource:self];
    //[contactList setAction:@selector(onClick:)];
    contacts = [[NSMutableArray alloc] init];
}

- (void) dealloc
{
    [contacts release];
}

- (void) onDoubleClick:(id)sender
{
    NSManagedObject* obj = [[arrayController arrangedObjects] objectAtIndex: [contactList selectedRow]];
    if (!obj) {
        return;
    }
    NSString* jid = [NSString stringWithFormat:@"%@@uc.sina.com.cn", [obj valueForKey:@"jid"]];
    [[room xmpp] startChat:jid];
}

- (void) setRoom:(XMPPMUCRoom*) _room
{
    room = _room;
    [self willChangeValueForKey:@"contacts"];
    [contacts addObjectsFromArray:[mucRoomDataContext getContactsByRoomJid:[_room jid]]];
    [self didChangeValueForKey:@"contacts"];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	MUCRoomContactItem* item = [contacts objectAtIndex:rowIndex];
    if ([[aTableColumn identifier] isEqualToString:@"status"]) {
        return [ContactItem statusImage:[[item valueForKey:@"presence"] integerValue]];
    } else if ([[aTableColumn identifier]isEqualToString:@"name"]) {
        return [item valueForKey:@"name"];
    } 
	return @"";
}

@end