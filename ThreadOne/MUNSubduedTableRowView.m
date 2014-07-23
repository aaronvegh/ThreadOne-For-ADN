//
//  MUNSubduedTableRowView.m
//  Munenori
//
//  Created by Aaron Vegh on 2013-08-14.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNSubduedTableRowView.h"
#import "MUNThemeManager.h"

@implementation MUNSubduedTableRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        [[[MUNThemeManager sharedManager] highToneColor] setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:self.bounds];
        [selectionPath fill];
        
        [[[MUNThemeManager sharedManager] highlightColor] setFill];
        NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 5, self.bounds.size.height)];
        [highlightPath fill];
    }
}

- (void)drawSeparatorInRect:(NSRect)dirtyRect
{
    [[[MUNThemeManager sharedManager] highToneDividerColor] setFill];
    NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRect:NSMakeRect(self.bounds.origin.x + 10, self.bounds.size.height - 1, self.bounds.size.width - 20, 1)];
    [highlightPath fill];
}

@end
