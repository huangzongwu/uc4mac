//
//  SearchViewController.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-5-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchDelegate.h"

@class XMPP;
@class ContactDataContext;
@interface SearchViewController : NSViewController <SearchDelegate, NSTableViewDataSource> {
@private
    NSMutableArray* contacts;
    IBOutlet NSTableView* contactList;
    IBOutlet ContactDataContext* contactDataContext;
    IBOutlet XMPP* xmpp;
}

- (void) search:(NSString*) cond;

@end