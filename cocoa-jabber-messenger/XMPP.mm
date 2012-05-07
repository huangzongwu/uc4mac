/**
 * @desc 
 * 程序运行过程中一直存在。其中CXmpp的C代表C++，是负责监听各种gloox消息的类。实现了众多主要接口。
 * XMPP是负责和XMPPSession、XMPPMUCRoom进行交互的类，主要作用是把CXmpp接收到的消息转发给session和room
 * 的manager，再通过各自manager转给各个session和room的实例。session、room和各自manager的实现请看
 * XMPPSession.mm和XMPPMUCRoom.mm
 */

#import "XMPP.h"
#import "SynthesizeSingleton.h"
#import "XMPPConnectionDelegate.h"
#import "XMPPVcardUpdateDelegate.h"
#import "SearchDelegate.h"
#import "ContactItem.h"
#import "MUCRoomItem.h"
#import "XMPPSession.h"
#import "XMPPMUCRoom.h"
#import "RequestWithTGT.h"
#import "ChineseToPinyin.h"
#import <CommonCrypto/CommonDigest.h>

#include <sys/time.h>
#include <gloox/gloox.h>
#include <gloox/client.h>
#include <gloox/eventhandler.h>
#include <gloox/rostermanager.h>
#include <gloox/messagehandler.h>
#include <gloox/presencehandler.h>
#include <gloox/vcardhandler.h>
#include <gloox/connectionlistener.h>
#include <gloox/rosterlistener.h>
#include <gloox/error.h>
#include <gloox/vcardmanager.h>
#include <gloox/mutex.h>
#include <gloox/pubsubmanager.h>
#include <gloox/messagesessionhandler.h>
#include <gloox/messagesession.h>
#include <gloox/message.h>
#include <gloox/mucroom.h>
#include <gloox/mucroomhandler.h>

// md5函数
NSString * md5( NSString *str )
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    return [NSString 
            stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1],
            result[2], result[3],
            result[4], result[5],
            result[6], result[7],
            result[8], result[9],
            result[10], result[11],
            result[12], result[13],
            result[14], result[15]
            ];
}

@interface HandlerWrapper : NSObject {
@private
    gloox::Presence* presence;
    gloox::Message* message;
    gloox::MessageSession* session;
}
@property (assign) gloox::Presence* presence;
@property (assign) gloox::Message* message;
@property (assign) gloox::MessageSession* session;
@end

@implementation HandlerWrapper
@synthesize presence;
@synthesize message;
@synthesize session;
@end

@interface XMPP (glooxHandler)
- (void) updateContact:( ContactItem* ) item;
- (void) updateContacts:( NSMutableArray* ) contacts;
- (void) onConnect: (id) sender;
- (void) onDisconnect: (NSString*) errorString;
@end

//CXmpp实现
class CXmpp:public gloox::PresenceHandler, gloox::ConnectionListener, gloox::VCardHandler, gloox::MessageSessionHandler, gloox::RosterListener, gloox::EventHandler, gloox::LogHandler
{
public:
    //仅有一个实例
    static CXmpp& instance();
    
    //和XMPP组合
    void setDelegate (XMPP* pDelegate) {
        m_delegateMutex.lock();
        m_pDelegate = pDelegate;
        vcardStack = [[NSMutableArray alloc] init];
        rooms = [[NSMutableArray alloc] init];
        m_delegateMutex.unlock();
    }
    
    //设置注册用户名、密码
    bool setLoginInfo(NSString* loginId, NSString* password);
    
    //发起连接请求
    void connect();
    
    //发起断开请求
    void disconnect();
    
    //发起获取联系人信息请求
    void requestVcard(NSString* jid);
    
    //返回client实例
    gloox::Client* client() {
        return m_pClient;
    };
    
    //开始个人聊天
    void startChat(gloox::JID& jid);
    
    //关闭个人聊天
    void closeSession(gloox::MessageSession* pSession);
    
