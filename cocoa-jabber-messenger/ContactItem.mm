//
//  ContactItem.mm
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/18/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "ContactItem.h"


@implementation ContactItem
@synthesize key;
@synthesize name;
@synthesize pinyin;
@synthesize jid;
@synthesize fullJid;
@synthesize photo;
@synthesize groups;
@synthesize presence;
@synthesize status;
@synthesize online;
@synthesize vcard;
@synthesize image;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setName:@""];
        [self setJid:@""];
        [self setFullJid:@""];
        [self setStatus:@""];
        [self setKey:@""];
        [self setPinyin:@""];
        [self setPresence:PRESENCE_UNKNOWN];
        [self setOnline:YES];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
