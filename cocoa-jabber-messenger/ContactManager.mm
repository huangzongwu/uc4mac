//
//  ContactManager.mm
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/18/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "ContactManager.h"
#import "ContactItem.h"

@implementation ContactGroup
@synthesize info;
@synthesize contacts;

- (void) _init
{
    info = [[ContactItem alloc] init];
    [info setJid:@""];
    contacts = [[NSMutableArray alloc] init];    
}

- (id) init
{
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (id) initWithName:(NSString*) name
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
    [contacts release];
}

- (void) updateContact:(ContactItem*) item
{
    NSEnumerator* e = [contacts objectEnumerator];
    ContactItem* index;
    while((index = [e nextObject])) {
        if ([[index jid]isEqualToString:[item jid]]) {
            if ([[item name]length]) {
                [index setName:[item name]];
            }
            if ([[item key]length]) {
                [index setKey:[item key]];
            }
            if ([[item photo]length]) {
                [index setPhoto:[item photo]];
            }
            if ([[item status]length]) {
                [index setStatus:[item status]];
            }
            [index setPresence:[item presence]];
            return;
        }
    }
    [contacts addObject:[item retain]];
}

- (void) removeContact:(ContactItem*) item
{
    NSEnumerator* e = [contacts objectEnumerator];
    ContactItem* index;
    while((index = [e nextObject])) {
        if ([[index jid]isEqualToString:[item jid]]) {
            [contacts removeObject:index];
            return;
        }
    }
    return;
}

@end

@implementation ContactGroupManager
@synthesize groups;
- (id) init
{
    self = [super init];
    if (self) {
        groups = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [groups release];
}

- (ContactGroup*)groupByName:(NSString*) name
{
    NSEnumerator* e = [groups objectEnumerator];
    ContactGroup* group;
    while ((group = [e nextObject])) {
        if ([[[group info] name] isEqualToString:name]) {
            return group;
        }
    }
    return nil;
}

- (void) updateContact:(ContactItem*) item
{
    ContactGroup* group = nil;
    NSEnumerator* e = [[item groups] objectEnumerator];
    NSString* groupName;
    while ((groupName = [e nextObject])) {
        group = [self groupByName:groupName];
        if (!group) {
            group = [[ContactGroup alloc] initWithName:groupName];
            [groups addObject:group];
        }
    }
    if (!group) {
        return;
    }
    [group updateContact:item];
}

@end