    //加入聊天室
    void joinRooms(NSString* uid);
    
    //更新群联系人
    void updateRoomContacts();
    
protected:
    //连接成功回调
    virtual void 	onConnect ();
    
    //断开成功回调
    virtual void 	onDisconnect (gloox::ConnectionError e);
    
    //个人聊天session创建失败回调
    virtual void 	onSessionCreateError (const gloox::Error *error);
    
    //TLS连接创建成功回调
    virtual bool 	onTLSConnect (const gloox::CertInfo &info){
        return true;
    }
    
    //TODO comment
    //virtual void 	onResourceBind (const std::string &resource){};
    
    //TODO comment
    //virtual void 	onResourceBindError (const gloox::Error *error){};
    
    //TODO comment
    //virtual void 	onStreamEvent (gloox::StreamEvent event){};
    
    //返回请求的联系人信息回调
    virtual void 	handleVCard (const gloox::JID &jid, const gloox::VCard *vcard);
    
    //TODO comment
    virtual void 	handleVCardResult (gloox::VCardHandler::VCardContext context, const gloox::JID &jid, gloox::StanzaError se=gloox::StanzaErrorUndefined);
    
    //TODO 添加好友
    virtual void 	handleItemAdded (const gloox::JID &jid){};
    virtual void 	handleItemSubscribed (const gloox::JID &jid){};
    virtual void 	handleItemRemoved (const gloox::JID &jid){};
    virtual void 	handleItemUpdated (const gloox::JID &jid){};
    virtual void 	handleItemUnsubscribed (const gloox::JID &jid, const std::string&){};
    
    //联系人列表回调
    virtual void 	handleRoster (const gloox::Roster &roster);
    
    //TODO comment
    virtual void 	handlePresence (const gloox::Presence &presence);
    
    //个人聊天新消息回调
    virtual void    handleMessageSession (gloox::MessageSession* session);
    
    //联系人在线状态回调
    virtual void 	handleRosterPresence (const gloox::RosterItem &item, 
                                          const std::string &resource, 
                                          gloox::Presence::PresenceType presence, 
                                          const std::string &msg){};
    //个人在线状态回调
    virtual void 	handleSelfPresence (const gloox::RosterItem &item, 
                                        const std::string &resource, 
                                        gloox::Presence::PresenceType presence, 
                                        const std::string &msg){};
    
    //允许加好友请求回调
    virtual bool 	handleSubscriptionRequest (const gloox::JID &jid, const std::string &msg);
    
    //拒绝加好友请求回调
    virtual bool 	handleUnsubscriptionRequest (const gloox::JID &jid, const std::string &msg){return false;};
    
    //
    virtual void 	handleNonrosterPresence (const gloox::Presence &presence){};
    
    //第三方接入
    virtual void    handleGatewayLogin(const std::string& domain){};
    
    //联系人列表请求失败回调
    virtual void 	handleRosterError (const gloox::IQ &iq);
    
    
    virtual void    handleEvent(const gloox::Event& event);
    
    //日志回调
    virtual void    handleLog(gloox::LogLevel level, gloox::LogArea area, const std::string &message);

private:
    CXmpp();
    virtual ~CXmpp();
    gloox::Client* m_pClient;
    gloox::PubSub::Manager* m_pPubSubManager;
    gloox::RosterManager* m_pRosterManager;
    gloox::VCardManager* m_pVcardManager;
    XMPP* m_pDelegate;
    NSMutableArray* vcardStack;
    NSMutableArray* rooms;
    gloox::util::Mutex m_delegateMutex;
};

#pragma mark -
#pragma mark *** public functions ***

CXmpp::CXmpp()
:m_pClient(0),
m_pDelegate(0),
m_pRosterManager(0),
m_pVcardManager(0),
m_pPubSubManager(0)
{
}

CXmpp::~CXmpp()
{
    //disconnect();
    [vcardStack release];
    [rooms release];
    NSLog(@"class CXmpp destoried");
}

