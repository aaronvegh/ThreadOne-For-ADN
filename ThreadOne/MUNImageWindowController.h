//
//  MUNImageWindowController.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-09-08.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PVAsyncImageView.h"

@interface MUNImageWindowController : NSWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName andImage:(NSImage*)image;

@property (readwrite, strong) NSImage * image;
@property (readwrite, strong) IBOutlet PVAsyncImageView * imageView;
@property (readwrite, strong) NSString * regularPath;
@property (readwrite, assign) NSSize imageSize;

@end
