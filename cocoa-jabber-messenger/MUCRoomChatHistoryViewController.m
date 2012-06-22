//
//  MUCRoomChatHistoryViewController.m
//  cocoa-jabber-messenger
//
//  Created by 硕实 陈 on 12-3-1.
//  Copyright (c) 2012年 NHN Corporation. All rights reserved.
//

#import "MUCRoomChatHistoryViewController.h"
#import "MUCRoomMessageItem.h"
#import "RowResizableTableView.h"
#import "MUCRoomChatTextFieldCell.h"

@implementation MUCRoomChatHistoryViewController
@synthesize currentPage;
@synthesize jid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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

- (void) showRoomHistory:(NSInteger) page
{
    [historyList deselectRow:[historyList selectedRow]];
    NSArray* chatHistory = [[NSArray alloc] initWithArray:[MUCRoomMessageItem findByCriteria:[NSString stringWithFormat:@"WHERE room_jid='%@' ORDER BY time_stamp DESC LIMIT 10 OFFSET %d", jid, page*10]]];
    if ([chatHistory count] > 0) {
        [history removeAllObjects];
        currentPage = page;
        for (MUCRoomMessageItem* item in chatHistory) {
            [history addObject:item];
            [historyList reloadData];
        }
    }
    [chatHistory release];   
}

- (IBAction) roomBack:(id) sender
{
    if (currentPage > 0) {
        [self showRoomHistory:(currentPage-1)];
    }
}

- (IBAction) roomForward:(id) sender
{
    [self showRoomHistory:(currentPage+1)];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *) aTableView
{
	return [history count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	MUCRoomMessageItem* item = [history objectAtIndex:rowIndex];
	if ([[aTableColumn identifier]isEqualToString:@"ProfileImage"]) {
        return nil;
	} else if ([[aTableColumn identifier]isEqualToString:@"MyImage"]) {
        return nil;
    } else if ([[aTableColumn identifier]isEqualToString:@"TextMessage"]) {
        [[aTableColumn dataCell] setLeftArrow:![[item name] isEqualToString:@"我"]];
        [[aTableColumn dataCell] setSender:[item name]];
        if ([item timeStamp]) {
            [[aTableColumn dataCell] setMessageTime:[item timeStamp]];
        }
		if (rowIndex == [aTableView selectedRow]) {
			[[aTableColumn dataCell] setSelected:YES];
		}
		else {
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

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if (![aCell isKindOfClass:[MUCRoomChatTextFieldCell class]])
    {
        return;
    }
}

@end
