//
//  MUCContactItem.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-31.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomContactItem.h"

@implementation MUCRoomContactItem
@synthesize key;
@synthesize name;
@synthesize jid;
@synthesize photo;
@synthesize image;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setName:@""];
        [self setJid:@""];
        [self setKey:@""];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
