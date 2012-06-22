//
//  BaseChatTextFiledCell.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-4.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "BaseChatTextFiledCell.h"
#import "RowResizableTableView.h"
#import "RegexKitLite.h"

const NSInteger CORNER_RADIUS = 5;
const NSInteger ARROW_TOP = 10;
const NSInteger ARROW_WIDTH = 10;
const NSInteger ARROW_HEIGHT = 10;

@implementation BaseChatTextFiledCell
@synthesize leftArrow;
@synthesize images;
@synthesize messageTime;
@synthesize selected;
//@synthesize backgroundColor;
@synthesize linkClickedHandler = _linkClickedHandler;

- (id) init {
	[super init];
    //	_cFlags.vCentered = 1;
    selected = NO;
	leftArrow = YES;
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
    BaseChatTextFiledCell *result = [super copyWithZone:zone];
    result->_linkClickedHandler = [_linkClickedHandler copy];
    result->messageTime = [messageTime copy];
    return result;
}

- (void)dealloc {
    [_linkClickedHandler release];
    [super dealloc];
}

// Our cell wants to work like a button, and wants to keep tracking until the mouse is released up
+ (BOOL)prefersTrackingUntilMouseUp {
    return YES;
}

- (NSRect) textRectFromCellFrame:(NSRect) cellFrame withMinimumWidth:(NSInteger) minimumWidth
{
	NSRect textRect = cellFrame;
	if (leftArrow) {
		textRect.origin.x+=5;
	} else {
		textRect.origin.x-=15;
	}
    NSSize requiredSize = [self cellSizeForBounds:textRect];
    NSInteger requiredWidth = (requiredSize.width+5 > minimumWidth) ? requiredSize.width+5 : minimumWidth;
    if (textRect.size.width > requiredWidth) {
        if (!leftArrow) {
            textRect.origin.x += (textRect.size.width - requiredWidth);
        }
        textRect.size.width = requiredWidth;
    }
    return textRect;
}

// Text cells in NSTableView's normally don't "track the mouse", since they don't resond to clicks. 
// Wait! What about editing? Well, that is done via the NSFieldEditor which handles the clicks/selection/etc.
- (NSUInteger) hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
    NSUInteger hitTestResult = [super hitTestForEvent:event 
                                               inRect:[self textRectFromCellFrame:cellFrame withMinimumWidth:0] ofView:controlView];
    // If we hit on content (ie: text, and not whitespace), then we go ahead and say we want to track
    if ((hitTestResult & NSCellHitContentArea) != 0) {
        hitTestResult |= NSCellHitTrackableArea;
    }
    return hitTestResult;
}

// Factor link click handling into own method - used by tracking and accessibility
- (void)_handleLinkClick {
    NSAttributedString *attrValue = [self attributedStringValue];
    NSURL *link = [attrValue attribute:NSLinkAttributeName atIndex:0 effectiveRange:NULL];
    if (link != nil && _linkClickedHandler != nil) {
        // We do have a link -- open it!
        _linkClickedHandler(link, self);
    }
    else if (link)
    {
        [[NSWorkspace sharedWorkspace]openURL:link];
    }
}

// Override tracking to handle the link click -- while we are tracking we change the link text color to something different to let the user have some feedback that they are clicking on something.
// Ideally we want to override stopTracking:at:inView:mouseIsUp:, but we also need to know the cellFrame to find out if the user clicked on the content or not.
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
    BOOL result = YES;
    // Did we click on the text? We will use the hit testing routine to see if we hit content -- for text cells, that means the text.
    NSUInteger hitTestResult = [self hitTestForEvent:theEvent inRect:cellFrame ofView:controlView];
    if ((hitTestResult & NSCellHitContentArea) != 0) {
        // Give the user some feedback by changing the text color
        //        [self _setAttributedStringTextColor:[NSColor redColor]];
        // Do the tracking until mouse up
        result = [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];
        // Now we grab the latest event, in case the user moved the mouse in the normal tracking loop, and hit test again
        theEvent = [NSApp currentEvent];
        hitTestResult = [self hitTestForEvent:theEvent inRect:cellFrame ofView:controlView];
        if ((hitTestResult & NSCellHitContentArea) != 0) {
            [self _handleLinkClick];
        }
    }
    return result;
}


#pragma mark -
#pragma mark Accessibility support

// Add an AXPress action to list of actions we support, when asked to perform, handle the link click.

- (NSArray*) accessibilityActionNames {
    return [[super accessibilityActionNames] arrayByAddingObject:NSAccessibilityPressAction];
}

- (void) accessibilityPerformAction:(NSString *)action {
    if ([action isEqualToString:NSAccessibilityPressAction]) {
        [self _handleLinkClick];
    } else {
        [super accessibilityPerformAction:action];
    }
}

