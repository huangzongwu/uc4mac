//
//  MUCRoomItem.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomItem.h"

@implementation MUCRoomItem
@synthesize name;
@synthesize jid;
@synthesize image;
@synthesize intro;
@synthesize notice;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setName:@""];
        [self setJid:@""];
        [self setIntro:@""];
        [self setNotice:@""];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
