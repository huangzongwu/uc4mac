//
//  MUCRoomContactViewController.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-6.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MUCRoomContactItem.h"

@class XMPP;
@class MUCRoomContactDataContext;
@interface MUCRoomContactViewController : NSViewController {
@private
    XMPP* xmpp;
    IBOutlet NSTableView* contactList;
    IBOutlet NSArrayController* arrayController;
}

@property (assign) XMPP* xmpp;
@property (assign) NSMutableArray* contacts;

- (void) updateContacts:(NSArray*) mucRoomContacts;
@end
