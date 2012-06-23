//
//  XMPP.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/16/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMPPConnectionDelegate;
@protocol XMPPVcardUpdateDelegate;
@protocol SearchDelegate;
@class RequestWithTGT;
@class XMPPThread;
@class XMPPSession;
@class XMPPSessionManager;
@class XMPPMUCRoom;
@class XMPPMUCRoomManager;
@class ContactItem;
@interface XMPP : NSObject {
@private
    NSMutableDictionary* myVcard;
    NSMutableArray* connectionDelegates;
    NSMutableArray* vcardUpdateDelegates;
    NSMutableArray* stanzas;
    id <SearchDelegate> searchDelegate;
    XMPPThread* xmppThread;
    
    IBOutlet XMPPSessionManager* sessionManager;
    IBOutlet XMPPMUCRoomManager* mucRoomManager;
    RequestWithTGT* tgtRequest;
}

@property (assign) NSMutableDictionary* myVcard;
@property (assign) id <SearchDelegate> searchDelegate;

- (XMPPSessionManager*) sessionManager;
- (XMPPMUCRoomManager*) mucRoomManager;
- (RequestWithTGT*) tgtRequest;
- (BOOL)loginWithId:(NSString*)loginId withPassword:(NSString*)password;
- (void) onConnect:(NSString*) myJid;
- (void) requestVcard:(NSString*) jid;
- (void) updateSelfVcard:(ContactItem*) item;
- (void) disconnect;
- (void) registerVcardUpdateDelegate:(id <XMPPVcardUpdateDelegate>) vcardUpdateDelegate;
- (void) deregisterVcardUpdateDelegate:(id <XMPPVcardUpdateDelegate>) vcardUpdateDelegate;
- (void) registerConnectionDelegate:(id <XMPPConnectionDelegate>) connectionDelegate;
- (void) deregisterConnectionDelegate:(id <XMPPConnectionDelegate>) connectionDelegate;
- (BOOL) isFinished;
- (void) startChat:(NSString*) jid;
- (void) startRoomChat:(NSString*) jid;
- (void) searchContacts:(NSString*) cond;
- (void) close:(XMPPSession*) session;
@end
