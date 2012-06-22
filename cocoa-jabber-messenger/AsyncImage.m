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
@synthesize asyncImageDelegates;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        asyncImageDelegates = [[NSMutableArray alloc] init];
    }    
    return self;
}

- (void) loadImage:(NSString*) thePicName 
{
    if (connection) { 
        [connection release]; 
    }
    if (data) { 
        [data release]; 
    }
    [self setPicName:thePicName];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:
                                [NSString stringWithFormat:@"http://uc.s.dpool.sina.com.cn/nd/img1uc/%@/%@/%@", 
                                [thePicName substringWithRange:NSMakeRange(0, 2)],
                                [thePicName substringWithRange:NSMakeRange(2, 2)],
                                thePicName]]
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
        NSLog(@"fail to get pic %@", thePicName);
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

- (void) registerAsyncImageDelegate:(id < AsyncImageDelegate >) asyncImageDelegate
{
    [asyncImageDelegates addObject:asyncImageDelegate];
}

- (void) deregisterAsyncImageDelegate:(id < AsyncImageDelegate >) asyncImageDelegate
{
    [asyncImageDelegates removeObject:asyncImageDelegate];
}

- (void) connectionDidFinishLoading:(NSURLConnection*) theConnection 
{
    //write data to /tmp/picname
    [data writeToFile:[NSString stringWithFormat:@"/tmp/%@", picName] atomically:false];
    NSEnumerator* e = [asyncImageDelegates objectEnumerator];
    id < AsyncImageDelegate > asyncImageDelegate;
    while (asyncImageDelegate = [e nextObject]) {
        [asyncImageDelegate imageloaded:picName];
    }
}

- (void) dealloc 
{
    [connection cancel];
    [connection release];
    [asyncImageDelegates release];
    [super dealloc];
}


@end