CXmpp&  CXmpp::instance()
{
    static CXmpp xmpp;
    return xmpp;
}

void    CXmpp::disconnect()
{
    if (m_pClient) {
        m_pClient->disconnect();
        delete m_pClient;
        m_pClient=0;
    }    
}

void    CXmpp::joinRooms(NSString* uid)
{
    if (!m_pClient) {
        return;
    }
    NSMutableArray* roomInfos = [[NSMutableArray alloc] initWithArray:[[m_pDelegate tgtRequest] getRoomList:uid]];
    for(NSDictionary* roomInfo in roomInfos){
        NSString* roomJidStr = [[NSString alloc] initWithFormat:@"%@@group.uc.sina.com.cn/%@darwin", [roomInfo valueForKey:@"groupid"], uid];
        gloox::JID roomJid([roomJidStr UTF8String]);
        gloox::MUCRoom* mucRoom = new gloox::MUCRoom(m_pClient, roomJid, 0, 0);
        XMPPMUCRoom* room = [[XMPPMUCRoom alloc] init];
        [room setXmpp:m_pDelegate];
        [room setGid:[roomInfo valueForKey:@"groupid"]];
        [room setJid:roomJidStr];
        [room setName:[roomInfo valueForKey:@"groupname"]];
        [room setRoom:mucRoom];
        [room setChatWindowCreated:NO];
        [rooms addObject:room];
        //[room release];
    }
    [m_pDelegate performSelectorOnMainThread:@selector(joinRooms:) withObject:rooms waitUntilDone:NO];
}

void    CXmpp::updateRoomContacts()
{
    NSMutableArray* roomContacts = [[NSMutableArray alloc] initWithCapacity:[rooms count]];
    for (XMPPMUCRoom* room in rooms) {
        NSMutableDictionary* contacts = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[m_pDelegate tgtRequest] getRoomContacts: [room gid]], @"contacts", [room jid], @"roomjid", nil];
        [roomContacts addObject:contacts];
        NSLog(@"%@", roomContacts);
    }
    [m_pDelegate performSelectorOnMainThread:@selector(updateRoomContacts:) withObject:roomContacts waitUntilDone:NO];
}

bool    CXmpp::setLoginInfo(NSString* loginId, NSString* password)
{
    delete m_pClient;
    delete m_pVcardManager;
    
    gloox::JID* jid = new gloox::JID();
    jid->setServer("uc.sina.com.cn");
    jid->setResource("darwin");
    [[m_pDelegate tgtRequest] setTgt:md5([NSString stringWithFormat:@"%@%@", loginId, password])];
    loginId = [loginId stringByReplacingOccurrencesOfString:@"@"
                                         withString:@"\\40"];
    jid->setUsername([loginId UTF8String]);
    m_pClient = new gloox::Client(*jid, [password UTF8String]);
    m_pClient->registerPresenceHandler( this );
    m_pClient->registerConnectionListener( this );
    m_pClient->logInstance().registerLogHandler( gloox::LogLevelDebug, gloox::LogAreaAll, this );
    m_pClient->registerMessageSessionHandler( this );
    m_pRosterManager = m_pClient->rosterManager();
    m_pRosterManager->registerRosterListener(this, false);
    m_pRosterManager->fill();
    m_pVcardManager = new gloox::VCardManager(m_pClient);
    m_pPubSubManager = new gloox::PubSub::Manager(m_pClient);
    return true;
}

