//
//  MUNAttachmentView.m
//  ThreadOne
//
//  Created by Aaron Vegh on 12/5/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNAttachmentView.h"

@implementation MUNAttachmentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:@[NSURLPboardType]];
        self.wantsLayer = YES;
    }
    return self;
}


# pragma mark -
# pragma mark Dragging Destination

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    // highlight the view
    self.layer.borderColor = [[NSColor blueColor] CGColor];
    self.layer.cornerRadius = 3.0;
    self.layer.borderWidth = 2.0;
    
    return [sender draggingSourceOperationMask];
    
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
    self.layer.borderWidth = 0;
    
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
        self.layer.borderWidth = 0;
        
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        
        [self.uploadDelegate uploadImage:fileURL];
        
    }
    return YES;
}

@end
