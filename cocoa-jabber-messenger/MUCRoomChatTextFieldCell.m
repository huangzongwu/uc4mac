//
//  MUCRoomChatTextFieldCell.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-4.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomChatTextFieldCell.h"

@implementation MUCRoomChatTextFieldCell 
@synthesize sender;

- (NSAttributedString*) attributedNameString:(NSString*)name
{    
    NSMutableParagraphStyle* paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy]autorelease];
    [paragraphStyle setAlignment:NSLeftTextAlignment];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor darkGrayColor], 
                           NSForegroundColorAttributeName, 
                           [NSFont userFontOfSize:10], 
                           NSFontAttributeName, 
                           paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    return [[[NSAttributedString alloc] initWithString:name attributes:attrs] autorelease];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    
    BOOL isFocused = NO;
    
    if (([[controlView window] firstResponder] == controlView) && 
        [[controlView window] isMainWindow] &&
        [[controlView window] isKeyWindow]) {
        isFocused = YES;
    } else {
        isFocused = NO;
    }
    
    NSAttributedString* name = [self attributedNameString:sender];
    NSAttributedString* timeStamp = [self attributedTimeStampStringFromDate:messageTime];
    NSRect nameRect = [name boundingRectWithSize:NSMakeSize(1000, 1000) options:0];
    NSRect timeStampRect = [timeStamp boundingRectWithSize:NSMakeSize(1000, 1000) options:0];
    NSRect textRect = [self textRectFromCellFrame:cellFrame withMinimumWidth:100];
    
    NSRect bpRect = textRect;
    bpRect.origin.y += 5;
    bpRect.size.width += 10;
    bpRect.size.height -= 10;

    if (leftArrow) {
        bpRect.origin.x -= 10;
    }
    [self drawRect:bpRect withIsKeyWindow:isFocused];
    
    timeStampRect = textRect;
    timeStampRect.origin.y += (timeStampRect.size.height-15);
    timeStampRect.size.width -= 10;
    [timeStamp drawInRect:timeStampRect];
    
    nameRect = textRect;
    nameRect.origin.y = (nameRect.origin.y+2);
    [name drawInRect:nameRect];
    
    [super drawInteriorWithFrame:textRect inView:controlView];
}

@end
