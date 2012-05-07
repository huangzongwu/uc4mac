//
//  MUCContactItem.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-31.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUCRoomContactItem : NSObject 
{
@private
    NSString* key;
    NSString* name;
    NSString* jid;
    NSData* photo;
    NSImage* image;
}

@property (nonatomic, retain) NSString* key;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* jid;
@property (nonatomic, retain) NSData* photo;
@property (nonatomic, retain) NSImage* image;

@end
