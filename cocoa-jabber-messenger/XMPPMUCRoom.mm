//
//  XMPPMUC.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-29.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

/**
 * 聊天室实现，一度令我很郁闷，说说思路，就是参考私聊。
 * 开始没想明白将Session换成MUCRoom即可，推荐先看gloox对MUCRoom的文档
 * http://camaya.net/api/gloox-0.9-pre5/classgloox_1_1MUCRoom.html
 * 先从XMPPSession的sendMessage方法入手，它调用的是MessageSession中定义的send。
 * 那么群聊的sendMessage理应调用类似方法，这个方法正是MUCRoom中定义的send。
 * 对应关系就找到了，ROOM对应SESSION。下面的工作就是复制粘贴加替换，没啥难度了。
 */

#import "XMPP.h"
#import "RequestWithTGT.h"
#import "XMPPMUCRoom.h"
#import "SynthesizeSingleton.h"
#import "MUCRoomChatWindowController.h"
#import "MUCRoomMessageItem.h"
#import "MUCRoomDataContext.h"
#import "MUCRoomItem.h"
#import "MUCRoomContactItem.h"
#import "GrowlLinker.h"
#include "message.h"
#include "mucroomhandler.h"
#include "mucroom.h"
#include "mutex.h"
#include <string.h>

#pragma mark *** CMUCRoomEventHandler Implementation ***
class CMUCRoomEventHandler:public gloox::MUCRoomHandler
{
public:
    CMUCRoomEventHandler(XMPPMUCRoomManager* pRoomManager);
    virtual ~CMUCRoomEventHandler();
    
protected:
    virtual void 	handleMUCMessage (gloox::MUCRoom*, const gloox::Message&, bool priv);
    virtual void    handleMUCParticipantPresence(gloox::MUCRoom* room, const gloox::MUCRoomParticipant participant, const gloox::Presence& presence);
    virtual void    handleMUCSubject(gloox::MUCRoom* room, const std::string& nick, const std::string& subject);
    virtual void    handleMUCError(gloox::MUCRoom* room, gloox::StanzaError error);
    virtual void    handleMUCInfo(gloox::MUCRoom* room, int features, const std::string& name, const gloox::DataForm* infoForm);
    virtual void    handleMUCItems(gloox::MUCRoom* room, const gloox::Disco::ItemList& items );
    virtual void    handleMUCInviteDecline(gloox::MUCRoom* room, const gloox::JID& invitee, const std::string& reason);
    virtual bool    handleMUCRoomCreation(gloox::MUCRoom* room);
    virtual bool    handleMUCRoomDestruction(gloox::MUCRoom* room);
    
private:
    XMPPMUCRoomManager*     m_pRoomManager;
};

CMUCRoomEventHandler::CMUCRoomEventHandler(XMPPMUCRoomManager* pRoomManager)
:m_pRoomManager(pRoomManager)
{
    
}

CMUCRoomEventHandler::~CMUCRoomEventHandler()
{
    NSLog(@"destroy:CMUCRoomEventHandler");
}

void    CMUCRoomEventHandler::handleMUCMessage(gloox::MUCRoom* room, const gloox::Message& msg, bool priv)
{
    NSString* myJid = [[NSString alloc] initWithUTF8String:room->nick().c_str()];
    NSString* senderJid = [[NSString alloc] initWithUTF8String:msg.from().resource().c_str()];
    
    if([senderJid isEqualToString:myJid] == NO){
        NSString* roomJid = [NSString stringWithFormat:@"%@@group.uc.sina.com.cn/%@", [NSString stringWithUTF8String:room->name().c_str()], myJid];
        MUCRoomMessageItem * message = [[MUCRoomMessageItem alloc] init];
        [message setType:@"from"];
        [message setMessage:[NSString stringWithUTF8String:msg.body().c_str()]];
        [message setJid:senderJid];
        [message setRoomJid:roomJid];
        [message setTimeStamp:[NSDate date]];
        [m_pRoomManager performSelectorOnMainThread:@selector(activateRoom:) withObject:roomJid waitUntilDone:NO];
        [m_pRoomManager performSelectorOnMainThread:@selector(handleMUCMessage:) withObject:message waitUntilDone:NO];
        [roomJid release];
    }
    
    [myJid release];
    [senderJid release];
}

void    CMUCRoomEventHandler::handleMUCParticipantPresence(gloox::MUCRoom* room, const gloox::MUCRoomParticipant participant, const gloox::Presence& presence)
{
    NSString* myJid = [NSString stringWithUTF8String:room->nick().c_str()];
    NSString* roomJid = [NSString stringWithFormat:@"%@@group.uc.sina.com.cn/%@", [NSString stringWithUTF8String:room->name().c_str()], myJid];
    MUCRoomContactItem* contact = [[MUCRoomContactItem alloc] init];
    [contact setJid:[NSString stringWithUTF8String:participant.jid->username().c_str()]];
    [contact setRoomJid:roomJid];
    [contact setPresence:presence.subtype()];
    [m_pRoomManager performSelectorOnMainThread:@selector(updateContact:) withObject:contact waitUntilDone:NO];
}

void    CMUCRoomEventHandler::handleMUCSubject(gloox::MUCRoom* room, const std::string& nick, const std::string& subject)
{
}

