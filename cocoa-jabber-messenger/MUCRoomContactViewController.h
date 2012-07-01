//
//  MUCRoomContactViewController.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-6.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XMPPMUCRoom;
@class MUCRoomContactDataContext;
@class MUCRoomContactItem;
@class MUCRoomDataContext;
@interface MUCRoomContactViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
@private
    IBOutlet NSTableView* contactList;
    IBOutlet NSArrayController* arrayController;
    IBOutlet MUCRoomDataContext* mucRoomDataContext;
}

@property (nonatomic, assign) XMPPMUCRoom* room;
@property (nonatomic, retain) NSMutableArray* contacts;

@end
