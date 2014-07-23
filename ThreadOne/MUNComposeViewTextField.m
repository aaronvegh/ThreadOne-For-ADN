//
//  MUNComposeViewTextField.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-10-02.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNComposeViewTextField.h"

@implementation MUNComposeViewTextField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    [[self cell] setBezelStyle: NSTextFieldRoundedBezel];
    self.delegate = self;
    self.currentEditor.minSize = NSMakeSize(self.bounds.size.width, CGFLOAT_MAX);
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    NSRect blackOutlineFrame = NSMakeRect(0.5, 0.5, [self bounds].size.width - 1, [self bounds].size.height - 1);
    NSBezierPath * fieldPath = [NSBezierPath bezierPathWithRoundedRect:blackOutlineFrame xRadius:2 yRadius:2];
    
    [[NSColor colorWithCalibratedRed:0.596 green:0.596 blue:0.596 alpha:1] set];
    [fieldPath stroke];
    
    [[NSColor whiteColor] set];
    [fieldPath fill];
        
}



@end
