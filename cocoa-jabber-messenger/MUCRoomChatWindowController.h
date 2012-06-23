//
//  MUCChatWindowController.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-29.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XMPP;
@class XMPPMUCRoom;
@class MUCRoomMessageItem;
@class MUCRoomContactViewController;
@class MUCRoomHistoryWindowController;
@class MUCRoomDataContext;
@interface MUCChatWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate> 
{
	IBOutlet NSTableView* chatListCtrl;
	IBOutlet NSTextFieldCell* msgToSend;
	IBOutlet NSImageView* profileImageView;
	IBOutlet NSTextField* commentCtrl;
    IBOutlet NSTextField* targetNameField;
    IBOutlet NSTextField* targetJidField;
    IBOutlet NSDrawer* roomContactsDrawer;
    IBOutlet MUCRoomContactViewController* mucRoomContactViewController;
    IBOutlet MUCRoomDataContext* mucRoomDataContext;
	NSMutableArray*	messageArray;
	NSImage* targetImage;
	NSImage* myImage;
    NSString* targetName;
    NSString* targetJid;
    XMPPMUCRoom* room;
    MUCRoomHistoryWindowController* historyWindowController;
}

@property (assign) XMPPMUCRoom* room;
@property (nonatomic, retain) NSImage* targetImage;
@property (nonatomic, retain) NSImage* myImage;
@property (nonatomic, retain) NSString* targetName;
@property (nonatomic, retain) NSString* targetJid;

- (void) updateContacts:(NSArray*) contacts;
- (void) onMessageReceived:(MUCRoomMessageItem*) msg;
- (IBAction) send:(id) sender;
- (IBAction) copy:(id) sender;
- (IBAction) toggleRoomContacts:(id) sender;
//-(IBAction)sendMyLocation:(id)sender;
//-(MessageItem*) findItemByMessageKey:(long long)key;

@end
