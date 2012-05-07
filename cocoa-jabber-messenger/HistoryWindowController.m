//
//  HistoryWindowController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-26.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "HistoryWindowController.h"
#import "ChatHistoryViewController.h"
#import "MessageItem.h"

@implementation HistoryWindowController

static bool historyWindowCreated;

- (id) initWithWindow:(NSWindow *) window
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
    NSLog(@"close");
    historyWindowCreated = NO;
}

- (void) windowDidClose:(NSNotification*) notification
{
}

- (BOOL) windowShouldClose:(id) sender
{
	return YES;
}

- (void) showHistory:(NSString*) jid
{
    [historyViewController setJid:jid];
    [historyViewController showHistory:0];
}

- (void) setXmpp:(XMPP *)xmpp
{
    [historyViewController setXmpp:xmpp];
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
