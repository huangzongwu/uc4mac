//
//  MUCChatWindowController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-29.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomHistoryWindowController.h"
#import "MUCRoomChatWindowController.h"
#import "MUCRoomContactViewController.h"
#import "MUCRoomChatTextFieldCell.h"
#import "RowResizableTableView.h"
#import "XMPP.h"
#import "XMPPMUCRoom.h"
#import "MUCRoomMessageItem.h"
#import "MUCRoomDataContext.h"

@implementation MUCChatWindowController
@synthesize targetImage;
@synthesize myImage;
@synthesize targetJid;
@synthesize targetName;
@synthesize xmpp;
@synthesize room;

- (void)readMessage:(NSNotification *)aNotification
{
	if (![[self window] isVisible]) {
        
	}
    else {
        [[self window] makeKeyAndOrderFront:self];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"readMessage" object:self];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
				   hasVisibleWindows:(BOOL)flag
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"readMessage" object:self];
	return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [room close];
}

- (void)windowDidClose:(NSNotification *)notification
{
}

- (BOOL)windowShouldClose:(id)sender
{
	return YES;
}

- (void) updateContacts:(NSArray*) contacts
{
    [mucRoomContactViewController setXmpp:xmpp];
    [mucRoomContactViewController updateContacts:contacts];
}

- (void) setTargetJid:(NSString *)_targetJid
{
    [targetJid release];
    targetJid = _targetJid;
    [targetJidField setStringValue:targetJid];
}

- (void) setTargetName:(NSString *)_targetName
{
    [targetName release];
    targetName = _targetName;
    [[self window]setTitle:[NSString stringWithFormat:@"群 - %@", targetName]];
    [targetNameField setStringValue:targetName];
}

- (void) setTargetImage:(NSImage *)image
{
    if (targetImage == image) {
        return;
    }
    [profileImageView setImage:image];
    [targetImage release];
    targetImage = [image retain];
}

- (void) awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readMessage:)
                                                 name:NSApplicationDidBecomeActiveNotification object:nil];
    messageArray = [[NSMutableArray alloc] init];
	[chatListCtrl setDataSource:self];
	[chatListCtrl setDelegate:self];
    [chatListCtrl setDoubleAction:@selector(onDoubleClick:)];
    [chatListCtrl setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
	[chatListCtrl setIntercellSpacing:NSMakeSize(0, 0)]; 
    historyWindowController = [[MUCRoomHistoryWindowController alloc] initWithWindowNibName:@"MUCRoomHistoryWindow"];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [mucRoomContactViewController dealloc];
    [messageArray removeAllObjects];
	[messageArray release];
    [targetJid release];
    [targetName release];
    [targetImage release];
    [historyWindowController release];
    [super dealloc];
}

- (BOOL) addMessageItem:(MUCRoomMessageItem*) item
{
    [messageArray addObject:item];
    [item save];
    [chatListCtrl reloadData];
    [chatListCtrl scrollRowToVisible:[messageArray count]];
    return YES;
}

- (void) onMessageReceived:(MUCRoomMessageItem*) msg;
{
    NSManagedObject* contact = [mucRoomDataContext findContactByJid:[msg jid] withRoomJid:[msg roomJid]];
    if (contact) {
        [msg setName: [contact valueForKey:@"name"]];
    } else {
        [msg setName: [msg jid]];
    }
    [self addMessageItem:msg];
}

-(IBAction)toggleRoomContacts:(id)sender
{
    if ([roomContactsDrawer state] == NSDrawerOpenState || [roomContactsDrawer state] == NSDrawerOpeningState) {
        [roomContactsDrawer close];
        [sender setTag:0];
    } else {
        [roomContactsDrawer openOnEdge: NSMaxXEdge];
        [sender setTag:1];
    }
}

