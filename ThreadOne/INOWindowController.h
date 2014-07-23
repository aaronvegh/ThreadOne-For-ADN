//
//  INOWindowController.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-05.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class INOCustomWindow;
@class MUNTitleHeaderView;
@class INOChatViewController;
@class INOMessageViewController;
@class MUNImageAttachmentButton;
@class MUNNewChatViewController;

@interface INOWindowController : NSWindowController <NSWindowDelegate>

@property (strong, readwrite) INOCustomWindow * aWindow;
@property (strong, readwrite) IBOutlet MUNTitleHeaderView * titleHeaderView;
@property (strong, readwrite) INOChatViewController * chatViewController;
@property (strong, readwrite) INOMessageViewController * messageViewController;
@property (readwrite, strong) MUNNewChatViewController * makeChatViewController;

- (void)renderTitleHeaderView;
//- (void)setNewMessageView;
- (void)prepareViews:(BOOL)fromRight;
- (void)switchToMessageTable;
- (void)switchToChatsTable;
- (void)showImage:(MUNImageAttachmentButton*)button;
@end
