//
//  ContactViewController.mm
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/17/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "ContactViewController.h"
#import "BuddyCell.h"
#import "XMPP.h"
#import "ContactItem.h"
#import "ContactManager.h"
#include "gloox/presence.h"
#import "ContactDataContext.h"

#pragma mark *** ContactViewController ***

@implementation ContactViewController

#pragma mark *** Initialize ***

- (void) awakeFromNib
{
	iGroupRowCell = [[NSTextFieldCell alloc] init];
	[iGroupRowCell setEditable:NO];
	[iGroupRowCell setLineBreakMode:NSLineBreakByTruncatingTail];
    [xmpp setVcardUpdateDelegate:self];
    groupManager = [[ContactGroupManager alloc]init];
    [contactList setIntercellSpacing:NSMakeSize(0,0)];
    [contactList setTarget:self];
    [contactList setDoubleAction:@selector(onDoubleClick:)];
    [contactList setAction:@selector(onClick:)];
    [contactList setDataSource:self];
}

- (void)dealloc
{
    [groupManager release];
    [iGroupRowCell release];
    [super dealloc];
}

- (void) onClick:(id) sender
{
    NSInteger selected = [contactList selectedRow];
    NSTreeNode* node = [contactList itemAtRow:selected];
    if ([contactList isExpandable:node]) {
        if ([contactList isItemExpanded:node]) {
            [contactList collapseItem:node];
        }
        else {
            [contactList expandItem:node];
        }
    }    
}

- (void) onDoubleClick:(id) sender
{
    NSInteger selected = [contactList selectedRow];
    NSTreeNode* node = [contactList itemAtRow:selected];
    NSManagedObject* object = [node representedObject];
    if ([[[object entity] valueForKey:@"name"] isEqualToString:@"Contact"] == YES) {
        NSString* jid = [object valueForKey:@"jid"];
        if (!jid) {
            return;
        } else {
            NSLog(@"jid: %@", jid);
        }
        [xmpp startChat:jid];
    }
}

#pragma mark -
#pragma mark *** Roster Delegate ***

- (void) vcardUpdate:(ContactItem*) item;
{
    NSString* presentedGroupName = nil;
    NSString* groupName = nil;
    if ([item groups]) {
        if ([[item groups] count])
        {
            groupName = [[item groups] objectAtIndex:0];
            presentedGroupName = groupName;
        }
    }
    if (!presentedGroupName) {
        presentedGroupName = [contactDataContext groupNameByContact:item];
    }
    NSInteger count = [contactDataContext contactCountInGroup:presentedGroupName];
    if (!count) {
        [contactList expandItem:nil expandChildren:YES];
    }
    [contactDataContext updateContact:item intoGroup:presentedGroupName];
}

#pragma mark -
#pragma mark *** outlineView dataset ***

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
		return [[groupManager groups] objectAtIndex:index];
	}
    if ([item isKindOfClass:[ContactGroup class]]) {
        return [[item contacts] objectAtIndex:index];
    }    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[ContactGroup class]]) {
        return YES;
    }
	return NO;    
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil) {
		return [[groupManager groups] count];
	}
    if ([item isKindOfClass:[ContactGroup class]]) {
        return [[item contacts] count];
    }
	return 0;
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

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSManagedObject* obj = [item representedObject];
    BOOL group = [[[obj entity] name] isEqualToString:@"ContactGroup"];
    if (group) {
        NSString* name = [NSString stringWithFormat:@"\t%@", [obj valueForKey:@"name"]];
        return name;
    }
    if ([[tableColumn identifier] isEqualToString:@"image"]) {
        NSData* imageData = [obj valueForKey:@"image"];
        if (imageData) {
            NSImage* image = [[[NSImage alloc] initWithData:imageData] autorelease];
            return image;
        }
        return [NSImage imageNamed:@"NSUser"];
    }
    if ([[tableColumn identifier] isEqualToString:@"name"]) {
        [(BuddyCell*)[tableColumn dataCell] setTitle:[obj valueForKey:@"name"]];
        [(BuddyCell*)[tableColumn dataCell] setSubTitle:[obj valueForKey:@"jid"]];
        return [obj valueForKey:@"name"];
    }
    if ([[tableColumn identifier] isEqualToString:@"status"]) {
        return [self statusImage:[[obj valueForKey:@"presence"] integerValue]];
    }
    return nil;
}

- (NSCell *) outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if (tableColumn == nil) {
        NSManagedObject* obj = [item representedObject];
        return [[[obj entity] name] isEqualToString:@"ContactGroup"] ? iGroupRowCell : nil;
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    NSManagedObject* obj = [item representedObject];
    if ([[[obj entity] name] isEqualToString:@"ContactGroup"]) {
        return YES;
    }
    return NO;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    NSManagedObject* obj = [item representedObject];
    return [[[obj entity] name] isEqualToString:@"ContactGroup"] ? 20 : [contactList rowHeight];
}
#pragma mark -
@end
