//
//  INOAppDelegate.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2/24/2014.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOAppDelegate.h"
#import "INOChatViewController.h"
#import "INOMessageViewController.h"
#import "MUNUser.h"
#import "INOCustomWindow.h"
#import "MUNTitleHeaderView.h"
#import "INOADNSocketController.h"
#import "MUNPreferencesWindowController.h"
#import "INOChannelTools.h"
#import "Reachability.h"

NSString * const kADNAccessId = @"";
NSString * const kADNSecret = @"";
NSString * const kADNPasswordGrant = @"";

@interface INOAppDelegate ()

@property (readwrite, strong) ANKChannel * selectedChannel;

@end

@implementation INOAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if ([[MUNUser sharedInstance] accessToken]) {
        [[ANKClient sharedClient] logInWithAccessToken:[[MUNUser sharedInstance] accessToken]
                                            completion:^(BOOL succeeded, ANKAPIResponseMeta *meta, NSError *error) {
            [ANKClient sharedClient].accessToken = [[MUNUser sharedInstance] accessToken];
            [self.windowController renderTitleHeaderView];
            
            if (!self.socketController) {
                self.socketController = [[INOADNSocketController alloc] init];
                self.socketController.socketDelegate = self;
            }
            
        }];
    }
    
    // set some default prefs
    NSDictionary *appDefaults = @{@"sounds" : @"ThreadOne",
                                  @"soundTypeOption" : @"all",
                                  @"themeName" : @"defaultTheme"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    if(!self.windowController) {
        self.windowController = [[INOWindowController alloc] initWithWindowNibName:@"INOWindowController"];
    }
    
    [self.windowController showWindow:nil];

    Reachability * reach = [Reachability reachabilityWithHostname:@"alpha.app.net"];
    
    __weak typeof(self)weakSelf = self;
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf.socketController && [[MUNUser sharedInstance] accessToken]) {
                strongSelf.socketController = [[INOADNSocketController alloc] init];
                strongSelf.socketController.socketDelegate = strongSelf;
                [strongSelf.windowController.chatViewController.channelTable reloadData];
            }
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.socketController = nil;
            
        });
    };
    
    [reach startNotifier];
    
}

- (IBAction)openPreferences:(id)sender
{
    if(!self.preferencesWindowController) {
        self.preferencesWindowController = [[MUNPreferencesWindowController alloc] initWithWindowNibName:@"MUNPreferencesWindowController"];
    }
    [self.preferencesWindowController showWindow:nil];
}

- (IBAction)muteChannel:(id)sender
{
    // determine channel to unsub
    if ([[self.windowController.aWindow.contentView subviews] containsObject:self.windowController.chatViewController.view]) {
        NSInteger selectedRow = self.windowController.chatViewController.channelTable.selectedRow;
        self.selectedChannel = [self.windowController.chatViewController.channelData objectAtIndex:selectedRow][@"data"];
    }
    else {
        self.selectedChannel = self.windowController.messageViewController.channel;
    }
    
    NSAlert * warning = [[NSAlert alloc] init];
    warning.messageText = @"Are you sure you want to unsubscribe from this chat?";
    warning.informativeText = @"To reinstate this chat, start a new chat with the same recipients.";
    [warning addButtonWithTitle:@"Cancel"];
    [warning addButtonWithTitle:@"Unsubscribe"];
    [warning setAlertStyle:NSCriticalAlertStyle];
    [warning beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    if (returnCode == 1000) {
        //cancel
    }
    else if (returnCode == 1001) {
        // unsub
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUnsubscribe:) name:@"didUnsubscribeFromChannel" object:nil];
        [[INOChannelTools sharedTools] unsubscribe:self.selectedChannel];
    }
}

- (void)handleUnsubscribe:(NSNotification*)aNotification
{
    if ([[self.windowController.aWindow.contentView subviews] containsObject:self.windowController.chatViewController.view]) {
        [self.windowController.chatViewController loadDataForChannelTable];
        
    }
    else {
        [self.windowController switchToChatsTable];
        [self.windowController.chatViewController loadDataForChannelTable];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didUnsubscribeFromChannel" object:nil];

}

- (IBAction)openMainWindow:(id)sender
{
    if(!self.windowController) {
        self.windowController = [[INOWindowController alloc] initWithWindowNibName:@"INOWindowController"];
    }
    
    [self.windowController showWindow:nil];
}

- (void)socketDidDisconnect
{
    self.socketController = nil;
    self.socketController = [[INOADNSocketController alloc] init];
    self.socketController.socketDelegate = self;
}


@end
