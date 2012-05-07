//
//  LoginViewController.m
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/16/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "LoginViewController.h"
#import "XMPP.h"

@implementation LoginViewController

- (void)awakeFromNib
{  
    [xmpp registerConnectionDelegate:self];
	NSUserDefaults* userDefaults;
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* strLoginid = [userDefaults stringForKey:@"loginid"];
	NSString* strPassword = [userDefaults stringForKey:@"password"]	;
	
	if (strLoginid) {
		[loginField setStringValue:strLoginid];
	}
	if (strPassword) {
		[passwordField setStringValue:strPassword];
		if ([strPassword isEqualToString:@""]) {
			isSavePassword = NO;
		}
		else {
			isSavePassword = YES;
		}
	}
	else {
		isSavePassword = NO;
	}
	
	[savePasswordButton setState:isSavePassword?NSOnState:NSOffState];
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)savePassword:(id)sender
{
	isSavePassword = ([savePasswordButton state]==NSOnState);	
}

- (IBAction) signIn:(id) sender
{
    @try {
        BOOL loginFlag = [xmpp loginWithId:[loginField stringValue] withPassword:[passwordField stringValue]];
        if (loginFlag == TRUE) {
            [[NSUserDefaults standardUserDefaults] setObject:[loginField stringValue] forKey:@"loginid"];
            if (isSavePassword) {
                [[NSUserDefaults standardUserDefaults] setObject:[passwordField stringValue] forKey:@"password"];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
            }
            [loginField setEditable:NO];
            [passwordField setEditable:NO];
            [savePasswordButton setEnabled:NO];
            [submitButton setEnabled:NO];
            [inProgress setHidden:NO];
            [inProgress startAnimation:self];
        } else {
            NSRunAlertPanel(@"Login Failed", @"Invailid login format", @"OK", NULL, NULL);
        }
    } @catch(NSException* e) {
		NSRunAlertPanel(@"Login Failed", [e reason], @"OK", NULL, NULL);
        return;
    }
}

- (void) onConnect
{
    [[self view] setHidden:YES];
}

- (void) onDisconnectWithErrorCode:(NSInteger) errorCode
{
    [loginField setEditable:YES];
    [passwordField setEditable:YES];
    [savePasswordButton setEnabled:YES];
    [submitButton setEnabled:YES];
    [inProgress setHidden:YES];
    [inProgress stopAnimation:self];
    [[self view]setHidden:NO];
    switch (errorCode) {
        case 16:
            NSRunInformationalAlertPanel(@"Login Failed", @"Authnication failed - wrong password", @"OK", NULL, NULL);
            break;
        default:
            break;
    }
}

@end
