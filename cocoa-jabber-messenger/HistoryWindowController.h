//
//  HistoryWindowController.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-26.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ChatHistoryViewController;
@class MessageItem;
@class XMPP;
@interface HistoryWindowController : NSWindowController
{
@private
    IBOutlet ChatHistoryViewController* historyViewController;
}

+ (void) setHistoryWindowCreated:(BOOL) created;
+ (BOOL) getHistoryWindowCreated;
- (void) showHistory:(NSString*) jid;
- (void) setXmpp:(XMPP*) xmpp;

@end
