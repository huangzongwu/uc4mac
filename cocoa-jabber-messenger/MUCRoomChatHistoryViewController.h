//
//  MUCRoomChatHistoryViewController.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-3-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MUCRoomChatHistoryViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
@private
    IBOutlet NSTableView* historyList;
    NSInteger currentPage;
    NSString* jid;
}

@property (retain) NSMutableArray* history;
@property (assign) NSInteger currentPage;
@property (assign) NSString* jid;

- (void) showRoomHistory:(NSInteger) page;
- (IBAction) roomBack:(id) sender;
- (IBAction) roomForward:(id) sender;

@end
