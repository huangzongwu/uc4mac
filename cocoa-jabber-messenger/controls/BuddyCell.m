//
//  BuddyCell.m
//  Ta
//
//  Created by Sangeun Kim on 3/25/11.
//  Copyright 2011 NHN Corporation. All rights reserved.
//

#import "BuddyCell.h"

@implementation BuddyCell
@synthesize subTitle;
@synthesize title;

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

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSImage *gradient;
    /* Determine whether we should draw a blue or grey gradient. */
    /* We will automatically redraw when our parent view loses/gains focus, 
     or when our parent window loses/gains main/key status. */
    if (([[controlView window] firstResponder] == controlView) && 
        [[controlView window] isMainWindow] &&
        [[controlView window] isKeyWindow]) {
        gradient = [NSImage imageNamed:@"highlight_blue.tiff"];
    } else {
        gradient = [NSImage imageNamed:@"highlight_grey.tiff"];
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
    NSInteger titleSize = 12;
    NSInteger subtitleSize = 11;
	NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment:NSLeftTextAlignment];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	//	float fontSize = 5;//[NSFont systemFontSizeForControlSize:NSMiniControlSize],//
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [self isHighlighted]?[NSColor whiteColor]:[NSColor blackColor], NSForegroundColorAttributeName, 
						   [NSFont userFontOfSize:titleSize], 
						   NSFontAttributeName, 
						   paragraphStyle, NSParagraphStyleAttributeName, nil];
    NSRect titleRect = cellFrame;
    if (subTitle) {
        titleRect.size.height /=2;
        NSRect subtitleRect = titleRect;
        subtitleRect.origin.y += titleRect.size.height;
        subtitleRect.origin.y += (subtitleRect.size.height-subtitleSize)/2-4;
        subtitleRect.size.height = subtitleSize+2;
        subtitleRect.origin.x += 5;
        subtitleRect.size.width -= 8;
        
        NSDictionary *subtitleAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [self isHighlighted]?[NSColor lightGrayColor]:[NSColor grayColor], 
                                       NSForegroundColorAttributeName, 
                                       [NSFont userFontOfSize:subtitleSize], 
                                       NSFontAttributeName, 
                                       paragraphStyle, NSParagraphStyleAttributeName, nil];
        NSMutableAttributedString* attributedSubtitle = [[NSMutableAttributedString alloc] initWithString:subTitle attributes:subtitleAttrs];
        [attributedSubtitle drawInRect:subtitleRect];
        [attributedSubtitle release];
    }
    [paragraphStyle release];
    titleRect.origin.y += (titleRect.size.height-titleSize)/2+2;
    titleRect.size.height = titleSize+8;
    titleRect.origin.x += 5;
    titleRect.size.width -= 8;
    NSMutableAttributedString* attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:attrs];
    [attributedTitle drawInRect:titleRect];
    [attributedTitle release];
}

@end
