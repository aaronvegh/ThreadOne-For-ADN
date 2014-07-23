//
//  INOMessageTableView.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-09.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOMessageTableView.h"

@implementation INOMessageTableView

- (void)setFrameSize:(NSSize)newSize {
    newSize.height += 5;
    [super setFrameSize:newSize];
}

@end
