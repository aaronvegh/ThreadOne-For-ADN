//
//  MUNNewChatViewController.m
//  ThreadOne
//
//  Created by Aaron Vegh on 10/6/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNNewChatViewController.h"
#import "INOAutoSuggestViewController.h"
#import "INOAutoSuggestTableView.h"
#import "MUNNewChatTextField.h"
#import "MUNNewUserTokenContainerView.h"
#import "MUNComposeTextView.h"
#import "MUNComposeView.h"
#import "INOMessageTableView.h"


#define AUTOSUGGEST_DELAY 0.5

@interface MUNNewChatViewController ()

@end

@implementation MUNNewChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    self.appDelegate = (INOAppDelegate*)[NSApp delegate];
    self.mainWindowController = self.appDelegate.windowController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arrowDown:) name:@"sendArrowDown" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshShowUsers:) name:@"refreshShowUsers" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage:) name:@"sendNewChatMessage" object:nil];
    
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    
    [self.horizontalSeparator setWantsLayer:YES];
    [self.horizontalSeparator.layer setBackgroundColor:[[NSColor colorWithCalibratedRed:0.847 green:0.855 blue:0.863 alpha:1] CGColor]];
    
    self.userListViewController = [[INOAutoSuggestViewController alloc] initWithNibName:@"INOAutoSuggestViewController" bundle:[NSBundle mainBundle] partialText:self.userSelectionField.stringValue sender:self.userSelectionField];
    
    [self.userListViewController loadView];
    [self.userListViewController.view setHidden:YES];
    
    [self prepareViews:YES];
    [self switchToAddUser];
    
    self.isSending = NO;
    
}

- (IBAction)addUser:(id)sender
{
    [self prepareViews:YES];
    [self switchToAddUser];
}

- (void)controlTextDidChange:(NSNotification*)aNotification
{
    if (self.autoSuggestTimer) {
        [self.autoSuggestTimer invalidate];
    }
    
    self.autoSuggestTimer = [NSTimer scheduledTimerWithTimeInterval:AUTOSUGGEST_DELAY target:self selector:@selector(createPopover:) userInfo:[aNotification object] repeats:NO];
    
}

- (void)arrowDown:(NSNotification*)notification
{
    [[self.view window] makeFirstResponder:self.userListViewController.tableView];
    [[self.userListViewController tableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void)createPopover:(NSNotification*)notification
{
    self.userListViewController.partialText = self.userSelectionField.stringValue;
    
    NSRect popoverRect = NSMakeRect(
                                    self.animationContainerView.frame.size.width / 2 - 115,
                                    self.animationContainerView.frame.origin.y - 210,
                                    230, 200
                                    );
    
    [self.userListViewController.view setFrame:popoverRect];
    
    [self.view addSubview:self.userListViewController.view];
}

#pragma mark -
#pragma mark Moving Views

- (void)prepareViews:(BOOL)fromTop
{
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    if (fromTop) {
        [transition setSubtype:kCATransitionFromTop];
    }
    else {
        [transition setSubtype:kCATransitionFromBottom];
    }
    
    [self.animationContainerView setAnimations:[NSDictionary dictionaryWithObject:transition forKey:@"subviews"]];
    [self.animationContainerView setWantsLayer:YES];
}

- (void)switchToAddUser
{
    [[self.userDisplayView animator] removeFromSuperview];
    
    self.userSelectionField.frame = NSMakeRect(15, self.view.frame.size.height - 40, self.view.frame.size.width - 30, 22);
    [[self.view animator] addSubview:self.userSelectionField];
    
    [[self.view window] makeFirstResponder:self.userSelectionField];
}

- (void)switchToShowUsers
{
    self.userSelectionField.stringValue = @"";
    [[self.userSelectionField animator] removeFromSuperview];
    
    self.userDisplayView.frame = NSMakeRect(15, 0, self.animationContainerView.frame.size.width - 30, 30);
    
    self.addUserButton.frame = NSMakeRect(self.userDisplayView.frame.size.width - 80, 0, 80, 30);
    self.tokenContainer.frame = NSMakeRect(0, 0, self.userDisplayView.frame.size.width - 85, 25);
    
    [self.animationContainerView addSubview:self.userDisplayView];
}

- (void)refreshShowUsers:(NSNotification*)notification
{
    [self prepareViews:YES];
    [self switchToShowUsers];
    
    self.tokenContainer.tokenArray = self.userListViewController.chosenUserArray;
    [[self tokenContainer] refreshView];
}


- (void)textViewDidChangeSelection:(NSNotification *)aNotification
{
    MUNComposeTextView * textView = [aNotification object];
    
    
    NSRect usedRect = [textView.textContainer.layoutManager usedRectForTextContainer:textView.textContainer];
    
    CGFloat newHeight = MAX(usedRect.size.height, 35);
    
    NSRect textViewStartingRect = [[[self.messagePostField superview] superview] frame];
    NSRect composeViewStartingRect = [self.composeView frame];
    
    [[self.messagePostField superview] superview].frame = NSMakeRect(textViewStartingRect.origin.x, textViewStartingRect.origin.y, textViewStartingRect.size.width, newHeight);
    
    [self.composeView setFrame:NSMakeRect(composeViewStartingRect.origin.x, composeViewStartingRect.origin.y, composeViewStartingRect.size.width, newHeight + 10)];
    
}

- (void)sendMessage:(NSNotification*)notification
{
    if (!self.isSending) {
        self.isSending = YES;
        NSMutableArray * channelUsers = [NSMutableArray array];
        for (ANKUser * user in self.userListViewController.chosenUserArray) {
            [channelUsers addObject:user.userID];
        }
        
        ANKMessage * newMessage = [[ANKMessage alloc] init];
        newMessage.destinationUserIDs = channelUsers;
        newMessage.text = self.messagePostField.string;
        
        [[ANKClient sharedClient] createMessage:newMessage inChannelWithID:@"pm" completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
            self.messagePostField.string = @"";
            
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"] isEqualToString:@"none"] && ![[[NSUserDefaults standardUserDefaults] valueForKey:@"soundTypeOption"] isEqualToString:@"notifications"]) {
                
                NSString *audioFile;
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"] isEqualToString:@"ThreadOne"]) {
                    audioFile = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], @"01_ascending"];
                }
                else { //([[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"] isEqualToString:@"Munenori"]) {
                    audioFile = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], @"ZoopUp"];
                }
                
                NSData *audioData = [NSData dataWithContentsOfFile:audioFile options:NSDataReadingMappedIfSafe error:nil];
                NSSound *zoopUp = [[NSSound alloc] initWithData:audioData];
                [zoopUp play];
            }
            
            ANKChannel * newChannel = [[ANKChannel alloc] init];
            newChannel.channelID = [(ANKMessage*)responseObject channelID];
            
            self.mainWindowController.messageViewController.messageData = nil;
            self.mainWindowController.messageViewController.fetchState = MessageFetchStateFirstRun|MessageFetchStateIncoming;
            self.mainWindowController.messageViewController.updateTime = nil;
            [self.mainWindowController.messageViewController loadDataForChannel:newChannel];
            
            [self.mainWindowController prepareViews:YES];
            [self.mainWindowController switchToMessageTable];
            [self.mainWindowController.messageViewController.messageTable reloadData];
            
            self.isSending = NO;
            
        }];
        
    
    }
    
    
}

@end
