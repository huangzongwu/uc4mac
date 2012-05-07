//
//  MessageItem.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/22/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLitePersistentObject.h"

@interface MessageItem : SQLitePersistentObject {
@protected
    NSString* type;
    NSString* jid;
    NSString* name;
    NSMutableArray* images;
    NSString* message;
    NSDate* timeStamp;
}
@property (nonatomic, retain)   NSString* type;
@property (nonatomic, retain)   NSString* jid;
@property (nonatomic, retain)   NSString* name;
@property (nonatomic, retain)   NSMutableArray* images;
@property (nonatomic, retain)   NSString* message;
@property (nonatomic, retain)   NSDate* timeStamp;
@end
