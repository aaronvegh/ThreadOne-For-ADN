//
//  INOMessageViewController.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-06.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MUNComposeTextView;
@class MUNComposeView;
#import "MUNAttachmentView.h"
@class INOMessageTableView;
#import "INOMessageTools.h"
#import "ITProgressIndicator.h"

@interface INOMessageViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSTextViewDelegate, NSControlTextEditingDelegate, MUNAttachmentUploadDelegate>

@property (readwrite, strong) ANKChannel * channel;
@property (readwrite, strong) NSMutableArray * messageData;

@property (readwrite, strong) IBOutlet NSView * headerView;
@property (readwrite, strong) IBOutlet NSTextField * headerChatTitle;
@property (readwrite, strong) IBOutlet NSTextField * headerChatParticipants;

@property (readwrite, strong) IBOutlet INOMessageTableView * messageTable;
@property (readwrite, strong) IBOutlet MUNComposeView * composeView;
@property (readwrite, strong) IBOutlet MUNComposeTextView * messagePostField;
@property (readwrite, strong) IBOutlet NSButton * attachmentButton;
@property (readwrite, strong) IBOutlet NSView * horizontalRule;
@property (readwrite, strong) IBOutlet MUNAttachmentView * attachmentView;
@property (readwrite, strong) IBOutlet NSProgressIndicator * progressIndicator;
@property (readwrite, strong) NSMutableArray * annotationArray;
@property (readwrite, strong) NSMutableArray * attachmentArray;

@property (readwrite, strong) NSMutableParagraphStyle * titleParagraphStyle;
@property (readwrite, strong) NSMutableParagraphStyle * messageParagraphStyle;
@property (readwrite, strong) NSMutableParagraphStyle * myMessageParagraphStyle;

@property (readwrite, strong) NSMutableParagraphStyle * theirTitleParagraphStyle;
@property (readwrite, strong) NSMutableParagraphStyle * myTitleParagraphStyle;

@property (readwrite, assign) BOOL messagesAreBeingFetched;
@property (readwrite, strong) ANKClient * messageClient;
@property (readwrite, assign) MessageFetchState fetchState;
@property (readwrite, strong) NSDate * updateTime;

@property (readwrite, strong) IBOutlet NSView * messageLoadingView;
@property (readwrite, strong) IBOutlet ITProgressIndicator * indicator;

- (IBAction)sendMessage:(id)sender;
- (IBAction)attachFile:(id)sender;
- (void)updatePreviewView;
- (void)loadDataForChannel:(ANKChannel*)channel;
- (void)scrollToEnd;

@end
