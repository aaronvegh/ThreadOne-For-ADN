//
//  MUNImageAttachmentButton.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-09-09.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MUNImageAttachmentButton : NSButton

- (id)initWithFrame:(NSRect)frame image:(NSImage*)image;

@property (readwrite, strong) NSImage * image;
@property (readwrite, strong) NSImageView * imageView;
@property (readwrite, strong) NSString * regularPath;
@property (readwrite, assign) NSSize imageSize;

@end
