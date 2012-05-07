//
//  XMPPVcardUpdateDelegate.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/17/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ContactItem;
@protocol XMPPVcardUpdateDelegate <NSObject>
- (void) vcardUpdate:(ContactItem*) item;
@end
