//
//  AsyncImageView.h
//  SinaUC
//
//  Created by 硕实 陈 on 12-5-5.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncImageDelegate.h"

@protocol AsyncImageDelegate;
@interface AsyncImage : NSObject {

@private
    NSMutableArray* asyncImageDelegates;
    NSURLConnection* connection;
    NSMutableData* data;
    NSString* picName;
}

@property (retain) NSMutableData* data;
@property (retain) NSString* picName;
@property (retain) NSMutableArray* asyncImageDelegates;

- (void) loadImage:(NSString*) url;
- (void) registerAsyncImageDelegate:(id <AsyncImageDelegate>) asyncImageDelegate;
- (void) deregisterAsyncImageDelegate:(id <AsyncImageDelegate>) asyncImageDelegate;

@end
