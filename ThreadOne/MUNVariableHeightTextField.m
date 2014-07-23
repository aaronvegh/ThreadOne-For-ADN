//
//  MUNVariableHeightTextField.m
//  Munenori
//
//  Created by Aaron Vegh on 2013-08-13.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNVariableHeightTextField.h"

@implementation MUNVariableHeightTextField


-(NSSize)intrinsicContentSize
{
    if ( ![self.cell wraps] ) {
        return [super intrinsicContentSize];
    }
    
    NSRect frame = [self frame];
    
    CGFloat width = frame.size.width;
    
    // Make the frame very high, while keeping the width
    frame.size.height = CGFLOAT_MAX;
    
    // Calculate new height within the frame
    // with practically infinite height.
    CGFloat height = [self.cell cellSizeForBounds: frame].height;
    
    return NSMakeSize(width, height);
}

@end
