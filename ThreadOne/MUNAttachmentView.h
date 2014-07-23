//
//  MUNAttachmentView.h
//  ThreadOne
//
//  Created by Aaron Vegh on 12/5/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MUNAttachmentUploadDelegate <NSObject>
- (void)uploadImage:(NSURL*)url;
@end

@interface MUNAttachmentView : NSView <NSDraggingDestination>

@property (weak, atomic) id <MUNAttachmentUploadDelegate> uploadDelegate;

@end

