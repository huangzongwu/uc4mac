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

- (id) init
{
    self = [super init];
    if (self) {
        images = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [images removeAllObjects];
    [images release];
}

- (void) setMessage:(NSString *) theMessage
{
    [message release];
    if ([theMessage rangeOfString:@"\t\t\t36"].location != NSNotFound) {
        NSString *regex = @"\\t{3}36([a-z0-9]+?\\.(?:jpg|png|gif))";
        NSArray* origImages = [theMessage arrayOfCaptureComponentsMatchedByRegex:regex];
        if ([origImages count] > 0) {
            for (NSArray* urlString in origImages) {
                NSString* origString = [urlString objectAtIndex:0];
                NSString* url = [urlString objectAtIndex:1];
                [images addObject:url];
                theMessage = [theMessage stringByReplacingOccurrencesOfString:origString withString:
                              [NSString stringWithFormat:@"http://uc.s.dpool.sina.com.cn/nd/img1uc/%@/%@/%@", 
                               [url substringWithRange:NSMakeRange(0, 2)],
                               [url substringWithRange:NSMakeRange(2, 2)],
                               url]];
            }
        }
    }
    message = [theMessage retain];
}
@end