-(IBAction)send:(id)sender
{
	if (!msgToSend) {
		return;
	}
    
	if (![[msgToSend stringValue]length]) {
		return;
	}
	
    NSMapTable *emojiMap = [NSMapTable mapTableWithStrongToStrongObjects];
    
    [emojiMap setObject:@"E056" forKey:@":)"];
    [emojiMap setObject:@"E057" forKey:@":D"];
    [emojiMap setObject:@"E058" forKey:@":("];
    [emojiMap setObject:@"E059" forKey:@":<"];
    [emojiMap setObject:@"E40B" forKey:@":o"];
    [emojiMap setObject:@"E40D" forKey:@":|"];
    [emojiMap setObject:@"E40E" forKey:@";<"];
    
    NSMutableString* message = [[NSMutableString alloc] initWithString:[msgToSend stringValue]];
    NSEnumerator* e = [emojiMap keyEnumerator];
    NSString* strEmoticon;
    while (nil != (strEmoticon = [e nextObject])) {
        NSRange range = [message rangeOfString:strEmoticon];
        if (range.location == NSNotFound) {
            continue;
        }
        NSScanner* emoScanner = [NSScanner scannerWithString:[emojiMap objectForKey:strEmoticon]];
        unsigned int intEmo;
        [emoScanner scanHexInt:&intEmo];
        unichar chEmo = intEmo;
        NSString* emoCode = [NSString stringWithCharacters:&chEmo length:1];
        do {
            [message replaceCharactersInRange:range withString:emoCode];
            range = [message rangeOfString:strEmoticon];
        }
        while ( range.location != NSNotFound );
    }
    
    MUCRoomMessageItem* item = [[MUCRoomMessageItem alloc] init];
    [item setRoomJid:targetJid];
    [item setType:@"to"];
    [item setJid:[[xmpp myVcard] valueForKey:@"jid"]];
    [item setName:@"我"];
    [item setMessage:message];
    [item setTimeStamp:[NSDate date]];
    [room sendMessage:item];
    [self addMessageItem:item];
    [item release];
    [message release];
	[msgToSend setStringValue:@""];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [messageArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	MUCRoomMessageItem* item = [messageArray objectAtIndex:rowIndex];
	if ([[aTableColumn identifier]isEqualToString:@"ProfileImage"]) {
		if ([[item jid]isEqualToString:targetJid]) {
			return targetImage;
		}
		else {
			return nil;
		}
	}
    else if ([[aTableColumn identifier]isEqualToString:@"MyImage"]) {
		if ([[item jid]isEqualToString:@""]) {
			return myImage;
		}
		else {
			return nil;
		}
    }
	if ([[aTableColumn identifier]isEqualToString:@"TextMessage"]) {
        [[aTableColumn dataCell] setLeftArrow:![[item name] isEqualToString:@"我"]];
        [[aTableColumn dataCell] setSender:[item name]];
        if ([item timeStamp]) {
            [[aTableColumn dataCell] setMessageTime:[item timeStamp]];
        }
		if (rowIndex == [aTableView selectedRow]) {
			[[aTableColumn dataCell] setSelected:YES];
		}
		else {
			[[aTableColumn dataCell] setSelected:NO];
		}
        
		return [item message];
	}
	return @"";
}

- (IBAction)copy:(id)sender
{
    NSInteger index = [chatListCtrl selectedRow];
    if (index == -1) {
        return;
    }
    MUCRoomMessageItem* item = [messageArray objectAtIndex:index];
    NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setString: [item message] forType:NSStringPboardType];
}

- (IBAction) showHistory:(id) sender
{
    [[historyWindowController window] makeKeyAndOrderFront:nil];
    BOOL created = [MUCRoomHistoryWindowController getHistoryWindowCreated];
    if (!created) {
        [historyWindowController showRoomHistory:targetJid];
        [MUCRoomHistoryWindowController setHistoryWindowCreated:YES];
    }
}

- (IBAction) onDoubleClick:(id)sender
{
    //    NSText *textEditor;
    NSInteger index = [sender selectedRow];
    
    [sender editColumn:1 row:index withEvent:nil select:YES];
    
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if (![aCell isKindOfClass:[MUCRoomChatTextFieldCell class]])
    {
        return;
    }
}
@end
