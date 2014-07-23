//
//  MUNChannelTableView.m
//  Munenori
//
//  Created by Aaron Vegh on 2013-08-16.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNChannelTableView.h"
#import "MUNThemeManager.h"

@implementation MUNChannelTableView


- (void)awakeFromNib
{
    self.backgroundColor = [[MUNThemeManager sharedManager] windowBackgroundColor];
    [self setDoubleAction:@selector(doubleClickRow)];
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent keyCode] == 124) { // right arrow to expand the window, if not already
        [self.tableDelegate openChannelCommand];
    }
    else {
        [super keyDown:theEvent];
    }
}

- (void)doubleClickRow
{
    [self.tableDelegate openChannelCommand];
}

- (void)drawGridInClipRect:(NSRect)clipRect
{
    NSRect lastRowRect = [self rectOfRow:[self numberOfRows]-1];
    NSRect myClipRect = NSMakeRect(0, 0, lastRowRect.size.width, NSMaxY(lastRowRect));
    NSRect finalClipRect = NSIntersectionRect(clipRect, myClipRect);
    [super drawGridInClipRect:finalClipRect];
}

@end
