//
//  cocoa_jabber_messengerAppDelegate.m
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/16/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "cocoa_jabber_messengerAppDelegate.h"
#import "MessageItem.h"
#import "ContactItem.h"
#import "GrowlLinker.h"
#import "SQLiteInstanceManager.h"

@implementation cocoa_jabber_messengerAppDelegate
@synthesize window;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    unreadMessageCount = 0;
    [growl setDelegate];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(readMessage:) name:@"readMessage" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(unreadMessage:) name:@"unreadMessage" object:nil];
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(contactStatus:) name:@"contactStatus" object:nil];
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    fileManager = [NSFileManager defaultManager];
    NSArray *paths = [[NSArray alloc] initWithArray:NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)];
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    applicationSupportFolder = [[NSString alloc] initWithString:[basePath stringByAppendingPathComponent:@"UC4Mac"]];
    [paths release];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [[SQLiteInstanceManager sharedManager] setDatabaseFilepath:[applicationSupportFolder stringByAppendingPathComponent:@"uc4mac.db"]];
    [applicationSupportFolder release];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}

- (IBAction) showWindow:(id)sender
{
    [window makeKeyAndOrderFront:sender];
}

- (void) readMessage:(NSNotification*) notification
{
    unreadMessageCount = 0;
    [[NSApp dockTile]setBadgeLabel:@""];   
}

- (void) unreadMessage:(NSNotification*) notification
{
    MessageItem* item = [notification object];
    NSString* label = [NSString stringWithFormat:@"%d", ++unreadMessageCount];
    [[NSApp dockTile]setBadgeLabel:label];
    [NSApp requestUserAttention: NSInformationalRequest];
    [growl alertWithType:NOTIFICATION_INCOMING_MESSAGE message:[item message] title:[item name]];
}

- (void) contactStatus:(NSNotification*) notification
{
    
    ContactItem*  item = [notification object];
    NSString* type;
    NSString* message;
    switch ([item presence]) {
        case 5:
            type = NOTIFICATION_CONTACT_SIGNOFF;
            message = @"has just logged off.";
            break;
            
        case -1:
            return;
            break;
            
        default:
            type = NOTIFICATION_CONTACT_SIGNIN;
            message = @"has just logged in.";
            break;
    }
    
    [growl alertWithType:type message:message title:[item name]];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*) theApplication hasVisibleWindows:(BOOL) flag {
    [window makeKeyAndOrderFront:self];
    return YES;
}

@end
