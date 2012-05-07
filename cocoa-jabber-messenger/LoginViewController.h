//
//  LoginViewController.h
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/16/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMPPConnectionDelegate.h"
@class XMPP;
@interface LoginViewController : NSViewController <XMPPConnectionDelegate> {
@private
    IBOutlet NSTextField* loginField;
    IBOutlet NSTextField* passwordField;
    IBOutlet NSButton* savePasswordButton;
    IBOutlet NSButton* submitButton;
	IBOutlet NSProgressIndicator* inProgress;
    
    BOOL isSavePassword;
    
    IBOutlet XMPP* xmpp;
    
}
- (IBAction)savePassword:(id)sender;
- (IBAction)signIn:(id)sender;
@end
