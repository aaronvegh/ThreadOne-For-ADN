//
//  MUNImageWindowController.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-09-08.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNImageWindowController.h"
#import "NSData+NSData_MIMEType.h"
#import <WebKit/WebKit.h>
#import "PVAsyncImageView.h"

@interface MUNImageWindowController ()

@end

@implementation MUNImageWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName andImage:(NSImage*)image
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.image = image;
        self.imageView.imageScaling = NSScaleNone;
        self.shouldCascadeWindows = NO;
    }
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    if (self.image) {
        NSImageRep *rep = [[self.image representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        
        [self resizeWindowForContentSize:imageSize];
        self.imageView.image = self.image;
    }
    else {
        [self resizeWindowForContentSize:self.imageSize];
        [self.imageView downloadImageFromURL:self.regularPath withPlaceholderImage:nil errorImage:[NSImage imageNamed:@"attachmentFailed"] andDisplaySpinningWheel:YES];
    }
    
    
}

- (void)resizeWindowForContentSize:(NSSize) size {
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    
    CGFloat width = MIN(screenFrame.size.width - 200, size.width);
    CGFloat height = MIN(screenFrame.size.height - 200, size.height);
    
    CGFloat x = screenFrame.size.width - width - ((screenFrame.size.width - width) / 2);
    CGFloat y = screenFrame.size.height - height - ((screenFrame.size.height - height) / 2);
    
    NSRect windowFrame = NSMakeRect(x, y, width, height);

    [self.window setContentAspectRatio:size];
    [self.window setFrame:windowFrame display:YES animate:YES];
    
}

@end