void    CXmpp::connect()
{
    if (!m_pClient) {
        return;
    }
    if (m_pClient->connect(false)) {
        gloox::ConnectionError ce = gloox::ConnNoError;
        int i = 0;
        bool joined = false;
        while (ce == gloox::ConnNoError && ++i) {
            ce = m_pClient->recv(100000);
            if (!joined && [[[m_pDelegate myVcard] valueForKey:@"uid"] isEqualTo:@""] == NO) {
                joinRooms([[m_pDelegate myVcard] valueForKey:@"uid"]);
                updateRoomContacts();
                joined = true;
            }
            while ([vcardStack count] > 0 && [vcardStack objectAtIndex:0] != nil) {
                NSString *jidStr = [vcardStack objectAtIndex:0];
                gloox::JID jid([jidStr UTF8String]);
                m_pVcardManager->fetchVCard(jid, this);
                [vcardStack removeObjectAtIndex:0];
            }
            if (i%9000 == 0) {
                [[m_pDelegate tgtRequest] exchangeTgt];
                i = 0;
            }
            if (i%600 ==0) {
                gloox::JID* jid = new gloox::JID();
                jid->setServer("xmpp.uc.sina.com.cn");
                m_pClient->xmppPing(*jid, this);
            }
        }
        printf( "ce: %d\n", ce );
    }
    [m_pDelegate disconnect];
}

void    CXmpp::requestVcard(NSString* jid)
{
    if (!m_pVcardManager) {
        return;
    }
    [vcardStack addObject:jid];
}

void 	CXmpp::handleVCardResult (gloox::VCardHandler::VCardContext context, const gloox::JID &jid, gloox::StanzaError se)
{
    NSLog(@"vcard result");
}

void    CXmpp::startChat(gloox::JID& jid)
{
    if (!m_pDelegate) { 
        return; 
    }
    gloox::MessageSession* pSession = new gloox::MessageSession( m_pClient, jid );
    XMPPSession* session = [[XMPPSession alloc] init];
    [session setSession:pSession];
    [session setXmpp:m_pDelegate];
    [[m_pDelegate sessionManager] addSession:session];
}

void    CXmpp::closeSession(gloox::MessageSession* pSession)
{
    m_pClient->disposeMessageSession(pSession);
}

#pragma mark -
#pragma mark *** ConnectionListener ***
void 	CXmpp::onConnect ()
{
    if (!m_pDelegate) {
        return;
    }
    NSString* myJid = [NSString stringWithUTF8String: m_pClient->jid().bare().c_str()];
    [m_pDelegate performSelectorOnMainThread:@selector(onConnect:) withObject:myJid waitUntilDone:NO];
}

void 	CXmpp::onDisconnect (gloox::ConnectionError e)
{
    if (!m_pDelegate) {
        return;
    }
    if (m_pVcardManager){
        delete m_pVcardManager;
        m_pVcardManager = 0;    
    }
    if (m_pRosterManager) {
        m_pRosterManager->removeRosterListener();
    }
    if (m_pPubSubManager) {
        delete m_pPubSubManager;
        m_pPubSubManager = 0;
    }
    NSString* errorString = [[NSString alloc] initWithFormat:@"%d", e];
    [m_pDelegate performSelectorOnMainThread:@selector(onDisconnect:) withObject:errorString waitUntilDone:NO];
}

void 	CXmpp::onSessionCreateError (const gloox::Error *error)
{
    if (!m_pDelegate) { 
        return; 
    }
    std::string errorString;
    if (error) {
        errorString = error->text();
    } else {
        errorString = "";
    }
    NSString* errorMessage = [[NSString init ]initWithCString:errorString.c_str() encoding:NSASCIIStringEncoding];
    [m_pDelegate performSelectorOnMainThread:@selector(onDisconnect:) withObject:errorMessage waitUntilDone:NO];    
}

