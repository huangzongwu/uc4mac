//
// XMPPConnectionDelegate.h
// cocoa-jabber-messenger

// Created by Sangeun Kim on 4/17/11.
// Checked by Chen shuoshi on 1/30/12.
// 该接口主要用于在各controller间传递登陆信号和异常断开信号
// 各实现类在初始化时（awakeFromNib)调用私有成员xmpp的registerConnectionDelegate
// 将自己注册到回调数组connectionDelegates中（XMPP.h定义），异步登陆后，xmpp将遍历
// 注册的类，并调用各类自己的onConnect事件。如果连接中断，将调用各类的onDisconnectWithErrorCode


#import <Foundation/Foundation.h>


@protocol XMPPConnectionDelegate <NSObject>
- (void) onConnect;
- (void) onDisconnectWithErrorCode:(NSInteger) errorCode;
@end
