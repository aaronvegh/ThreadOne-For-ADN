//
//  INOWindowController.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-05.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOWindowController.h"
#import "MUNTitleHeaderView.h"
#import "INOCustomWindow.h"
#import "INOChatViewController.h"
#import "INOMessageViewController.h"
#import "MUNThemeManager.h"
#import <QuartzCore/QuartzCore.h>
#import "MUNComposeTextView.h"
#import "INOMessageTableView.h"
#import "MUNImageAttachmentButton.h"
#import "MUNImageWindowController.h"
#import "ITProgressIndicator.h"
#import "MUNNewChatViewController.h"
#import "MUNNewChatTextField.h"

@interface INOWindowController ()

@property (readwrite, strong) MUNImageWindowController * imageWindowController;

@end

@implementation INOWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:@"INOWindowController"];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setDelegate:self];
    
    self.aWindow = (INOCustomWindow*)[self window];
    
    [self.aWindow.titleBarView addSubview:self.titleHeaderView];
    
    self.chatViewController = [[INOChatViewController alloc] initWithNibName:@"INOChatViewController" bundle:[NSBundle mainBundle]];
    [self.chatViewController.view setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
    [self.chatViewController.view setFrame:[self.aWindow.contentView frame]];
    
    self.messageViewController = [[INOMessageViewController alloc] initWithNibName:@"INOMessageViewController" bundle:nil];
    [self.messageViewController.view setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
    
    self.makeChatViewController = [[MUNNewChatViewController alloc] initWithNibName:@"MUNNewChatViewController" bundle:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteSwitchToChats:) name:@"remoteSwitchToChats" object:nil];
    
    [self.aWindow.contentView addSubview:self.chatViewController.view];
}

- (void)windowDidResize:(NSNotification *)notification
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [self.messageViewController.messageTable noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.messageViewController.messageTable numberOfRows])]];
    [NSAnimationContext endGrouping];
    
}

- (void)renderTitleHeaderView
{
    if ([[ANKClient sharedClient] authenticatedUser]) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        
        NSString *testPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ThreadOne/avatars/%@", [[ANKClient sharedClient] authenticatedUser].userID]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:testPath isDirectory:NO]) {
            self.titleHeaderView.currentUserAvatar.image = [[NSImage alloc] initWithContentsOfFile:testPath];
        }
        else {
            self.titleHeaderView.currentUserAvatar.image = [[NSImage alloc] initWithContentsOfURL:[[ANKClient sharedClient] authenticatedUser].avatarImage.URL];
        }
        
        [self.titleHeaderView.currentUserAvatar setWantsLayer: YES];
        self.titleHeaderView.currentUserAvatar.layer.cornerRadius = 5.0;
        self.titleHeaderView.currentUserAvatar.layer.masksToBounds = YES;
        
        NSAttributedString * usernameString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@", [[ANKClient sharedClient] authenticatedUser].username] attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontSmallerHeader]}];
        
        NSAttributedString * userFullNameString = [[NSAttributedString alloc] initWithString:[[ANKClient sharedClient] authenticatedUser].name attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontSmaller]}];
        
        self.titleHeaderView.currentUsername.attributedStringValue = usernameString;
        self.titleHeaderView.currentUserFullname.attributedStringValue = userFullNameString;
        
        self.titleHeaderView.currentUsername.textColor = [[MUNThemeManager sharedManager] bodyTextColor];
        self.titleHeaderView.currentUserFullname.textColor = [[MUNThemeManager sharedManager] bodyTextColor];
        
        
    }
    
}

#pragma mark -
#pragma mark View Controller Switching

- (void)prepareViews:(BOOL)fromRight
{
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    if (fromRight) {
        [transition setSubtype:kCATransitionFromRight];
    }
    else {
        [transition setSubtype:kCATransitionFromLeft];
    }
    
    [self.aWindow.contentView setAnimations:[NSDictionary dictionaryWithObject:transition forKey:@"subviews"]];
    [self.aWindow.contentView setWantsLayer:YES];
    
    
}

