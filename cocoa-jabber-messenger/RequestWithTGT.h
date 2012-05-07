//
//  RequestWithTGT.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-4.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestWithTGT : NSObject {
@private
    NSString* tgt;
    NSString* myJid;
}

@property (retain) NSString* tgt;
@property (retain) NSString* myJid;

- (NSMutableArray*) getRoomList :(NSString*) jid;
- (NSMutableArray*) getRoomContacts :(NSString*) gid;
- (void) exchangeTgt;
+ (NSString*) stringWithUUID;

@end
