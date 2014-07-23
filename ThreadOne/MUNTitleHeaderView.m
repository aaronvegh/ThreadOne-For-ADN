//
//  MUNTitleHeaderView.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-09-11.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNTitleHeaderView.h"
#import "MUNThemeManager.h"

@implementation MUNTitleHeaderView

- (void)awakeFromNib {

    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor clearColor] CGColor];
    
    self.chatsButton.image = [NSImage imageNamed:[[MUNThemeManager sharedManager] chatsButtonName]];
    self.makeNewChatButton.image = [NSImage imageNamed:[[MUNThemeManager sharedManager] brandNewChatButtonName]];
    
    self.chatsButtonName.textColor = [[MUNThemeManager sharedManager] bodyTextColor];
    self.makeNewChatButtonName.textColor = [[MUNThemeManager sharedManager] bodyTextColor];
}

- (void)mouseDown:(NSEvent *)mouseEvent

{
    mouseStart = [mouseEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)mouseEvent

{
    NSPoint mousePoint = [mouseEvent locationInWindow];
    
    NSPoint dragDistance = NSMakePoint(mousePoint.x - mouseStart.x, mousePoint.y - mouseStart.y);
    
    NSPoint origin = [[self window] frame].origin;
    
    origin.x = origin.x + dragDistance.x;
    
    origin.y = origin.y + dragDistance.y;
    
    [[self window] setFrame:NSMakeRect(origin.x, origin.y, self.window.frame.size.width, self.window.frame.size.height) display:NO];
    
}


// Redraw the close button when the main window status changes.
//
- (void)mainWindowChanged
{
	[closeButton setNeedsDisplay];
    [minitiarizeButton setNeedsDisplay];
    [zoomButton setNeedsDisplay];
}


@end
