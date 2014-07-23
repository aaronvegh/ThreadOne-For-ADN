//
//  INOAppDelegate.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2/24/2014.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INOWindowController.h"
#import "INOADNSocketController.h"
@class MUNPreferencesWindowController;

extern NSString * const kADNAccessId;
extern NSString * const kADNSecret;
extern NSString * const kADNPasswordGrant;

@interface INOAppDelegate : NSObject <NSApplicationDelegate, INOSocketDelegate>

@property (readwrite, strong) IBOutlet NSWindow * window;
@property (readwrite, nonatomic) INOWindowController * windowController;
@property (readwrite, strong) INOADNSocketController * socketController;
@property (readwrite, strong) MUNPreferencesWindowController * preferencesWindowController;


- (IBAction)muteChannel:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)openMainWindow:(id)sender;

@end