void    CMUCRoomEventHandler::handleMUCError(gloox::MUCRoom* room, gloox::StanzaError error)
{
}

void    CMUCRoomEventHandler::handleMUCInfo(gloox::MUCRoom* room, int features, const std::string& name, const gloox::DataForm* infoForm)
{
    NSLog(@"muc info!");
}

void    CMUCRoomEventHandler::handleMUCItems(gloox::MUCRoom* room, const gloox::Disco::ItemList& items)
{
    NSLog(@"muc item!");
}

void    CMUCRoomEventHandler::handleMUCInviteDecline(gloox::MUCRoom* room, const gloox::JID& invitee, const std::string& reason)
{
    NSLog(@"muc invite decline!");
}

bool    CMUCRoomEventHandler::handleMUCRoomCreation(gloox::MUCRoom* room)
{
    return true;
}

bool    CMUCRoomEventHandler::handleMUCRoomDestruction(gloox::MUCRoom* room)
{
    return true;
}


@implementation XMPPMUCRoom
@synthesize room;
@synthesize chatWindowCreated;
@synthesize xmpp;
@synthesize jid;
@synthesize gid;
@synthesize name;

- (void) dealloc
{
    [name release];
    [jid release];    
    [dataObject release];
    [windowController close];
    [windowController release];
    [super dealloc];
}

- (void) close
{
    chatWindowCreated = NO;
}

- (void) createChatWindowWithDataObject:(NSManagedObject*) obj
{
    //create chat window
    dataObject = [obj retain];
    windowController = [[MUCChatWindowController alloc] initWithWindowNibName:@"MUCChatWindow"];
    NSData* imageData = [dataObject valueForKey:@"image"];
    if (imageData) {
        NSImage* image = [[NSImage alloc]initWithData:imageData];
        [windowController setTargetImage:image];
        [image release];
    } else {
        [windowController setTargetImage:[NSImage imageNamed:@"NSUserGroup"]];
    }
    name = [dataObject valueForKey:@"name"];
    jid = [dataObject valueForKey:@"jid"];
    if (![name length]) {
        name = jid;
    }
    [windowController setTargetName:name];
    [windowController setTargetJid:jid];
    [windowController setRoom:self];
    chatWindowCreated = YES;
}

- (void) activateWindow
{
    [[windowController window]makeKeyAndOrderFront:self];
}

- (void) handleMessage:(MUCRoomMessageItem*) msg
{
    [windowController onMessageReceived:msg];
	if (![NSApp isActive]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unreadMessage" object:msg];
	}
    [msg release];
}

- (BOOL) sendMessage:(MessageItem*) item
{
    std::string message = [[item message]UTF8String];
    if (room) {
        room->send(message);
        return YES;
    }
    return NO;
}

@end

#pragma mark -
#pragma mark *** XMPPMUCRoomManager ***
@implementation XMPPMUCRoomManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        rooms = [[NSMutableDictionary alloc]init];
        handler = new CMUCRoomEventHandler(self);
    }
    
    return self;
}

- (void)dealloc
{
    if (handler) {
        delete handler;
    }
    [rooms release];
    [super dealloc];
}

- (void) joinRoom:(XMPPMUCRoom*) room
{
    if ([rooms objectForKey:[room jid]] == nil) {
        [rooms setValue:room forKey:[room jid]];
        [room room]->registerMUCRoomHandler(handler);
        [room room]->join();
    }
}

- (void) removeRoom:(XMPPMUCRoom*) room
{
    [rooms removeObjectForKey:[room jid]];
}

- (BOOL) activateRoom:(NSString*) roomJid
{
    if ([rooms objectForKey:roomJid] != nil) {
        if ([[rooms objectForKey:roomJid] chatWindowCreated] == NO) {
            NSManagedObject* obj = [mucRoomDataContxt findRoomByJid:roomJid];
            if (!obj) {
                return NO;
            }
            //NSArray* contacts = [[NSArray alloc] initWithArray:[mucRoomDataContxt getContactsByRoomJid:roomJid]];               
            [[rooms objectForKey:roomJid] createChatWindowWithDataObject:obj];
        }
        return YES;
    }
    return NO;
}

- (void) updateRoom:(XMPPMUCRoom*) room
{
    MUCRoomItem* roomItem = [[MUCRoomItem alloc] init];
    [roomItem setJid:[room jid]];
    [roomItem setName:[room name]];
    /*[roomItem setIntro:[room intro]];
     [roomItem setNotice:[room notice]];*/
    [mucRoomDataContxt updateRoom:roomItem];
    [roomItem release];
}

- (void) updateContact:(MUCRoomContactItem*) contact
{
    [mucRoomDataContxt updateRoomContact:contact withRoomJid:[contact roomJid]];
}

- (void) updateRoomContacts:(NSMutableArray*) contacts withRoomJid:(NSString*) roomJid
{
    [mucRoomDataContxt updateRoomContacts:contacts withRoomJid:roomJid];
}

- (void) handleMUCMessage:(MUCRoomMessageItem*) msg
{
    [[rooms objectForKey:[msg roomJid]] handleMessage:msg];
}

@end
