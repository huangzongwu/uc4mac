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

@implementation MUCRoomContactViewController
@synthesize room;
@synthesize contacts;

- (void) awakeFromNib
{
    NSLog(@"awake from nib");
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
    NSLog(@"dealloc of contact view controller");
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

- (void) updateContact:(MUCRoomContactItem*) mucRoomContact
{
    for (MUCRoomContactItem* item in contacts) {
        if ([[mucRoomContact jid] isEqualToString:[item jid]]) {
            [contacts replaceObjectAtIndex:[contacts indexOfObject:item] withObject:mucRoomContact];
        }
    }
    [contactList reloadData];
}

- (void) initContacts:(NSArray*) mucRoomContacts
{
    for (NSManagedObject* contact in mucRoomContacts){
        MUCRoomContactItem* item = [[MUCRoomContactItem alloc] init];
        [item setJid: [contact valueForKey:@"jid"]];
        [item setName: [contact valueForKey:@"name"]];
        [self willChangeValueForKey:@"contacts"];
        [contacts addObject:item];
        [self didChangeValueForKey:@"contacts"];
        [item release];
    }
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *) aTableView
{
    NSLog(@"%@", [room jid]);
	return [contacts count];
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