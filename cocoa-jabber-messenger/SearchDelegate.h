//
//  SearchDelegate.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-5-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchDelegate <NSObject>
- (void) search:(NSString*) cond;
@end