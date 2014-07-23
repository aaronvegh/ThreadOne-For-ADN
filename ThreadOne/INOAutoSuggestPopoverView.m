//
//  INOAutoSuggestPopoverView.m
//  INOTokenMaker
//
//  Created by Aaron Vegh on 10/22/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "INOAutoSuggestPopoverView.h"

#define NLPOPOVER_CORNER_RADIUS 5.0
#define NLPOPOVER_ARROW_HEIGHT 15.0
#define NLPOPOVER_ARROW_WIDTH 15.0


@implementation INOAutoSuggestPopoverView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.arrowDirection = NSMaxYEdge;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[self setNeedsDisplay:YES];
    
    NSBezierPath * windowPath = [self _popoverBezierPathWithRect:dirtyRect];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow setShadowBlurRadius:2.0f];
    [shadow setShadowOffset:NSMakeSize(0.f, 0.f)];
    [shadow set];
    
    [[NSColor whiteColor] setFill];
    [windowPath fill];
}

// Totally ripped this off from Zach Thayer:
// https://github.com/Nub/NLPopover/blob/master/NLPopoverFrame.m

- (NSBezierPath*)_popoverBezierPathWithRect:(NSRect)aRect
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    CGFloat radius = NLPOPOVER_CORNER_RADIUS;
    CGFloat inset = radius + NLPOPOVER_ARROW_HEIGHT;
    NSRect drawingRect = NSInsetRect(aRect, inset, inset);
    CGFloat minX = NSMinX(drawingRect);
    CGFloat maxX = NSMaxX(drawingRect);
    CGFloat minY = NSMinY(drawingRect);
    CGFloat maxY = NSMaxY(drawingRect);
    
    // Bottom left corner
    [path appendBezierPathWithArcWithCenter:NSMakePoint(minX, minY) radius:radius startAngle:180.0 endAngle:270.0];
    
    if (self.arrowDirection == NSMinYEdge) {
        CGFloat midX = NSMidX(drawingRect);
        NSPoint points[3];
        // Starting point
        points[0] = NSMakePoint(floor(midX - (NLPOPOVER_ARROW_WIDTH / 2.0)), minY - radius);
        // Arrow tip
        points[1] = NSMakePoint(floor(midX), points[0].y - NLPOPOVER_ARROW_HEIGHT + 1);
        // Ending point
        points[2] = NSMakePoint(floor(midX + (NLPOPOVER_ARROW_WIDTH / 2.0)), points[0].y);
        [path appendBezierPathWithPoints:points count:3];
    }
    // Bottom right corner
    [path appendBezierPathWithArcWithCenter:NSMakePoint(maxX, minY) radius:radius startAngle:270.0 endAngle:360.0];
    
    if (self.arrowDirection == NSMaxXEdge) {
        CGFloat midY = NSMidY(drawingRect);
        NSPoint points[3];
        points[0] = NSMakePoint(maxX + radius, floor(midY - (NLPOPOVER_ARROW_WIDTH / 2.0)));
        points[1] = NSMakePoint(points[0].x + NLPOPOVER_ARROW_HEIGHT, floor(midY));
        points[2] = NSMakePoint(points[0].x, floor(midY + (NLPOPOVER_ARROW_WIDTH / 2.0)));
        [path appendBezierPathWithPoints:points count:3];
    }
    // Top right corner
    [path appendBezierPathWithArcWithCenter:NSMakePoint(maxX, maxY) radius:radius startAngle:0.0 endAngle:90.0];
    
    if (self.arrowDirection == NSMaxYEdge) {
        CGFloat midX = NSMidX(drawingRect);
        NSPoint points[3];
        points[0] = NSMakePoint(floor(midX + (NLPOPOVER_ARROW_WIDTH / 2.0)), maxY + radius);
        points[1] = NSMakePoint(floor(midX), points[0].y + NLPOPOVER_ARROW_HEIGHT - 1);
        points[2] = NSMakePoint(floor(midX - (NLPOPOVER_ARROW_WIDTH / 2.0)), points[0].y);
        [path appendBezierPathWithPoints:points count:3];
    }
    // Top left corner
    [path appendBezierPathWithArcWithCenter:NSMakePoint(minX, maxY) radius:radius startAngle:90.0 endAngle:180.0];
    
    if (self.arrowDirection == NSMinXEdge) {
        CGFloat midY = NSMidY(drawingRect);
        NSPoint points[3];
        points[0] = NSMakePoint(minX - radius, floor(midY + (NLPOPOVER_ARROW_WIDTH / 2.0)));
        points[1] = NSMakePoint(points[0].x - NLPOPOVER_ARROW_HEIGHT, floor(midY));
        points[2] = NSMakePoint(points[0].x, floor(midY - (NLPOPOVER_ARROW_WIDTH / 2.0)));
        [path appendBezierPathWithPoints:points count:3];
    }
    [path closePath];
    return path;
}

@end
