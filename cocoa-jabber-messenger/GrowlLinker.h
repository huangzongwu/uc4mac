//
//  GrowlLinker.h
//  Ta
//
//  Created by Sangeun Kim on 3/15/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

#define NOTIFICATION_CONTACT_SIGNIN      @"contact sign-in"
#define NOTIFICATION_CONTACT_SIGNOFF     @"contact sign-off"
#define NOTIFICATION_INCOMING_MESSAGE    @"Incomming messages"

@interface GrowlLinker : NSObject  <GrowlApplicationBridgeDelegate>{
	GrowlApplicationBridge* bridge;
}
-(void) alert:(NSString *)message title:(NSString *)title;
-(void) alertWithType:(NSString*)type message:(NSString *)message title:(NSString *)title;
-(void) onShowWindow;	
- (void) setDelegate;

@end
