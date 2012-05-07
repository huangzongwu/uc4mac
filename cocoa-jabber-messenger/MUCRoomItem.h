//
//  MUCRoomItem.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUCRoomItem : NSObject
{
@private
    NSString* name;
    NSString* jid;
    NSData* image;
    NSString* intro;
    NSString* notice;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* jid;
@property (nonatomic, retain) NSData* image;
@property (nonatomic, retain) NSString* intro;
@property (nonatomic, retain) NSString* notice;

@end