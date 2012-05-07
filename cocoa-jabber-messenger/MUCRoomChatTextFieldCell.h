//
//  MUCRoomChatTextFieldCell.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-4.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseChatTextFiledCell.h"

@interface MUCRoomChatTextFieldCell : BaseChatTextFiledCell
{
@private
    NSString* sender;
}
@property (nonatomic, copy) NSString* sender;
@end
