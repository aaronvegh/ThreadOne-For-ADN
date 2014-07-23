//
//  MUNComposeView.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-10-02.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNComposeView.h"
#import "MUNThemeManager.h"

@implementation MUNComposeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    NSColor *startingColor = [[MUNThemeManager sharedManager] titleBarStartColor];
    NSColor *endingColor = [[MUNThemeManager sharedManager] titleBarEndColor];
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:startingColor
                             endingColor:endingColor];
    [aGradient drawInRect:[self bounds] angle:270];
    
    NSBezierPath * topBorderPath = [NSBezierPath bezierPathWithRect:NSMakeRect(0, dirtyRect.size.height - 0.5, dirtyRect.size.width, 0.5)];
    [[NSColor colorWithCalibratedRed:0.675 green:0.675 blue:0.675 alpha:1] set];
    [topBorderPath fill];
    
    NSBezierPath * nextTopBorderPath = [NSBezierPath bezierPathWithRect:NSMakeRect(0, dirtyRect.size.height - 1, dirtyRect.size.width, 0.5)];
    [[NSColor whiteColor] set];
    [nextTopBorderPath fill];
}



@end
