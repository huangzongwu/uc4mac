//
//  MessageItem.mm
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/22/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "MessageItem.h"
#import "RegexKitLite.h"

@implementation MessageItem
@synthesize type;
@synthesize name;
@synthesize message;
@synthesize jid;
@synthesize timeStamp;
@synthesize images;

- (void) setMessage:(NSString *) theMessage
{
    [message release];
    if ([theMessage rangeOfString:@"\t\t\t36"].location != NSNotFound) {
        NSString *regex = @"\\t{3}36([a-z0-9]+?\\.(?:jpg|png|gif))";
        NSArray* origImages = [theMessage arrayOfCaptureComponentsMatchedByRegex:regex];
        if ([origImages count] > 0) {
            images = [[NSMutableArray alloc] init];
            for (NSArray* urlString in origImages) {
                NSString* origString = [urlString objectAtIndex:0];
                NSString* url = [urlString objectAtIndex:1];
                [images addObject:url];
                theMessage = [theMessage stringByReplacingOccurrencesOfString:origString withString:@""];
            }
        }
    }
    message = [theMessage retain];
}
@end