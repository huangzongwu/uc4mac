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
}

- (void) onDoubleClick:(id)sender
{
    NSManagedObject* obj = [[mucRoomDataContext getContactsByRoomJid:[room jid]] objectAtIndex: [contactList selectedRow]];
    if (!obj) {
        return;
    }
    NSString* jid = [NSString stringWithFormat:@"%@@uc.sina.com.cn", [obj valueForKey:@"jid"]];
    [[room xmpp] startChat:jid];
}

- (void) refresh
{
    [contactList deselectRow:[contactList selectedRow]];
    [contactList reloadData];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *) aTableView
{
    if (!room) {
        return 0;
    }
    return [[mucRoomDataContext getContactsByRoomJid:[room jid]] count];
}

- (id) tableView:(NSTableView*) aTableView objectValueForTableColumn:(NSTableColumn*) aTableColumn row:(NSInteger) rowIndex
{
    MUCRoomContactItem* item = [[mucRoomDataContext getContactsByRoomJid:[room jid]] objectAtIndex:rowIndex];
	 //= [contacts objectAtIndex:rowIndex];
    if ([[aTableColumn identifier] isEqualToString:@"status"]) {
        return [ContactItem statusImage:[[item valueForKey:@"presence"] integerValue]];
    } else if ([[aTableColumn identifier]isEqualToString:@"name"]) {
        return [item valueForKey:@"name"];
    } 
	return nil;
}

@end