#pragma mark -
#pragma mark *** VCard Handlers ***
void 	CXmpp::handleVCard (const gloox::JID &jid, const gloox::VCard *vcard)
{
    if (!m_pDelegate) {
        return;
    }
    ContactItem* item = [[ContactItem alloc] init];
    [item setVcard:YES];
    [item setJid:[NSString stringWithUTF8String:jid.bare().c_str()]];
    [item setFullJid:[NSString stringWithUTF8String:jid.full().c_str()]];
    if (vcard->photo().extval == "") {
        NSData* imageData = [NSData dataWithBytes:vcard->photo().binval.c_str() length:vcard->photo().binval.size()];
        [item setPhoto:imageData];
        [imageData release];
    } else {
        NSURL* url = [NSURL URLWithString:[NSString stringWithUTF8String:vcard->photo().extval.c_str()]];
        if (url) {
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            [item setPhoto:imageData];
            [imageData release];
        }
    }
    [item setName:[NSString stringWithUTF8String:vcard->nickname().c_str()]];
    if ([[item jid] isEqualToString:[NSString stringWithUTF8String:m_pClient->jid().bare().c_str()]] == NO) {
        [m_pDelegate performSelectorOnMainThread:@selector(updateContact:) withObject:item waitUntilDone:NO];
    } else {
        [m_pDelegate performSelectorOnMainThread:@selector(updateSelfVcard:) withObject:item waitUntilDone:NO];
    }
}

#pragma mark -
#pragma mark *** RosterListener ***
void 	CXmpp::handleRoster (const gloox::Roster &roster)
{
    if (!m_pDelegate) { 
        return; 
    }
    gloox::Roster* pRoster = new gloox::Roster(roster);
    gloox::Roster::iterator it;
    NSMutableArray* contacts = [[NSMutableArray alloc ]initWithCapacity:pRoster->size()];
    for (it = pRoster->begin(); it != pRoster->end(); it++) {
        NSString* strKey = [NSString stringWithUTF8String:(*it).first.c_str()];
        gloox::RosterItem* pItem = (*it).second;
        NSString* strJid = [NSString stringWithUTF8String:pItem->jid().c_str()];
        NSMutableArray* groups = [[NSMutableArray alloc]init ];
        gloox::StringList list(pItem->groups());
        gloox::StringList::iterator group;
        for (group = list.begin(); group != list.end(); group++) {
            [groups addObject:[NSString stringWithUTF8String:(*group).c_str()]];            
        }
        NSString* strName = [NSString stringWithUTF8String:pItem->name().c_str()];
        BOOL online = pItem->online();
        ContactItem* item = [[ContactItem alloc] init];
        [item setKey:strKey];
        [item setJid:strJid];
        [item setName:strName];
        [item setPinyin:[ChineseToPinyin pinyinFromChiniseString:strName]];
        [item setOnline:online];
        [item setGroups:[NSArray arrayWithArray:groups]];
        [contacts addObject:item];
        [item release];
    }
    [m_pDelegate performSelectorOnMainThread:@selector(updateContacts:) withObject:contacts waitUntilDone:NO];
}

void 	CXmpp::handleRosterError (const gloox::IQ &iq)
{    
    NSLog(@"Roster Error");
}

bool 	CXmpp::handleSubscriptionRequest (const gloox::JID &jid, const std::string &msg)
{
    /*m_delegateMutex.lock();
    if (!m_pRosterManager) {
        m_delegateMutex.unlock();
        return false;
    }
    printf( "subscription: %s\n", jid.bare().c_str() );
    printf( "subscription msg: %s\n", msg.c_str() );
    gloox::StringList groups;
    groups.insert(groups.begin(), "sina");
    m_pRosterManager->subscribe(jid, "", groups, "");
    m_delegateMutex.unlock();*/
    return false;
}

#pragma mark-
#pragma mark *** Event Handler ***
void    CXmpp::handleEvent (const gloox::Event &event) {
    std::string sEvent;  
    switch (event.eventType())  
    {  
        case gloox::Event::PingPing:   //! 收到PING消息  
            sEvent = "PingPing";  
            break;  
        case gloox::Event::PingPong:   //! 收到返回PONG消息,心跳累计次数减1  
            sEvent = "PingPong";  
            //decreaceHeartBeatCount();  
            break;  
        case gloox::Event::PingError:  //!   
            sEvent = "PingError";  
            break;  
        default:  
            break;  
    }  
    return; 
}

