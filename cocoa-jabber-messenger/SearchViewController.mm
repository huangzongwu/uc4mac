//
//  SearchViewController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-5-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "SearchViewController.h"
#import "BuddyCell.h"
#include "gloox/presence.h"
#import "XMPP.h"
#import "ContactItem.h"
#import "ContactDataContext.h"

@implementation SearchViewController

- (void) awakeFromNib
{
    contacts = [[NSMutableArray alloc] init];
    [xmpp setSearchDelegate:self];
    [contactList setIntercellSpacing:NSMakeSize(0,0)];
    [contactList setTarget:self];
    [contactList setDoubleAction:@selector(onDoubleClick:)];
    [contactList setDataSource:self];
}

- (void) dealloc
{
    [contacts release];
}

- (void) search:(NSString*) cond
{
    [contacts removeAllObjects];
    [contacts addObjectsFromArray:[contactDataContext findContactsByPinyin:cond]];
    [contactList reloadData];
}

- (void) onDoubleClick:(id) sender
{
    [xmpp startChat:[[contacts objectAtIndex:[contactList selectedRow]] jid]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView*) aTableView
{
    return [contacts count];
}

- (NSString*) statusImage:(NSInteger) presence
{
    switch (presence) {
        case gloox::Presence::Available:
            return [NSImage imageNamed:@"status_online.png"];
            break;
            
            /*case gloox::Presence::Chat:
             return [NSString stringWithString:@"Chat"];
             break;*/
            
        case gloox::Presence::Away:
            return [NSImage imageNamed:@"status_hide.png"];
            break;
            
        case gloox::Presence::DND:
            return [NSImage imageNamed:@"status_busy.png"];
            break;
            
            /*case gloox::Presence::XA:
             return [NSString stringWithString:@"Away for an extended period of time"];
             break;*/
            
        case gloox::Presence::Unavailable:
            return [NSImage imageNamed:@"status_offline.png"];
            break;
            
            /*case gloox::Presence::Probe:
             return [NSString stringWithString:@"Probe"];
             break;
             
             case gloox::Presence::Error:
             return [NSString stringWithString:@"Error"];
             break;*/
        case PRESENCE_UNKNOWN:
            return [NSImage imageNamed:@"status_offline.png"];
            break;    
        default:
            return [NSImage imageNamed:@"status_offline.png"];
            break;
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[tableColumn identifier] isEqualToString:@"image"]) {
        NSData* imageData = [[contacts objectAtIndex:row] valueForKey:@"image"];
        if (imageData) {
            NSImage* image = [[[NSImage alloc] initWithData:imageData] autorelease];
            return image;
        }
        return [NSImage imageNamed:@"NSUser"];
    }
    if ([[tableColumn identifier] isEqualToString:@"name"]) {
        [(BuddyCell*)[tableColumn dataCell] setTitle:[[contacts objectAtIndex:row] valueForKey:@"name"]];
        [(BuddyCell*)[tableColumn dataCell] setSubTitle:[[contacts objectAtIndex:row] valueForKey:@"jid"]];
        return [[contacts objectAtIndex:row] valueForKey:@"name"];
    }
    if ([[tableColumn identifier] isEqualToString:@"status"]) {
        return [self statusImage:[[[contacts objectAtIndex:row] valueForKey:@"presence"] integerValue]];
    }
    return nil;
}

@end