- (NSBezierPath*) bezierPathWithRect:(NSRect) rect
{
	NSBezierPath *bp = [NSBezierPath bezierPath];
	float leftOX = rect.origin.x; 
	float leftX = leftOX;
	float rightX = leftOX + rect.size.width - ARROW_WIDTH;
	if (leftArrow) {
		leftX = leftOX + ARROW_WIDTH;
		rightX = leftOX + rect.size.width;
	}
	float bottomY = rect.origin.y;
	float topY = bottomY + rect.size.height;
	
	NSPoint startingPoint = NSMakePoint(leftX + ARROW_WIDTH, topY);
	[bp moveToPoint:startingPoint];
	NSPoint cp;
	// top right corner
	[bp lineToPoint:NSMakePoint(rightX-CORNER_RADIUS, topY)];
	cp = NSMakePoint(rightX, topY);
	[bp curveToPoint:NSMakePoint(rightX,  topY - CORNER_RADIUS)
	   controlPoint1:cp
	   controlPoint2:cp];
    // arrow
	if (!leftArrow) {
		[bp lineToPoint:NSMakePoint(rightX, topY-ARROW_HEIGHT-ARROW_TOP)];
		[bp lineToPoint:NSMakePoint(rightX+ARROW_WIDTH, topY-ARROW_HEIGHT/2-ARROW_TOP)];
		[bp lineToPoint:NSMakePoint(rightX, topY-ARROW_TOP)];
	}
	// bottom right corner
	[bp lineToPoint:NSMakePoint(rightX, bottomY + CORNER_RADIUS)];
	cp = NSMakePoint(rightX, bottomY);
	[bp curveToPoint:NSMakePoint(rightX - CORNER_RADIUS, bottomY)
	   controlPoint1:cp
	   controlPoint2:cp];
	// bottom left corner
	[bp lineToPoint:NSMakePoint(leftX + CORNER_RADIUS, bottomY)];
	cp = NSMakePoint(leftX, bottomY);
	[bp curveToPoint:NSMakePoint(leftX, bottomY + CORNER_RADIUS)
	   controlPoint1:cp
	   controlPoint2:cp];
	// arrow
	if (leftArrow) {
		[bp lineToPoint:NSMakePoint(leftX, topY-ARROW_HEIGHT-ARROW_TOP)];
		[bp lineToPoint:NSMakePoint(leftOX, topY-ARROW_HEIGHT/2-ARROW_TOP)];
		[bp lineToPoint:NSMakePoint(leftX, topY-ARROW_TOP)];
	}
	// top left corner
	[bp lineToPoint:NSMakePoint(leftX, topY - CORNER_RADIUS)];
	cp = NSMakePoint(leftX, topY);
	[bp curveToPoint:startingPoint
	   controlPoint1:cp
	   controlPoint2:cp];
	
	[bp closePath];
	[bp setLineJoinStyle:NSRoundLineJoinStyle];
	return bp;
}

