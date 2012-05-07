

//
//  main.m
//  cocoa-jabber-messenger
//
//  Created by Sangeun Kim on 4/16/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    int ret = NSApplicationMain(argc, (const char**)argv);
    [pool release];
    return ret;
}