//
//  XMPPSession.mm
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/20/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "XMPP.h"
#import "XMPPSession.h"
#import "SynthesizeSingleton.h"
#import "ChatWindowController.h"
#import "ContactDataContext.h"
#import "MessageItem.h"
#import "GrowlLinker.h"

#include "message.h"
#include "messagesession.h"
#include "messagehandler.h"
#include "messageeventhandler.h"
#include "chatstatehandler.h"
#include "mutex.h"

#include "chatstatefilter.h"
#include "messageeventfilter.h"

@interface XMPPSession(SessionHandler)
- (void) handleMessage:(MessageItem*) item;
@end

#pragma mark *** CMessageSessionEventHandler Implementation ***
class CMessageSessionEventHandler:public gloox::MessageHandler, public gloox::MessageEventHandler, public gloox::ChatStateHandler
{
public:
    CMessageSessionEventHandler(XMPPSession* m_pSession);
    virtual ~CMessageSessionEventHandler();
    
protected:
    virtual void 	handleMessage (const gloox::Message &msg, gloox::MessageSession *session=0);
    virtual void 	handleMessageEvent (const gloox::JID &from,gloox::MessageEventType event);
    virtual void 	handleChatState (const gloox::JID &from, gloox::ChatStateType state);
    
private:
    XMPPSession* m_pSession;
    
};

CMessageSessionEventHandler::CMessageSessionEventHandler(XMPPSession* pSession)
:m_pSession(pSession)
{
    
}

CMessageSessionEventHandler::~CMessageSessionEventHandler()
{
    NSLog(@"destroy:CMessageSessionEventHandler");
}

void 	CMessageSessionEventHandler::handleMessage (const gloox::Message &msg, 
                                        gloox::MessageSession *session)
{
    MessageItem* message = [[MessageItem alloc] init];
    NSString* messageString = [NSString stringWithUTF8String:msg.body().c_str()];
    [message setMessage:messageString];
    if (!msg.when()) {
        [message setTimeStamp:[NSDate date]];
    } else {
        NSArray* stamp = [[NSString stringWithUTF8String:msg.when()->stamp().c_str()] componentsSeparatedByString:@"T"];
        NSDate *sendTime = [[NSDate alloc] initWithString:[NSString stringWithFormat:@"%@-%@-%@ %@ -0800", 
                                                       [[stamp objectAtIndex:0] substringWithRange:NSMakeRange(0, 4)], 
                                                       [[stamp objectAtIndex:0] substringWithRange:NSMakeRange(4, 2)], 
                                                       [[stamp objectAtIndex:0] substringWithRange:NSMakeRange(6, 2)], 
                                                       [stamp objectAtIndex:1]]];
        [message setTimeStamp:sendTime];
    }
    [m_pSession performSelectorOnMainThread:@selector(handleMessage:) withObject:message waitUntilDone:NO];
                         
}

void 	CMessageSessionEventHandler::handleMessageEvent (const gloox::JID &from, gloox::MessageEventType event)
{
}

void 	CMessageSessionEventHandler::handleChatState (const gloox::JID &from, gloox::ChatStateType state)
{
    
}
#pragma mark -
#pragma mark *** XMPPSession Implementation ***
@implementation XMPPSession
@synthesize session;
@synthesize incomingSession;
@synthesize xmpp;
@synthesize jid;
@synthesize name;

- (void) dealloc
{
    if (handler) {
        delete handler;
    }
    [dataObject release];
    [windowController close];
    [windowController release];
    [super dealloc];
}

- (void) setSession:(gloox::MessageSession *)theSession
{
    @synchronized(self) {
        session = theSession;
    }
}

- (void) close
{
    
//    delete handler;
//    [windowController close];
    [xmpp close:self];
/*    if (chatStateFilter) {
        chatStateFilter->removeChatStateHandler();
        delete chatStateFilter;
    }
    
    if (messageEventFilter) {
        messageEventFilter->removeMessageEventHandler();
        delete messageEventFilter;
    }
*/    
//    if (session) {
//        session->removeMessageHandler();
//    }
//    session = nil;
}

- (void) createChatWindowWithDataObject:(NSManagedObject*) obj
{
    dataObject = [obj retain];
    windowController = [[ChatWindowController alloc] initWithWindowNibName:@"ChatWindow"];
    [[windowController window] makeKeyAndOrderFront:nil];
    NSImage* image = [[NSImage alloc] initWithData:[[xmpp myVcard] valueForKey:@"image"]];
    [windowController setMyImage: image];
    [image release];
    NSData* imageData = [dataObject valueForKey:@"image"];
    if (imageData) {
        NSImage* image = [[NSImage alloc] initWithData:imageData];
        [windowController setTargetImage:image];
        [image release];
    } else {
        [windowController setTargetImage:[NSImage imageNamed:@"NSUser"]];   
    }
    jid = [dataObject valueForKey:@"jid"];
    if (!jid) {
        return;
    }
    name = [dataObject valueForKey:@"name"];
    if (!name) {
        //requestVcard
        name = jid;
    }
    [name retain];
    [jid retain];
    [windowController setTargetName:name];
    [windowController setTargetJid:jid];
    [windowController registerSession:self];
    handler = new CMessageSessionEventHandler(self);
    session->registerMessageHandler(handler);
    chatStateFilter = new gloox::ChatStateFilter(session);
    chatStateFilter->registerChatStateHandler(handler);
    messageEventFilter = new gloox::MessageEventFilter(session);
    messageEventFilter->registerMessageEventHandler(handler);
}

- (void) activateWindow
{
    [[windowController window] makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma *** SessionHandler ***
- (void) handleMessage:(MessageItem*) item
{
    [item setType:@"from"];
    [item setJid:jid];
    [item setName:name];
    [windowController onMessageReceived:item];
	if (![NSApp isActive]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"unreadMessage" object:item];
	}
    [item release];
}
#pragma mark -
#pragma *** sendMessage ***

- (BOOL) sendMessage:(MessageItem*) item
{
    std::string message = [[item message] UTF8String];
    if (session) {
        session->send(message);
        return YES;
    }
    
    return NO;
    
}

@end

@implementation XMPPSessionManager

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        sessions = [[NSMutableArray alloc]init];
    }
    
    return self;
}

- (void) dealloc
{
    [sessions release];
    [super dealloc];
}

- (void) addSession:(XMPPSession*) session
{
    if ([sessions indexOfObject:session] == NSNotFound) {
        NSString* jid = [[NSString alloc] initWithUTF8String:[session session]->target().bare().c_str()];
        NSManagedObject* obj = [contactDataContxt findContactByJid:jid];
        if (!obj) {
            [[session xmpp] requestVcard:jid];
            obj = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext: contactDataContxt];
            [obj setValue:jid forKey:@"jid"];
        }
        [jid release];
        [session createChatWindowWithDataObject:obj];
        [sessions addObject:session];
        [session release];
    }
}

- (void) removeSession:(XMPPSession*) session
{
    [sessions removeObject:session];
}

- (BOOL) activateSession:(NSString*) jid
{
    NSEnumerator* e = [sessions objectEnumerator];
    XMPPSession* session;
    while ((session = [e nextObject])) {
        if ([[session jid] isEqualToString:jid]) {
            [session activateWindow];
            return YES;
        }
    }
    return NO;    
}

@end
