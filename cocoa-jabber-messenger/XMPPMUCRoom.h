//
//  XMPPMUC.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-29.
//  

#import <Foundation/Foundation.h>

namespace gloox {
    class MUCRoom;
}

class CMUCRoomEventHandler;

@class GrowlLinker;
@class MUCRoomContactViewController;
@class MUCChatWindowController;
@class MessageItem;
@class MUCRoomMessageItem;
@class XMPP;
@interface XMPPMUCRoom : NSObject {
@private
    gloox::MUCRoom* room;
    MUCChatWindowController* windowController;
    NSManagedObject* dataObject;
    BOOL chatWindowCreated;
    NSString* gid;
    NSString* jid;
    NSString* name;
    XMPP* xmpp;
}

@property (assign) gloox::MUCRoom* room;
@property (assign) BOOL chatWindowCreated;
@property (assign) XMPP* xmpp;
@property (assign) NSString* jid;
@property (assign) NSString* gid;
@property (assign) NSString* name;

- (void) createChatWindowWithDataObject:(NSManagedObject*) obj withContacts:(NSArray*) contacts;
- (BOOL) sendMessage:(MessageItem*) item;
- (void) handleMessage:(MUCRoomMessageItem*) msg;
- (void) close;
- (void) activateWindow;
@end

@class MUCRoomItem;
@class MUCRoomDataContext;
@class MUCRoomContactDataContext;
@interface XMPPMUCRoomManager : NSObject {
@private
    NSMutableDictionary* rooms;
    CMUCRoomEventHandler* handler;
    IBOutlet MUCRoomDataContext* mucRoomDataContxt;
}

- (void) joinRoom:(XMPPMUCRoom*) room;
- (void) removeRoom:(XMPPMUCRoom*) room;
- (BOOL) activateRoom:(NSString*) roomJid;
- (void) updateRoom:(XMPPMUCRoom*) room;
- (void) updateRoomContacts:(NSMutableArray*) contacts withRoomJid:(NSString*) roomJid;
- (void) handleMUCMessage:(MUCRoomMessageItem*) msg;

@end