#pragma mark -
#pragma mark *** Message Hander ***
void 	CXmpp::handleMessageSession(gloox::MessageSession *session)
{
    if (!m_pDelegate) { 
        return; 
    }
    XMPPSession* s = [[XMPPSession alloc] init];
    [s setSession:session];
    [s setIncomingSession:YES];
    [s setXmpp:m_pDelegate];
    [[m_pDelegate sessionManager] performSelectorOnMainThread:@selector(addSession:) withObject:s waitUntilDone:YES];
}

#pragma mark -
#pragma mark *** Presence Handlers ***
void 	CXmpp::handlePresence (const gloox::Presence &presence)
{
    if (!m_pDelegate) { 
        return; 
    }
    ContactItem* item = [[ContactItem alloc] init];
    [item setVcard:YES];
    [item setJid:[NSString stringWithUTF8String:presence.from().bare().c_str()]];
    [item setFullJid:[NSString stringWithUTF8String:presence.from().full().c_str()]];
    [item setStatus:[NSString stringWithUTF8String:presence.status().c_str()]];
    [item setPresence:presence.subtype()];
    [m_pDelegate performSelectorOnMainThread:@selector(updateContact:) withObject:item waitUntilDone:NO];
}

#pragma mark -
#pragma mark *** Log Handler ***
void    CXmpp::handleLog(gloox::LogLevel level, gloox::LogArea area, const std::string &message){
    //printf("log: level: %d, area: %d, %s\n", level, area, message.c_str());
}

#pragma mark -
#pragma mark *** XMPPThread ***
@interface XMPPThread : NSThread {
@private
}
@end

@implementation XMPPThread
- (id)init
{
    self = [super init];
    if (self) {
        //NSLog(@"XMPPThread initialized");
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    //NSLog(@"XMPPThread destroyed");
}

- (void)main
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    //NSLog(@"XMPPThread started");
    CXmpp::instance().connect();
    //NSLog(@"XMPPThread ended");
    [pool release];
}
@end

#pragma mark -
#pragma mark *** XMPP Implementation ***

@implementation XMPP
@synthesize myVcard;
@synthesize vcardUpdateDelegate;
@synthesize searchDelegate;

//SYNTHESIZE_SINGLETON_FOR_CLASS(XMPP)

- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        connectionDelegates = [[NSMutableArray alloc] init];
        tgtRequest = [[RequestWithTGT alloc] init];
        myVcard = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"", @"uid", @"", @"jid", @"", @"name", nil, @"image", nil];
        //NSLog(@"XMPP initialized");
    }
    return self;
}

- (void) dealloc
{
    CXmpp::instance().setDelegate(nil);
    [connectionDelegates release];
    [tgtRequest release];
    [myVcard release];
    [xmppThread release];
    [super dealloc];
    //NSLog(@"XMPP destroyed");
}

- (XMPPSessionManager*) sessionManager
{
    return sessionManager;
}

- (XMPPMUCRoomManager*) mucRoomManager
{
    return mucRoomManager;
}

- (RequestWithTGT*) tgtRequest
{
    return tgtRequest;
}

- (BOOL) isFinished
{
    if (!xmppThread) {
        return YES;
    }
    return [xmppThread isFinished];
}

- (void) requestVcard:(NSString*) jid {
    CXmpp::instance().requestVcard(jid);
}

- (void) registerConnectionDelegate:(id < XMPPConnectionDelegate >) connectionDelegate
{
    [connectionDelegates addObject:connectionDelegate];
}

- (void) deregisterConnectionDelegate:(id < XMPPConnectionDelegate >) connectionDelegate
{
    [connectionDelegates removeObject:connectionDelegate];
}

- (BOOL) loginWithId:(NSString*) loginId withPassword:(NSString*) password
{
    CXmpp::instance().setDelegate(self);
    CXmpp::instance().setLoginInfo(loginId, password);
    if (xmppThread || [xmppThread isExecuting]) {
        [NSException raise:@"Cannot do login process" format:@"XMPP Thread is already running"];
        return NO;
    } else {
        xmppThread = [[XMPPThread alloc] init];
        [xmppThread start];
        return YES;
    }
}

