//
//  ChatHistoryViewController.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-26.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XMPP;
@interface ChatHistoryViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
@private
    IBOutlet NSTableView* historyList;
    NSMutableArray* history;
    NSInteger currentPage;
    NSString* jid;
    NSImage* targetImage;
	NSImage* myImage;
}

@property (assign) XMPP* xmpp;
@property (assign) NSInteger currentPage;
@property (assign) NSString* jid;

- (void) showHistory:(NSInteger) page;
- (IBAction) back:(id) sender;
- (IBAction) forward:(id) sender;

@end
