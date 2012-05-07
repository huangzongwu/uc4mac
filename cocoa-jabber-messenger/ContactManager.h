//
//  ContactManager.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/18/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ContactItem;

@interface ContactGroup :NSObject
{
@private
    const NSMutableArray* contacts;
    const ContactItem* info;
}

@property (assign) ContactItem* info;
@property (assign) NSMutableArray* contacts;

- (void) updateContact:(ContactItem*) item;
- (void) removeContact:(ContactItem*) item;

@end

@interface ContactGroupManager : NSObject {
@private
    NSMutableArray* groups;
}

@property (assign) NSMutableArray* groups;

- (ContactGroup*)groupByName:(NSString*)name;
- (void) updateContact:(ContactItem*) item;

@end