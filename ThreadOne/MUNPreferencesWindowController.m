//
//  MUNPreferencesWindowController.m
//  ThreadOne
//
//  Created by Aaron Vegh on 12/2/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNPreferencesWindowController.h"
#import "LLManager.h"
#import "MUNThemeManager.h"
#import "INOAppDelegate.h"
#import "INOWindowController.h"
#import "MUNTitleHeaderView.h"
#import "INOCustomWindow.h"

@interface MUNPreferencesWindowController ()

@end

@implementation MUNPreferencesWindowController


- (void)awakeFromNib
{
    self.window.releasedWhenClosed = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"purchaseSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotProductInfo" object:nil];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"sounds"]) {

        NSMenuItem * selected;
        
        if ([[defaults valueForKey:@"sounds"] isEqualToString:@"ThreadOne"]) {
            selected = [[self.soundOptions itemArray] objectAtIndex:0];
            [self.soundTypeOptions setEnabled:YES];
            
        }
        else if ([[defaults valueForKey:@"sounds"] isEqualToString:@"Munenori"]) {
            selected = [[self.soundOptions itemArray] objectAtIndex:1];
            [self.soundTypeOptions setEnabled:NO];
        }
        else if ([[defaults valueForKey:@"sounds"] isEqualToString:@"none"]) {
            selected = [[self.soundOptions itemArray] objectAtIndex:2];
            [self.soundTypeOptions setEnabled:NO];
        }
        else {
            selected = [[self.soundOptions itemArray] objectAtIndex:0];
            [self.soundTypeOptions setEnabled:YES];
        }
        
        [self.soundOptions selectItem:selected];
    }
    else {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"default" forKey:@"sounds"];
        [self.soundOptions selectItem:[[self.soundOptions itemArray] objectAtIndex:0]];
    }
    
    if ([defaults valueForKey:@"soundTypeOption"]) {
        
        NSMenuItem * selected;
        
        if ([[defaults valueForKey:@"soundTypeOption"] isEqualToString:@"all"]) {
            selected = [[self.soundTypeOptions itemArray] objectAtIndex:0];
        }
        else if ([[defaults valueForKey:@"soundTypeOption"] isEqualToString:@"notifications"]) {
            selected = [[self.soundTypeOptions itemArray] objectAtIndex:1];
        }
        else {
            selected = [[self.soundTypeOptions itemArray] objectAtIndex:0];
        }
        
        [self.soundTypeOptions selectItem:selected];
    }
    else {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"all" forKey:@"soundTypeOption"];
        [self.soundTypeOptions selectItem:[[self.soundTypeOptions itemArray] objectAtIndex:0]];
    }
    
    
    if ([defaults valueForKey:@"themeName"]) {
        
        if ([[defaults valueForKey:@"themeName"] isEqualToString:@"defaultTheme"]) {
            [self.lightThemeName setState:NSOnState];
        }
        else if ([[defaults valueForKey:@"themeName"] isEqualToString:@"darkTheme"]) {
            [self.darkThemeName setState:NSOnState];
        }
        else {
            [self.lightThemeName setState:NSOnState];
        }
        
    }
    else {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"defaultTheme" forKey:@"themeName"];
        [self.lightThemeName setState:NSOnState];
        //[self.themeNames selectItem:[[self.soundOptions itemArray] objectAtIndex:0]];
    }
    
    if ([[defaults valueForKey:@"usernameDisplay"] boolValue]) {
        [self.usernameDisplayCheck setState:NSOnState];
    }
    else {
        [self.usernameDisplayCheck setState:NSOffState];
    }
        
    // CREDIT: https://github.com/kgn/LaunchAtLoginHelper
    if ([LLManager launchAtLogin]) {
        [self.loginLaunchCheck setState:NSOnState];
    }
    else {
        [self.loginLaunchCheck setState:NSOffState];
    }
    
    [self.preferencesToolbar setSelectedItemIdentifier:@"GeneralPreferences"];
    
}

- (IBAction)chooseSoundOption:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[[sender selectedItem] title] isEqualToString:@"ThreadOne"]) {
        [defaults setValue:@"ThreadOne" forKey:@"sounds"];
        [self.soundTypeOptions setEnabled:YES];
    }
    else if ([[[sender selectedItem] title] isEqualToString:@"Munenori"]) {
        [defaults setValue:@"Munenori" forKey:@"sounds"];
        [self.soundTypeOptions setEnabled:YES];
    }
    else if ([[[sender selectedItem] title] isEqualToString:@"None"]) {
        [defaults setValue:@"none" forKey:@"sounds"];
        [self.soundTypeOptions setEnabled:NO];
    }
}

- (IBAction)chooseSoundTypeOption:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[[sender selectedItem] title] isEqualToString:@"All"]) {
        [defaults setValue:@"all" forKey:@"soundTypeOption"];
    }
    else if ([[[sender selectedItem] title] isEqualToString:@"Notifications Only"]) {
        [defaults setValue:@"notifications" forKey:@"soundTypeOption"];
    }
}


- (IBAction)chooseThemeOption:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[sender title] isEqualToString:@"Light (Default)"]) {
        [defaults setValue:@"defaultTheme" forKey:@"themeName"];
        [[MUNThemeManager sharedManager] setThemeFile:@"defaultTheme"];
    }
    else if ([[sender title] isEqualToString:@"Dark"]) {
        [defaults setValue:@"darkTheme" forKey:@"themeName"];
        [[MUNThemeManager sharedManager] setThemeFile:@"darkTheme"];
    }
    
    [[MUNThemeManager sharedManager] resetValues];
    
    INOAppDelegate * delegate = (INOAppDelegate*)[NSApp delegate];
    NSRect existingFrame = delegate.windowController.window.frame;
    [delegate.windowController close];
    
    delegate.windowController = [[INOWindowController alloc] initWithWindowNibName:@"MUNWindowController"];
    [delegate.windowController.window setFrame:existingFrame display:YES];
    [delegate.windowController showWindow:nil];
    [delegate.windowController renderTitleHeaderView];
    
}

- (IBAction)chooseLoginLaunchOption:(id)sender
{
    if (self.loginLaunchCheck.state == NSOnState) {
        [LLManager setLaunchAtLogin:YES];
    }
    else {
        [LLManager setLaunchAtLogin:NO];
    }
}


- (IBAction)chooseUsernameDisplayOption:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.usernameDisplayCheck.state == NSOnState) {
        [defaults setValue:@YES forKey:@"usernameDisplay"];
    }
    else {
        [defaults setValue:@NO forKey:@"usernameDisplay"];
    }
}


- (IBAction)clickRateButton:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/threadone/id788290980?ls=1&mt=12"]];
}


@end
