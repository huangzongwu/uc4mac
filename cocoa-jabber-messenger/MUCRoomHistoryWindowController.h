//
//  MUCRoomHistoryWindowController.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-3-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MUCRoomChatHistoryViewController;
@class MUCRoomMessageItem;
@interface MUCRoomHistoryWindowController : NSWindowController
{
@private
    IBOutlet MUCRoomChatHistoryViewController* roomHistoryViewController;
}

+ (void) setHistoryWindowCreated:(BOOL) created;
+ (BOOL) getHistoryWindowCreated;
- (void) showRoomHistory:(NSString*) jid;

@end


