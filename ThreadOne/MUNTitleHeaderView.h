//
//  MUNTitleHeaderView.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-09-11.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MUNTitleHeaderView : NSView
{
    NSPoint mouseStart;
    NSButton *closeButton;
    NSButton *minitiarizeButton;
    NSButton *zoomButton;
}
@property (readwrite, strong) IBOutlet NSTextField * titleField;
@property (readwrite, strong) IBOutlet NSImageView * currentUserAvatar;
@property (readwrite, strong) IBOutlet NSTextField * currentUsername;
@property (readwrite, strong) IBOutlet NSTextField * currentUserFullname;
@property (readwrite, strong) IBOutlet NSButton * chatsButton;
@property (readwrite, strong) IBOutlet NSView * chatsButtonNewPip;
@property (readwrite, strong) IBOutlet NSButton * makeNewChatButton;
@property (readwrite, strong) IBOutlet NSView * horizontalGuideView;
@property (readwrite, strong) IBOutlet NSTextField * chatsButtonName;
@property (readwrite, strong) IBOutlet NSTextField * makeNewChatButtonName;


- (void)mainWindowChanged;

@end
