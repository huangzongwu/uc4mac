//
//  MUCRoomListViewController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomListViewController.h"
#import "BuddyCell.h"
#import "XMPP.h"
#import "MUCRoomItem.h"
#import "MUCRoomListManager.h"

@implementation MUCRoomListViewController

- (void) awakeFromNib
{
    iGroupRowCell = [[NSTextFieldCell alloc] init];
	[iGroupRowCell setEditable:NO];
	[iGroupRowCell setLineBreakMode:NSLineBreakByTruncatingTail];
    groupManager = [[MUCRoomGroupManager alloc]init];
    [roomList setIntercellSpacing:NSMakeSize(0,0)];
    [roomList setTarget:self];
    [roomList setDoubleAction:@selector(onDoubleClick:)];
    [roomList setAction:@selector(onClick:)];
    [roomList setDataSource:self];
}

- (void)dealloc
{
    [groupManager release];
    [iGroupRowCell release];
    [super dealloc];
}

- (void) onClick:(id) sender
{
    NSInteger selected = [roomList selectedRow];
    NSTreeNode* node = [roomList itemAtRow:selected];
    if ([roomList isExpandable:node]) {
        if ([roomList isItemExpanded:node]) {
            [roomList collapseItem:node];
        } else {
            [roomList expandItem:node];
        }
    }
}

- (void) onDoubleClick:(id) sender
{
    NSInteger selected = [roomList selectedRow];
    NSTreeNode* node = [roomList itemAtRow:selected];
    NSManagedObject* obj = [node representedObject];
    if ([[[obj entity] name] isEqualToString:@"Room"]) {
        if ([[[obj entity] valueForKey:@"name"] isEqualToString:@"Room"] == YES) {
            NSString* jid = [obj valueForKey:@"jid"];
            if (!jid) {
                return;
            }
            if (![jid length]) {
                return;
            }
            [xmpp startRoomChat:jid];
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item
{
    NSManagedObject* obj = [item representedObject];
    if ([[[obj entity] name] isEqualToString:@"Room"]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
    NSManagedObject* obj = [item representedObject];
    if ([[[obj entity] name] isEqualToString:@"RoomGroup"]) {
        return YES;
    } else {
        return NO; 
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
    NSManagedObject* obj = [item representedObject];
    if ([[[obj entity] name] isEqualToString:@"RoomGroup"]) {
        return YES;
    } else {
        return NO; 
    }
}

- (id)outlineView:(NSOutlineView*) outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id) item
{
    NSManagedObject* obj = [item representedObject];
    if ([[[obj entity] name] isEqualToString:@"RoomContact"] == YES) {
        return nil;
    }
    
    BOOL group = [[[obj entity] name] isEqualToString:@"RoomGroup"];
        
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
        return [NSImage imageNamed:@"NSUserGroup"];
    }
    
    if ([[tableColumn identifier] isEqualToString:@"name"]) {
        [(BuddyCell*)[tableColumn dataCell] setSubTitle:[obj valueForKey:@"intro"]];
        [(BuddyCell*)[tableColumn dataCell] setTitle:[obj valueForKey:@"name"]];
        return [obj valueForKey:@"name"];
    }
    return nil;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if (tableColumn == nil) {
        NSManagedObject* obj = [item representedObject];
        return [[[obj entity] name] isEqualToString:@"RoomGroup"] ? iGroupRowCell : nil;
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    NSManagedObject* obj = [item representedObject];
    return [[[obj entity] name] isEqualToString:@"RoomGroup"];
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    NSManagedObject* obj = [item representedObject];
    return [[[obj entity] name] isEqualToString:@"RoomGroup"] ? 20 : [roomList rowHeight];
}

@end
