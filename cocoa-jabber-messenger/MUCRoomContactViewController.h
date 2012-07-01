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
@interface MUCRoomContactViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
@private
    IBOutlet NSTableView* contactList;
    IBOutlet NSArrayController* arrayController;
}

@property (nonatomic, assign) XMPPMUCRoom* room;
@property (nonatomic, retain) NSMutableArray* contacts;

- (void) initContacts:(NSArray*) mucRoomContacts;
- (void) updateContact:(MUCRoomContactItem*) mucRoomContact; 
@end
