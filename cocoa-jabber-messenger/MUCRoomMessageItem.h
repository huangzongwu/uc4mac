//
//  MUCRoomMessageItem.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-4.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageItem.h"

@interface MUCRoomMessageItem : MessageItem{
@private
    NSString* roomJid;
}
@property (nonatomic, retain)    NSString* roomJid;
@end
