//
//  XMPPMUC.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-29.
//  聊天室实现，一度令我很郁闷，说说思路，就是参考私聊。
//  开始没想明白将Session换成MUCRoom即可，推荐先看gloox对MUCRoom的文档
//  http://camaya.net/api/gloox-0.9-pre5/classgloox_1_1MUCRoom.html
//  先从XMPPSession的sendMessage方法入手，它调用的是MessageSession中定义的send。
//  那么群聊的sendMessage理应调用类似方法，这个方法正是MUCRoom中定义的send。
//  对应关系就找到了，ROOM对应SESSION。下面的工作就是复制粘贴加替换，没啥难度了。

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

- (void) createChatWindowWithDataObject:(NSManagedObject*) obj;
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