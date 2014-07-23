//
//  MUNComposeViewTextFieldCell.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-10-03.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNComposeViewTextFieldCell.h"

#define PADDING_MARGIN 5

@implementation MUNComposeViewTextFieldCell

- (NSRect)titleRectForBounds:(NSRect)theRect

{
    
    NSRect titleFrame = [super titleRectForBounds:theRect];
    
    //Padding on left side
    titleFrame.origin.x = PADDING_MARGIN;
    
    //Padding on right side
    titleFrame.size.width -= (2 * PADDING_MARGIN);
    
    // Padding on top
    titleFrame.origin.y = theRect.size.height - PADDING_MARGIN;
    
    return titleFrame;
    
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent

{
    
    NSRect textFrame = aRect;
    
    textFrame.origin.x += PADDING_MARGIN;
    
    textFrame.size.width -= (2* PADDING_MARGIN);
    
    textFrame.origin.y = aRect.size.height - PADDING_MARGIN;
    
    [super editWithFrame: textFrame inView: controlView editor:textObj delegate:anObject event: theEvent];
    
}



//Any padding implemented in this function will be visible while selecting text in textfieldcell

//If Padding is not done here, padding done for title will not be visible while selecting text



- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength

{
    
    NSRect textFrame = aRect;
    
    textFrame.origin.x += PADDING_MARGIN;
    
    textFrame.size.width -= (2* PADDING_MARGIN);
    
    textFrame.origin.y = PADDING_MARGIN;
    
    [super selectWithFrame: textFrame inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
    
}



- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView

{
    
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    
    [[self attributedStringValue] drawInRect:titleRect];
    
}

@end
