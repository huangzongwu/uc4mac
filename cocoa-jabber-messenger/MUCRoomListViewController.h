//
//  MUCRoomListViewController.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-31.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MUCRoomItem;
@class MUCRoomGroupManager;
@class XMPP;
@class MUCRoomDataContext;
@class MUCRoomContactDataContext;
@interface MUCRoomListViewController : NSViewController <NSOutlineViewDataSource> {
@private
    MUCRoomGroupManager* groupManager;
    NSTextFieldCell*    iGroupRowCell;
    IBOutlet NSOutlineView* roomList;
    IBOutlet XMPP* xmpp;
}
@end