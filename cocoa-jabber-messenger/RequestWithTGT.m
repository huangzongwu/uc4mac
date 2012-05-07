//
//  RequestWithTGT.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-4.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "RequestWithTGT.h"
#import "JSONKit.h"

@implementation RequestWithTGT
@synthesize myJid;
@synthesize tgt;

- (NSMutableArray*) getRoomList:(NSString*) jid
{
    NSString* urlStr = [[NSString alloc] initWithFormat:@"http://202.106.184.141/group-list/%@", jid];
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:tgt forHTTPHeaderField:@"X-UC-AUTH"];
    [request setValue:@"tgt" forHTTPHeaderField:@"X-UC-AUTH-TYPE"];
    NSError *err=nil;
    NSData *data=[NSURLConnection sendSynchronousRequest:request
                                       returningResponse:nil 
                                                   error:&err];
    [urlStr release];
    [url release];
    [request release];
    
    return [data objectFromJSONData];
}

- (NSMutableArray*) getRoomContacts:(NSString*) gid
{
    NSArray* jidArr = [[NSArray alloc] initWithArray:[myJid componentsSeparatedByString:@"@"]];
    NSString* guid = [[RequestWithTGT class] stringWithUUID];
    NSString* urlStr = [[NSString alloc] initWithFormat:@"http://202.106.184.141/group-user/%@?uid=%@&RandomGuid=@%", gid, [jidArr objectAtIndex:0], guid];
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:tgt forHTTPHeaderField:@"X-UC-AUTH"];
    [request setValue:@"tgt" forHTTPHeaderField:@"X-UC-AUTH-TYPE"];
    NSError *err=nil;
    NSData *data=[NSURLConnection sendSynchronousRequest:request
                                       returningResponse:nil 
                                                   error:&err];
    [urlStr release];
    [url release];
    [request release];
    [jidArr release];
    
    return [data objectFromJSONData];
}

- (void) exchangeTgt
{
    NSString* urlStr = [[NSString alloc] initWithFormat:@"http://218.30.115.182/sso/update?tgt=%@", tgt];
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                       returningResponse:nil 
                                                   error:&err];
    if (!err && [[data objectFromJSONData] count] > 0) {
        tgt = [[data objectFromJSONData] valueForKey:@"tgt"];
    }
    [urlStr release];
    [url release];
    [request release];
}

+ (NSString*) stringWithUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString* uuidString = (NSString*) CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
}

@end
