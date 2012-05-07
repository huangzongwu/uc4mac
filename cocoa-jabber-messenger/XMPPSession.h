//
//  XMPPSession.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/20/11.
//  Checked by Chen shuoshi on 1/30/11
//  实现一对一对话

#import <Foundation/Foundation.h>

namespace gloox {
    class MessageSession;
    class MessageEventFilter;
    class ChatStateFilter;
}

class CMessageSessionEventHandler;

@class GrowlLinker;
@class ChatWindowController;
@class ContactDataContext;
@class MessageItem;
@class XMPP;
@interface XMPPSession : NSObject {
@private
    gloox::MessageSession* session;
    gloox::ChatStateFilter* chatStateFilter;
    gloox::MessageEventFilter* messageEventFilter;
    CMessageSessionEventHandler* handler;
    ChatWindowController* windowController;
    NSManagedObject* dataObject;
    BOOL incomingSession;
    NSString* name;
    NSString* jid;
    XMPP* xmpp;
}
@property (nonatomic, assign) gloox::MessageSession* session;
@property (assign) BOOL incomingSession;
@property (assign) XMPP* xmpp;
@property (readonly) NSString* jid;
@property (readonly) NSString* name;

- (void) createChatWindowWithDataObject:(NSManagedObject*) obj;
- (BOOL) sendMessage:(MessageItem*) item;
- (void) close;
- (void) activateWindow;
@end

@interface XMPPSessionManager : NSObject {
@private
    NSMutableArray* sessions;
    IBOutlet ContactDataContext* contactDataContxt;
}
- (void) addSession:(XMPPSession*) session;
- (void) removeSession:(XMPPSession*) session;
- (BOOL) activateSession:(NSString*)jid;
@end
