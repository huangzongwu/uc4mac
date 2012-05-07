//
//  cocoa_jabber_messengerAppDelegate.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/16/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GrowlLinker;

@interface cocoa_jabber_messengerAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSInteger unreadMessageCount;
    IBOutlet GrowlLinker* growl;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction) showWindow:(id)sender;

@end
