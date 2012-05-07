//
//  LaunchedViewController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-1-30.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "LaunchedViewController.h"
#import "XMPP.h"

@implementation LaunchedViewController
@synthesize myImage;
@synthesize myJid;
@synthesize myName;

- (void)awakeFromNib
{
    [xmpp registerConnectionDelegate:self];
}

- (void)dealloc
{
    [super dealloc];
}

- (void) setMyJid:(NSString*) theJid
{
    [myJid release];
    myJid = theJid;
    [myJidField setStringValue:theJid];
}

- (void) setMyName:(NSString*) theName
{
    [myName release];
    myName = theName;
    [myNameField setStringValue:theName];
}

- (void) setMyImage:(NSImage*) theImage
{
    if (myImage == theImage) {
        return;
    }
    [profileImageView setImage:theImage];
    [myImage release];
    myImage = [theImage retain];
}

- (IBAction) switchView:(id) sender
{
    [contactAndRoomContainer selectTabViewItemAtIndex:[sender selectedSegment]];
}

- (IBAction) search:(id) sender
{
    if ([[sender stringValue] isEqualToString:@""] == NO) {
        [xmpp searchContacts:[sender stringValue]];
        [contactAndSearchContainer selectTabViewItemAtIndex:1];
    } else {
        [contactAndSearchContainer selectTabViewItemAtIndex:0];
    }
}

#pragma mark -
#pragma mark *** Connection Delegate ***

- (void) onConnect
{
    [[self view] setHidden:NO];
    NSUInteger style = [[[self view] window] styleMask]; 
    [[[self view] window] setStyleMask:style|NSResizableWindowMask];
    [self setMyJid: [[xmpp myVcard] valueForKey:@"jid"]];
    [self setMyName: [[xmpp myVcard] valueForKey:@"name"]];
    NSImage* image = [[NSImage alloc] initWithData:[[xmpp myVcard] valueForKey:@"image"]];
    [self setMyImage:image];
    [image release];
}

- (void) onDisconnectWithErrorCode:(NSInteger) errorCode
{
    [[self view]setHidden:YES];
}

@end
