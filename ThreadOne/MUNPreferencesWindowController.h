//
//  MUNPreferencesWindowController.h
//  ThreadOne
//
//  Created by Aaron Vegh on 12/2/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DDHotKeyTextField;
@class MUNBluePillButton;

@interface MUNPreferencesWindowController : NSWindowController <NSToolbarDelegate>

@property (readwrite, strong) IBOutlet NSButton * lightThemeName;
@property (readwrite, strong) IBOutlet NSButton * darkThemeName;
@property (readwrite, strong) IBOutlet NSPopUpButton * soundOptions;
@property (readwrite, strong) IBOutlet NSPopUpButton * soundNotificationOptions;
@property (readwrite, strong) IBOutlet NSPopUpButton * soundTypeOptions;
@property (readwrite, strong) IBOutlet NSButton * loginLaunchCheck;
@property (readwrite, strong) IBOutlet NSButton * usernameDisplayCheck;
@property (readwrite, strong) IBOutlet MUNBluePillButton * buyNowButton;
@property (readwrite, strong) IBOutlet MUNBluePillButton * restoreButton;
@property (readwrite, strong) IBOutlet NSTextField * priceLabel;
@property (readwrite, strong) IBOutlet DDHotKeyTextField * hotKeyField;
@property (readwrite, strong) IBOutlet NSTabView * tabView;
@property (readwrite, strong) IBOutlet NSToolbar * preferencesToolbar;
@property (readwrite, strong) IBOutlet NSToolbarItem * generalPrefsItem;
@property (readwrite, strong) IBOutlet NSToolbarItem * themePrefsItem;
@property (readwrite, strong) IBOutlet NSToolbarItem * soundPrefsItem;
@property (readwrite, strong) IBOutlet NSToolbarItem * purchasePrefsItem;
@property (readwrite, strong) IBOutlet NSView * thanksView;
@property (readwrite, strong) IBOutlet MUNBluePillButton * rateButton;

- (IBAction)chooseSoundOption:(id)sender;
- (IBAction)chooseThemeOption:(id)sender;
- (IBAction)chooseLoginLaunchOption:(id)sender;
- (IBAction)chooseUsernameDisplayOption:(id)sender;
- (IBAction)chooseSoundTypeOption:(id)sender;
- (IBAction)clickRateButton:(id)sender;

@end
