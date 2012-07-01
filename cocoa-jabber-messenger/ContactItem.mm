//
//  ContactItem.mm
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/18/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "ContactItem.h"
#include "presence.h"

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

+ (NSString*) statusImage:(NSInteger) presence
{
    switch (presence) {
        case gloox::Presence::Available:
            return [NSImage imageNamed:@"status_online.png"];
            break;
            
            /*case gloox::Presence::Chat:
             return [NSString stringWithString:@"Chat"];
             break;*/
            
        case gloox::Presence::Away:
            return [NSImage imageNamed:@"status_hide.png"];
            break;
            
        case gloox::Presence::DND:
            return [NSImage imageNamed:@"status_busy.png"];
            break;
            
            /*case gloox::Presence::XA:
             return [NSString stringWithString:@"Away for an extended period of time"];
             break;*/
            
        case gloox::Presence::Unavailable:
            return [NSImage imageNamed:@"status_offline.png"];
            break;
            
            /*case gloox::Presence::Probe:
             return [NSString stringWithString:@"Probe"];
             break;
             
             case gloox::Presence::Error:
             return [NSString stringWithString:@"Error"];
             break;*/
            
        case PRESENCE_UNKNOWN:
            return [NSImage imageNamed:@"status_offline.png"];
            break;    
            
        default:
            return [NSImage imageNamed:@"status_offline.png"];
            break;
    }
    
}

@end
