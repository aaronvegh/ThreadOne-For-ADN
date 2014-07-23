//
//  MUNNewChatViewController.h
//  ThreadOne
//
//  Created by Aaron Vegh on 10/6/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INOAppDelegate.h"
#import "INOWindowController.h"
@class INOAutoSuggestViewController;
@class MUNNewChatTextField;
@class MUNNewUserTokenContainerView;
@class MUNComposeTextView;
@class MUNComposeView;

@interface MUNNewChatViewController : NSViewController <NSTextFieldDelegate, NSPopoverDelegate, NSTextViewDelegate, NSControlTextEditingDelegate>

@property (readwrite, strong) INOAppDelegate * appDelegate;
@property (readwrite, strong) INOWindowController * mainWindowController;

@property (readwrite, strong) INOAutoSuggestViewController * userListViewController;
@property (readwrite, strong) IBOutlet NSView * horizontalSeparator;

@property (readwrite, strong) IBOutlet MUNNewChatTextField * userSelectionField;

@property (readwrite, strong) NSTimer * autoSuggestTimer;

@property (readwrite, strong) IBOutlet NSView * animationContainerView;

@property (readwrite, strong) IBOutlet NSView * userDisplayView;

@property (readwrite, strong) IBOutlet NSButton * addUserButton;
@property (readwrite, strong) IBOutlet MUNNewUserTokenContainerView * tokenContainer;

@property (readwrite, strong) IBOutlet MUNComposeView * composeView;
@property (readwrite, strong) IBOutlet MUNComposeTextView * messagePostField;

@property (readwrite, assign) BOOL isSending;

- (IBAction)addUser:(id)sender;


@end
