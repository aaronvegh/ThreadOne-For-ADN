//
//  MUNMessageTableViewCell.h
//  Munenori
//
//  Created by Aaron Vegh on 2013-08-16.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MUNVariableHeightTextField;
@class HyperlinkTextField;

@interface MUNTheirMessageTableViewCell : NSTableCellView

@property (nonatomic, assign) BOOL me;
@property (strong, readwrite) ANKMessage * thisMessage;
@property (strong, readwrite) IBOutlet NSTextField * userName;
@property (strong, readwrite) IBOutlet HyperlinkTextField * messageField;
@property (strong, readwrite) IBOutlet NSImageView * avatarView;
@property (strong, readwrite) IBOutlet NSTextField * timeAgo;
@property (strong, readwrite) IBOutlet NSView * horizontalRule;
@property (strong, readwrite) IBOutlet NSView * backgroundView;
@property (strong, readwrite) IBOutlet NSView * attachmentView;
@property (strong, readwrite) NSTimer * timeAgoTimer;


- (void)generateImageAttachmentView;

@end
