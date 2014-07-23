//
//  MUNChannelTableViewCell.h
//  Munenori
//
//  Created by Aaron Vegh on 2013-06-29.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MUNVariableHeightTextField;

@interface MUNChannelTableViewCell : NSTableCellView <NSTextFieldDelegate>

- (NSView*)unreadPip;
- (void)generateAvatarView:(ANKChannel*)channel;

@property (strong, readwrite) IBOutlet NSTextField * timeAgo;
@property (strong, readwrite) IBOutlet NSTextField * titleField;
@property (strong, readwrite) IBOutlet NSTextField * lastMessage;
@property (strong, readwrite) IBOutlet NSView * avatarView;
@property (strong, readwrite) ANKChannel * channel;
@property (strong, readwrite) NSTimer * timeAgoTimer;
@property (strong, readwrite) IBOutlet NSView * pipView;
@property (strong, readwrite) IBOutlet NSView * screenView;

@end
