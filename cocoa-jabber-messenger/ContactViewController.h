//
//  ContactViewController.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/17/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMPPVcardUpdateDelegate.h"

@class ContactItem;
@class ContactGroupManager;
@class XMPP;
@class ContactDataContext;
@interface ContactViewController : NSViewController <NSOutlineViewDataSource, XMPPVcardUpdateDelegate> {
@private
    ContactGroupManager* groupManager;
    NSTextFieldCell*    iGroupRowCell;
    IBOutlet NSOutlineView* contactList;
    IBOutlet XMPP* xmpp;
    IBOutlet ContactDataContext* contactDataContext;
}

- (void) vcardUpdate:(ContactItem*) item;

@end
