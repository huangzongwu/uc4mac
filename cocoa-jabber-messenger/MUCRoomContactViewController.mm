//
//  MUCRoomContactViewController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-6.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomContactViewController.h"
#import "XMPP.h"

@implementation MUCRoomContactViewController
@synthesize xmpp;
@synthesize contacts;

- (void) awakeFromNib
{
    NSLog(@"awake from nib");
    [contactList setIntercellSpacing:NSMakeSize(0,0)];
    [contactList setTarget:self];
    [contactList setDoubleAction:@selector(onDoubleClick:)];
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
    [xmpp startChat:jid];
}

- (void) updateContacts:(NSArray*) mucRoomContacts
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

@end