//
//  BaseChatTextFiledCell.h
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-4.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface BaseChatTextFiledCell : NSTextFieldCell {
    BOOL                leftArrow;
	NSDate*             messageTime;
    NSMutableArray*     images;
    BOOL                imageloaded;
    @protected
    void (^_linkClickedHandler)(NSURL *url, id sender);
}

@property (nonatomic, copy) NSDate* messageTime;
@property (nonatomic, retain) NSMutableArray* images;
@property (assign) BOOL leftArrow;
@property (assign) BOOL selected;
@property (copy) void (^linkClickedHandler)(NSURL * url, id sender);

- (NSRect) textRectFromCellFrame:(NSRect) cellFrame withMinimumWidth:(NSInteger) minimumWidth;
- (NSAttributedString*) attributedTimeStampStringFromDate:(NSDate*) date;
- (void) drawRect:(NSRect) rect withIsKeyWindow:(BOOL) isKeyWindow;

@end
