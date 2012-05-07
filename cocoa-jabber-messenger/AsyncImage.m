//
//  AsyncImageView.m
//  SinaUC
//
//  Created by 硕实 陈 on 12-5-5.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "AsyncImage.h"
#import "AsyncImageDelegate.h"

@implementation AsyncImage
@synthesize picName;
@synthesize data;

- (void)loadImageFromURL:(NSURL*) url {
    if (connection) { 
        [connection release]; 
    }
    if (data) { 
        [data release]; 
    }
    NSLog(@"url: %@", url);
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                             timeoutInterval:15];
    connection = [[NSURLConnection alloc]
                  initWithRequest:request delegate:self];
    //TODO error handling, what if connection is nil?
    if (connection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        data = [[NSMutableData alloc] init];
    } else {
        NSLog(@"fail to get pic %@", url);
    }
}

- (void) connection:(NSURLConnection*) theConnection didReceiveData:(NSData*) incrementalData 
{
    [data appendData:incrementalData];
}

- (void) connection:(NSURLConnection*) theConnection didReceiveResponse:(NSURLResponse*) response
{
    NSLog(@"recv init");
    [data setLength:0];
}

- (void) connection:(NSURLConnection*) theConnection didFailWithError:(NSError*) error
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void) registerAsyncImageDelegate:(id < AsyncImageDelegate >) connectionDelegate
{
    [asyncImageDelegates addObject:connectionDelegate];
}

- (void) deregisterAsyncImageDelegate:(id < AsyncImageDelegate >) connectionDelegate
{
    [asyncImageDelegates removeObject:connectionDelegate];
}

- (void) connectionDidFinishLoading:(NSURLConnection*) theConnection 
{
    NSEnumerator* e = [asyncImageDelegates objectEnumerator];
    id < AsyncImageDelegate > asyncImageDelegate;
    while (asyncImageDelegate = [e nextObject]) {
        [asyncImageDelegate imageloaded:picName withData:data];
    }
}

- (void)dealloc {
    [connection cancel];
    [connection release];
    [super dealloc];
}


@end