- (void) drawRect:(NSRect) rect withIsKeyWindow:(BOOL) isKeyWindow {
	//NSBezierPath *bp = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:2 yRadius:2];
    NSBezierPath* bp = [self bezierPathWithRect:rect];
	if (selected) {
		if ([NSApp isActive] && isKeyWindow)
			[[NSColor colorWithCalibratedRed:0.22 green:0.46 blue:0.84 alpha:1.00] set];
		else
			[[NSColor darkGrayColor] set];
		[bp setLineWidth:4.0];
		[bp stroke];
	} else {
		[NSGraphicsContext saveGraphicsState]; 
		NSShadow* theShadow = [[NSShadow alloc] init];
		[theShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
		[theShadow setShadowBlurRadius:2.0];
		[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
		[theShadow set]; 
		[[NSColor colorWithDeviceRed:0.69 green:0.77 blue:0.70 alpha:1.00] set];
		[bp setLineWidth:1.0];
		[bp stroke];
		[NSGraphicsContext restoreGraphicsState];
		[theShadow release];
	}
    
	NSColor *startingColor;
	NSColor *endingColor;
    if (leftArrow) {
		startingColor = [NSColor colorWithCalibratedRed:0.82 green:0.82 blue:0.89 alpha:1.00];
		endingColor = [NSColor colorWithCalibratedRed:0.76 green:0.76 blue:0.86 alpha:1.00];
    }
	else {
		startingColor = [NSColor colorWithCalibratedRed:0.81 green:0.87 blue:0.89 alpha:1.00];
		endingColor = [NSColor colorWithCalibratedRed:0.72 green:0.78 blue:0.80 alpha:1.00];
	}
    
	NSGradient *grd = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:endingColor];
	[grd drawInBezierPath:bp angle:-90];
	[grd release];
}

- (NSAttributedString*) attributedTimeStampStringFromDate:(NSDate*)date
{
    NSDateFormatter *df;
	NSString* strTimeStamp;
    
    if (time) {
        df =  [[NSDateFormatter alloc] init];
        NSDate* now = [NSDate date];
        NSString* strToday = [now descriptionWithCalendarFormat: @"%Y %m %d" timeZone: nil locale: nil];
        NSString* strTheday = [date descriptionWithCalendarFormat: @"%Y %m %d" timeZone: nil locale: nil];
        
        BOOL isToday = NO;
        if ([strToday isEqualToString:strTheday]) {
            [df setDateFormat:@"h:mm a"];
            isToday = YES;
        } else {
            [df setDateFormat:@"YYYY-M-d  h:mm a"];
        }
        
        strTimeStamp = [NSString stringWithFormat:@"%@%@", 
                        isToday?@"今天 ":@"",
                        [df stringFromDate:date]];
        [df release];
    } else {
        strTimeStamp = [NSString stringWithString: @"发送中..." ];
    }
    
    NSMutableParagraphStyle* paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [paragraphStyle setAlignment:NSRightTextAlignment];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSColor grayColor], 
                           NSForegroundColorAttributeName, 
                           [NSFont userFontOfSize:9], 
                           NSFontAttributeName, 
                           paragraphStyle, 
                           NSParagraphStyleAttributeName, 
                           nil];
    
    return [[[NSAttributedString alloc] initWithString:strTimeStamp attributes:attrs] autorelease];
}

- (void) drawInteriorWithFrame:(NSRect) cellFrame inView:(NSView*) controlView {
    NSRect textRect = [self titleRectForBounds:cellFrame];
    
    if (images && [[self stringValue] hasSuffix:[images objectAtIndex:0]]) {
        NSRect imageRect = textRect;
        NSTextAttachment *attachment;  
        attachment = [[[NSTextAttachment alloc] init] autorelease];  
        NSImage *img = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/tmp/%@", [images objectAtIndex:0]]]; // or wherever you are 
        [(NSCell*)[attachment attachmentCell] setImage:img];
        NSMutableAttributedString *imgAttrStr;  
        imgAttrStr = (id) [NSMutableAttributedString attributedStringWithAttachment:  
                          attachment];  
        imageRect.origin.y += (textRect.size.height-img.size.height-30);

        [imgAttrStr drawInRect:imageRect];
        [img release];
    }
    [[self attributedStringValue] drawInRect:textRect];

}

- (NSSize) cellSizeForBounds:(NSRect) aRect
{
    NSSize textSize = [super cellSizeForBounds:aRect];
    if (images && [[self stringValue] hasSuffix:[images objectAtIndex:0]]) {
        NSImage *img = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/tmp/%@", [images objectAtIndex:0]]];
        CGFloat w = textSize.width > img.size.width ? textSize.width : img.size.width;
        return NSMakeSize(w, textSize.height+img.size.height);
    } else {
        return NSMakeSize(textSize.width, textSize.height);
    }
}

- (NSRect) titleRectForBounds:(NSRect) theRect 
{
    NSRect titleFrame = [super titleRectForBounds:theRect];
    if (leftArrow) {
        titleFrame.origin.x += 15;
    } else {
        titleFrame.origin.x += 5;
    }
    titleFrame.origin.y += 15;
    return titleFrame;
}

- (void) editWithFrame:(NSRect) aRect inView:(NSView*) controlView editor:(NSText*) textObj delegate:(id)anObject event:(NSEvent*) theEvent
{
	NSRect textRect = [self textRectFromCellFrame:aRect withMinimumWidth:100];
    if (leftArrow) {
        textRect.origin.x += 13;
    } else {
        textRect.origin.x += 3;
    }    
    textRect.origin.y += 15;
    [super editWithFrame:textRect inView:controlView editor:textObj delegate:anObject event:theEvent];
    [textObj setDrawsBackground:NO];    
}

- (void) selectWithFrame:(NSRect) aRect inView:(NSView*) controlView editor:(NSText*) textObj delegate:(id) anObject start:(NSInteger) selStart length:(NSInteger) selLength
{
	NSRect textRect = [self textRectFromCellFrame:aRect withMinimumWidth:100];
    if (leftArrow) {
        textRect.origin.x += 13;
    } else {
        textRect.origin.x += 3;
    }    
    textRect.origin.y += 15;
    [super selectWithFrame:textRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
    [textObj setDrawsBackground:NO];
}

@end
