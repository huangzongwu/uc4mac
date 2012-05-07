//
//  BuddyImageCell.m
//  Ta
//
//  Created by Sangeun Kim on 4/5/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "BuddyImageCell.h"


@implementation BuddyImageCell

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
//    BOOL isFocused = NO;
    NSImage *gradient;
    /* Determine whether we should draw a blue or grey gradient. */
    /* We will automatically redraw when our parent view loses/gains focus, 
     or when our parent window loses/gains main/key status. */
    if (([[controlView window] firstResponder] == controlView) && 
        [[controlView window] isMainWindow] &&
        [[controlView window] isKeyWindow]) {
        gradient = [NSImage imageNamed:@"highlight_blue.tiff"];
//        isFocused = YES;
    } else {
        gradient = [NSImage imageNamed:@"highlight_grey.tiff"];
//        isFocused = NO;
    }
    
    /* Make sure we draw the gradient the correct way up. */
    [gradient setFlipped:YES];
    int i = 0;
    
    if ([self isHighlighted]) {
        //[controlView lockFocus];
        
        /* We're selected, so draw the gradient background. */
        NSSize gradientSize = [gradient size];
        for (i = cellFrame.origin.x; i < (cellFrame.origin.x + cellFrame.size.width); i += gradientSize.width) {
            [gradient drawInRect:NSMakeRect(i, cellFrame.origin.y, gradientSize.width, cellFrame.size.height)
                        fromRect:NSMakeRect(0, 0, gradientSize.width, gradientSize.height)
                       operation:NSCompositeSourceOver
                        fraction:1.0];
        }
        
        //[controlView unlockFocus];
    } 
    
    cellFrame.origin.x += 5;
    cellFrame.origin.y += 5;
    cellFrame.size.width -= 10;
    cellFrame.size.height -= 10;
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}
@end
