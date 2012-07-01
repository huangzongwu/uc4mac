//
//  MUCRoomHistoryWindowController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-3-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomHistoryWindowController.h"
#import "MUCRoomChatHistoryViewController.h"
#import "MUCRoomMessageItem.h"

@implementation MUCRoomHistoryWindowController

static bool historyWindowCreated;

- (id) initWithWindow:(NSWindow*) window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) windowWillClose:(NSNotification*) notification
{
    historyWindowCreated = NO;
}

- (void) windowDidClose:(NSNotification*) notification
{
}

- (BOOL) windowShouldClose:(id) sender
{
	return YES;
}

- (void) showRoomHistory:(NSString*) jid
{
    [roomHistoryViewController setJid:jid];
    [roomHistoryViewController showRoomHistory:0];
}

+ (void) setHistoryWindowCreated:(BOOL) created
{
    historyWindowCreated = created;
}

+ (BOOL) getHistoryWindowCreated
{
    return historyWindowCreated;
}

@end