- (void) disconnect
{
    if (xmppThread) {
        [xmppThread release];
        xmppThread = nil;
    }
    CXmpp::instance().disconnect();
    //NSLog(@"XMPP disconnect");
}

- (void) startChat:(NSString*) jid
{
    if (!jid) {
        return;
    }
    if ([sessionManager activateSession:jid]) {
        return;
    }
    gloox::JID glooxJid([jid UTF8String]);
    CXmpp::instance().startChat(glooxJid);
}

- (void) startRoomChat:(NSString*) jid
{
    if ([mucRoomManager activateRoom:jid]) {
        return;
    }
}

#pragma mark -
#pragma mark *** XMPP callback handlers ***

- (void) onConnect:(NSString*) myJid
{
    CXmpp::instance().requestVcard(myJid);
}

- (void) updateSelfVcard:(ContactItem*) item
{
    NSArray* jidArr = [[NSArray alloc] initWithArray:[[item jid] componentsSeparatedByString:@"@"]];   

    [myVcard setValue:[jidArr objectAtIndex:0] forKey:@"uid"];
    [myVcard setValue:[item jid] forKey:@"jid"];
    [myVcard setValue:[item name] forKey:@"name"];
    [myVcard setValue:[item photo] forKey:@"image"];
    [tgtRequest setMyJid:[item jid]];
        
    NSEnumerator* e = [connectionDelegates objectEnumerator];
    id < XMPPConnectionDelegate > connectionDelegate;
    while (connectionDelegate = [e nextObject]) {
        [connectionDelegate onConnect];
    }
}

- (void) onDisconnect:(NSString*) errorString
{
    gloox::ConnectionError error = (gloox::ConnectionError)[errorString intValue];
    NSEnumerator* e = [connectionDelegates objectEnumerator];
    id < XMPPConnectionDelegate > connectionDelegate;
    while ((connectionDelegate = [e nextObject])) {
        [connectionDelegate onDisconnectWithErrorCode:error];
    }
    [errorString release];
    CXmpp::instance().setDelegate(nil);
}

- (void) updateContact:(ContactItem*) contact
{
    if (!vcardUpdateDelegate) {
        [contact release];
        return;
    }
    [vcardUpdateDelegate vcardUpdate:contact];
    if (![contact vcard]) {
        CXmpp::instance().requestVcard([contact fullJid]);
    }
    [contact release];
}

- (void) updateContacts:(NSMutableArray*) contacts
{
    if (!vcardUpdateDelegate) {
        [contacts release];
        return;
    }
    for (ContactItem* contact in contacts) {
        [vcardUpdateDelegate vcardUpdate:contact];
        if (![contact vcard]) {
            CXmpp::instance().requestVcard([contact jid]);
        }
    }
    [contacts release];
}

- (void) updateRoomContacts:(NSMutableArray*) roomContacts
{
    for (NSMutableDictionary* contacts in roomContacts) {
        [mucRoomManager updateRoomContacts:[contacts valueForKey:@"contacts"] withRoomJid:[contacts valueForKey:@"roomjid"]];
    }
}

- (void) searchContacts:(NSString*) cond
{
    if (!searchDelegate) {
        return;
    }
    [searchDelegate search:cond];
}

- (void) joinRooms:(NSMutableArray*) rooms
{
    if (!mucRoomManager) {
        return;
    }
    for (XMPPMUCRoom* room in rooms) {
        [mucRoomManager updateRoom:room];
        [mucRoomManager joinRoom:room];
    }
}

#pragma mark -
- (void) close:(XMPPSession*) session
{
    CXmpp::instance().closeSession([session session]);
    [sessionManager performSelector:@selector(removeSession:) withObject:session afterDelay:0];
}

@end
