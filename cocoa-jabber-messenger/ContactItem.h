//
//  ContactItem.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/18/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DEFAULT_GROUP_NAME @"其他联系人"

#define PRESENCE_UNKNOWN -1
#define PRESENCE_OFFLINE 5

@interface ContactItem : NSObject {
@private
    NSString* key;
    NSString* name;
    NSString* jid;
    NSString* fullJid;
    NSData* photo;
    NSString* status;
    NSArray* groups;
    NSInteger presence;
    NSString* pinyin;
    BOOL    online;
    BOOL    vcard;
    
}
@property (nonatomic, retain) NSString* key;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* jid;
@property (nonatomic, retain) NSString* fullJid;
@property (nonatomic, retain) NSData* photo;
@property (nonatomic, retain) NSString* status;
@property (nonatomic, retain) NSArray* groups;
@property (nonatomic, retain) NSString* pinyin;
@property (assign) NSInteger presence;
@property (assign) BOOL online;
@property (assign) BOOL vcard;
@end
