//
//  GrowlLinker.m
//  Ta
//
//  Created by Sangeun Kim on 3/15/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "GrowlLinker.h"



@implementation GrowlLinker
/* Init method */
- (id) init { 
    self = [super init];
    return self;
}

- (void) setDelegate
{
	/* Tell growl we are going to use this class to hand growl notifications */
	[GrowlApplicationBridge setGrowlDelegate:self];
}

/* Begin methods from GrowlApplicationBridgeDelegate */
- (NSDictionary *) registrationDictionaryForGrowl { /* Only implement this method if you do not plan on just placing a plist with the same data in your app bundle (see growl documentation) */
	NSArray *array = [NSArray arrayWithObjects:NOTIFICATION_CONTACT_SIGNIN, NOTIFICATION_CONTACT_SIGNOFF, NOTIFICATION_INCOMING_MESSAGE, nil]; /* each string represents a notification name that will be valid for us to use in alert methods */
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                          [NSNumber numberWithInt:1], /* growl 0.7 through growl 1.1 use ticket version 1 */
  //                        GROWL_TICKET_VERSION, /* Required key in dictionary */
                          array, /* defines which notification names our application can use, we defined example and error above */
                          GROWL_NOTIFICATIONS_ALL, /*Required key in dictionary */
                          array, /* using the same array sets all notification names on by default */
                          GROWL_NOTIFICATIONS_DEFAULT, /* Required key in dictionary */
                          nil];
    return dict;
}

- (NSString *) applicationNameForGrowl
{
	return @"UC4Mac";
}

- (void) growlNotificationWasClicked:(id)clickContext{
    if (!clickContext)
    {
        return;
    }
    if ([clickContext isEqualToString:NOTIFICATION_CONTACT_SIGNIN])
    {
        [self onShowWindow];
        return;        
    }
    if ([clickContext isEqualToString:NOTIFICATION_CONTACT_SIGNOFF])
    {
        [self onShowWindow];
        return;        
    }
    if ([clickContext isEqualToString:NOTIFICATION_INCOMING_MESSAGE])
    {
        [self onShowWindow];
        return;        
    }
}

- (void) growlIsReady
{
}

/* These methods are not required to be implemented, so we will skip them in this example 
 - (NSString *) applicationNameForGrowl;
 - (NSData *) applicationIconDataForGrowl;
 - (void) growlNotificationTimedOut:(id)clickContext;
 */ 
/* There is no good reason not to rely on the what Growl provides for the next two methods, in otherwords, do not override these methods
 - (void) growlIsReady;
 - (void) growlIsInstalled;
 */
/* End Methods from GrowlApplicationBridgeDelegate */

/* Simple method to make an alert with growl that has no click context */
-(void) alert:(NSString *)message title:(NSString *)title{
    [GrowlApplicationBridge notifyWithTitle:title /* notifyWithTitle is a required parameter */
								description:message /* description is a required parameter */
						   notificationName:@"NAVER talk" /* notification name is a required parameter, and must exist in the dictionary we registered with growl */
								   iconData:nil /* not required, growl defaults to using the application icon, only needed if you want to specify an icon. */ 
								   priority:0 /* how high of priority the alert is, 0 is default */
								   isSticky:NO /* indicates if we want the alert to stay on screen till clicked */
							   clickContext:nil]; /* click context is the method we want called when the alert is clicked, nil for none */
}

/* Simple method to make an alert with growl that has a click context */
-(void) alertWithType:(NSString*)type message:(NSString *)message title:(NSString *)title{
    [GrowlApplicationBridge notifyWithTitle:title /* notifyWithTitle is a required parameter */
                                description:message /* description is a required parameter */
                           notificationName:type /* notification name is a required parameter, and must exist in the dictionary we registered with growl */
                                   iconData:nil /* not required, growl defaults to using the application icon, only needed if you want to specify an icon. */ 
                                   priority:0 /* how high of priority the alert is, 0 is default */
                                   isSticky:NO /* indicates if we want the alert to stay on screen till clicked */
                               clickContext:type]; /* click context is the method we want called when the alert is clicked, nil for none */
}

/* An example click context */
-(void) onShowWindow{
    /* code to execute when alert is clicked */
	if(![NSApp isActive])
	{
		[NSApp activateIgnoringOtherApps:YES];
	}
    return;
}

/* Dealloc method */
- (void) dealloc { 
    [super dealloc]; 
}
@end