- (IBAction)showChats:(id)sender
{
    if (![[self.aWindow.contentView subviews] containsObject:self.chatViewController.view]) {
        [self prepareViews:NO];
        [self switchToChatsTable];
    }
}

- (IBAction)newChat:(id)sender
{
    [self prepareViews:NO];
    
    [self switchToNewChatsView];
}

- (void)switchToMessageTable
{
    [self.titleHeaderView.chatsButton setEnabled:YES];
    self.messageViewController.view.frame = [self.aWindow.contentView frame];
    
    [[self.chatViewController.view animator] removeFromSuperview];
    
    [[self.aWindow.contentView animator] addSubview:self.messageViewController.view];
    
    [[self window] makeFirstResponder:self.messageViewController.messagePostField];
    
    [[self aWindow] display];
}

- (void)switchToChatsTable
{
    self.messageViewController.messageData = nil;
    self.messageViewController.messageClient = nil;
    self.messageViewController.headerChatTitle.stringValue = @"";
    self.messageViewController.headerChatParticipants.stringValue = @"";
    self.messageViewController.messagesAreBeingFetched = NO;
    //[self.messageViewController.messageTable reloadData];
    [self.messageViewController.messagePostField setString:@""];
    
    [self.titleHeaderView.chatsButton setEnabled:NO];
    [[self.messageViewController.view animator] removeFromSuperview];
    
    self.chatViewController.view.frame = [self.aWindow.contentView frame];
    [[self.aWindow.contentView animator] addSubview:self.chatViewController.view];
    
    [[self window] makeFirstResponder:self.chatViewController.channelTable];
    
    [[self aWindow] display];
}

- (void)switchToNewChatsView
{
    [self.titleHeaderView.chatsButton setEnabled:YES];
    if ([[self.aWindow.contentView subviews] containsObject:self.messageViewController.view]) {
        [[self.messageViewController.view animator] removeFromSuperview];
    }
    else if ([[self.aWindow.contentView subviews] containsObject:self.chatViewController.view]) {
        [[self.chatViewController.view animator] removeFromSuperview];
    }
    
    self.makeChatViewController.view.frame = [self.aWindow.contentView frame];
    [[self.aWindow.contentView animator] addSubview:self.makeChatViewController.view];
    [[self window] makeFirstResponder:self.makeChatViewController.userSelectionField];
}

- (void)remoteSwitchToChats:(NSNotification*)aNotification
{
    [self prepareViews:NO];
    [self switchToChatsTable];
}

- (BOOL)wantsScrollEventsForSwipeTrackingOnAxis:(NSEventGestureAxis)axis
{
    return YES;
}

- (void)scrollWheel:(NSEvent *)event {
    if ([event phase] == NSEventPhaseNone) return; // Not a gesture scroll event.
    if (fabsf([event scrollingDeltaX]) <= fabsf([event scrollingDeltaY])) return; // Not horizontal
    if (![NSEvent isSwipeTrackingFromScrollEventsEnabled]) return;
    
    __block BOOL animationCancelled = NO;
    [event trackSwipeEventWithOptions:0 dampenAmountThresholdMin:0 max:1
                         usingHandler:^(CGFloat gestureAmount, NSEventPhase phase, BOOL isComplete, BOOL *stop) {
         if (animationCancelled) {
             *stop = YES;
             return;
         }
         if (phase == NSEventPhaseBegan) {
             // Setup animation overlay layers
             if (gestureAmount > 0) {
                 // this is a right-ward gesture
                 if (![[self.aWindow.contentView subviews] containsObject:self.chatViewController.view]) {
                     // we're in the message view, so take us back to the chat view
                     [self prepareViews:NO];
                     [self switchToChatsTable];
                 }
             }
         }
    }];
}

- (void)showImage:(MUNImageAttachmentButton*)button
{
    self.imageWindowController = [[MUNImageWindowController alloc] initWithWindowNibName:@"MUNImageWindowController" andImage:button.image];
    self.imageWindowController.regularPath = button.regularPath;
    self.imageWindowController.imageSize = button.imageSize;
    [self.imageWindowController.window setAnimationBehavior:NSWindowAnimationBehaviorDocumentWindow];
    [self.imageWindowController showWindow:self];
}

@end
