//
//  ChatWindowController.mm
//  Ta
//
//  Created by Sangeun Kim on 3/13/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "HistoryWindowController.h"
#import "ChatWindowController.h"
#import "ChatTextFieldCell.h"
#import "RowResizableTableView.h"
#import "XMPP.h"
#import "XMPPSession.h"
#import "MessageItem.h"
#import "ContactItem.h"
#import "AsyncImage.h"

@implementation ChatWindowController
@synthesize targetImage;
@synthesize myImage;
@synthesize targetJid;
@synthesize targetName;
@synthesize session;

- (void) readMessage:(NSNotification*) aNotification
{
	if (![[self window] isVisible]) {

	}
    else {
        [[self window] makeKeyAndOrderFront:self];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"readMessage" object:self];
}

- (BOOL) applicationShouldHandleReopen:(NSApplication *) theApplication
				   hasVisibleWindows:(BOOL) flag
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"readMessage" object:self];
	return YES;
}

- (void) windowWillClose:(NSNotification*) notification
{
    [session close];
}

- (void) windowDidClose:(NSNotification*) notification
{
}

- (BOOL) windowShouldClose:(id) sender
{
	return YES;
}

- (void) setTargetJid:(NSString*) _targetJid
{
    [targetJid release];
    targetJid = _targetJid;
    [targetJidField setStringValue:targetJid];
}

- (void) setTargetName:(NSString*) _targetName
{
    [targetName release];
    targetName = _targetName;
    [[self window] setTitle:targetName];
    [targetNameField setStringValue:targetName];
}

- (void) setTargetImage:(NSImage*) image
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
    imageArrary = [[NSMutableDictionary alloc] init];
    asyncImg = [[AsyncImage alloc] init];
    [asyncImg registerAsyncImageDelegate:self];
	[chatListCtrl setDataSource:self];
	[chatListCtrl setDelegate:self];
    [chatListCtrl setDoubleAction:@selector(onDoubleClick:)];
    [chatListCtrl setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
	[chatListCtrl setIntercellSpacing:NSMakeSize(0,0)]; 
    historyWindowController = [[HistoryWindowController alloc] initWithWindowNibName:@"HistoryWindow"];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [messageArray removeAllObjects];
	[messageArray release];    
    [imageArrary removeAllObjects];
    [imageArrary release];
    [asyncImg release];
    [targetImage release];
    [targetJid release];
    [targetName release];
    [historyWindowController release];
    [super dealloc];
}

- (BOOL) addMessageItem:(MessageItem*) item
{
    [messageArray addObject:item];
    [item save];
    [chatListCtrl reloadData];
    [chatListCtrl scrollRowToVisible:[messageArray count]];
    return YES;
}

- (void) onMessageReceived:(MessageItem*) msg;
{
    [self addMessageItem:msg];
}

- (void) registerSession:(XMPPSession*) theSession
{
    [self setSession:theSession];
    [historyWindowController setXmpp:[theSession xmpp]];
    [[theSession xmpp] registerVcardUpdateDelegate: self];
}

- (IBAction) send:(id) sender
{
    if (!session) {
        return;
    }
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
    
    MessageItem* item = [[MessageItem alloc]init];
    [item setType:@"to"];
    [item setJid:targetJid];
    [item setName:@"我"];
    [item setMessage:message];
    [item setTimeStamp:[NSDate date]];
    [session sendMessage:item];
    [self addMessageItem:item];
    [item release];    
    [message release];
	[msgToSend setStringValue:@""];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *) aTableView
{
	return [messageArray count];
}

- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(NSInteger) rowIndex
{
	MessageItem* item = [messageArray objectAtIndex:rowIndex];
	if ([[aTableColumn identifier] isEqualToString:@"ProfileImage"]) {
		if ([[item name] isEqualToString:@"我"]) {
			return nil;
		}
		else {
			return targetImage;
		}
	} else if ([[aTableColumn identifier] isEqualToString:@"MyImage"]) {
		if ([[item name] isEqualToString:@"我"]) {
			return myImage;
		}
		else {
			return nil;
		}
    }
	if ([[aTableColumn identifier] isEqualToString:@"TextMessage"]) {
		if ([[item name] isEqualToString:@"我"]) {
			[[aTableColumn dataCell] setLeftArrow:NO];
		} else {
			[[aTableColumn dataCell] setLeftArrow:YES];
		}
        if ([item timeStamp]) {
            [[aTableColumn dataCell] setMessageTime:[item timeStamp]];
        }
        if ([[item images] count] > 0) {
            int requested = 0;
            for (NSString* image in [item images]) {
                if (![imageArrary valueForKey:image]) {
                    [imageArrary setValue:@"loading" forKey:image];
                    [asyncImg loadImage:image];
                } else if ([[imageArrary valueForKey:image] isEqualToString:@"finish"]) {
                    ++requested;
                }
            }
            if (requested == [[item images] count]) {
                [[aTableColumn dataCell] setImages:[item images]];
            }
        }
		if (rowIndex == [aTableView selectedRow]) {
			[[aTableColumn dataCell] setSelected:YES];
		} else {
			[[aTableColumn dataCell] setSelected:NO];
		}
		return [item message];
	}
	return @"";
}

- (void) imageloaded:(NSString*) picName
{
    [imageArrary setValue:@"finish" forKey:picName];
    [chatListCtrl reloadData];
}

- (void) vcardUpdate:(ContactItem*) item;
{
    if ([[item jid] isEqualToString: [self targetJid]]) {
        NSImage* image = [[NSImage alloc] initWithData:[item photo]];
        [self setTargetImage: image];
        [self setTargetName: [item name]];
    }
}

- (IBAction) copy:(id) sender
{
    NSInteger index = [chatListCtrl selectedRow];
    if (index == -1) {
        return;
    }
    MessageItem* item = [messageArray objectAtIndex:index];
    NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setString: [item message] forType:NSStringPboardType];
}

- (IBAction) showHistory:(id) sender
{
    [[historyWindowController window] makeKeyAndOrderFront:nil];
    BOOL created = [HistoryWindowController getHistoryWindowCreated];
    if (!created) {
        [historyWindowController showHistory:targetJid];
        [HistoryWindowController setHistoryWindowCreated:YES];
    }
}

- (IBAction) onDoubleClick:(id) sender
{
//    NSText *textEditor;
    NSInteger index = [sender selectedRow];
    [sender editColumn:1 row:index withEvent:nil select:YES];
}

- (void) tableView:(NSTableView *) aTableView willDisplayCell:(id) aCell forTableColumn:(NSTableColumn *) aTableColumn row:(NSInteger) rowIndex
{
    if (![aCell isKindOfClass:[ChatTextFieldCell class]]) {
        return;
    }
}
@end
