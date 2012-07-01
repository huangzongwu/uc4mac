//
//  ChatHistoryViewController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-2-26.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "ChatHistoryViewController.h"
#import "MessageItem.h"
#import "RowResizableTableView.h"
#import "ChatTextFieldCell.h"
#import "XMPP.h"

@implementation ChatHistoryViewController
@synthesize xmpp;
@synthesize currentPage;
@synthesize jid;

- (id) initWithNibName:(NSString*) nibNameOrNil bundle:(NSBundle*) nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }    
    return self;
}

- (void) awakeFromNib
{
    [historyList setTarget:self]; 
    [historyList setDataSource:self];
    [historyList setDelegate:self];
    [historyList setDoubleAction:@selector(onDoubleClick:)];
    [historyList setIntercellSpacing:NSMakeSize(0,0)];
    [historyList setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    history = [[NSMutableArray alloc] init];
}

- (void) dealloc
{
    [history release];
}

- (void) showHistory:(NSInteger) page
{
    [historyList deselectRow:[historyList selectedRow]];
    NSArray* chatHistory = [[NSArray alloc] initWithArray:[MessageItem findByCriteria:[NSString stringWithFormat:@"WHERE jid='%@' ORDER BY time_stamp DESC LIMIT 10 OFFSET %d", jid, page*10]]];
    if ([chatHistory count] > 0) {
        [history removeAllObjects];
        currentPage = page;
        for (MessageItem* item in chatHistory) {
            [history addObject:item];
            [historyList reloadData];
        }
    }
    [chatHistory release];
}

- (IBAction) back:(id) sender
{
    if (currentPage > 0) {
        [self showHistory:(currentPage-1)];
    }
}

- (IBAction) forward:(id) sender
{
    [self showHistory:(currentPage+1)];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *) aTableView
{
	return [history count];
}

- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(NSInteger) rowIndex
{
    if ([history count] == 0) {
        return nil;
    }
	MessageItem* item = [history objectAtIndex:rowIndex];
	if ([[aTableColumn identifier] isEqualToString:@"ProfileImage"]) {
		if ([[item name] isEqualToString:@"我"]) {
			return nil;
		} else {
			return targetImage;
		}
	}
    else if ([[aTableColumn identifier] isEqualToString:@"MyImage"]) {
		if ([[item name] isEqualToString:@"我"]) {
			return [[xmpp myVcard] valueForKey:@"image"];
		} else {
			return nil;
		}
    }
	if ([[aTableColumn identifier] isEqualToString:@"TextMessage"]) {
        [[aTableColumn dataCell] setLeftArrow:![[item name] isEqualToString:@"我"]];
        /*if ([[item image] length] > 0) {
            [[aTableColumn dataCell] setMessageImage:[item image]];
        }*/
        if ([item timeStamp]) {
            [[aTableColumn dataCell]
             setMessageTime:[item timeStamp]];
        }
		if (rowIndex == [aTableView selectedRow]) {
			[[aTableColumn dataCell] setSelected:YES];
		} else {
			[[aTableColumn dataCell] setSelected:NO];
		}
		return [item message];
	}
	return @"";
}

- (IBAction) onDoubleClick:(id) sender
{
    //NSText *textEditor;
    NSInteger index = [sender selectedRow];
    [sender editColumn:1 row:index withEvent:nil select:YES];
}

- (void) tableView:(NSTableView *) aTableView willDisplayCell:(id) aCell forTableColumn:(NSTableColumn *) aTableColumn row:(NSInteger) rowIndex
{
    if (![aCell isKindOfClass:[ChatTextFieldCell class]]) {
        return;
    }
}


@end
