//
//  MUNImageAttachmentButton.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-09-09.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNImageAttachmentButton.h"
#import "NSImageView+AFNetworking.h"

@implementation MUNImageAttachmentButton

- (id)initWithFrame:(NSRect)frame image:(NSImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = image;
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 45, 45)];
        self.title = @"";
        //self.bezelStyle = NSCircularBezelStyle;
    }
    return self;
}

@end
