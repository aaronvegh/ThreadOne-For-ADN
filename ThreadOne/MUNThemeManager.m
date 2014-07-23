//
//  MUNThemeManager.m
//  ThreadOne
//
//  Created by Aaron Vegh on 12/9/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNThemeManager.h"


@implementation MUNThemeManager

+ (MUNThemeManager *)sharedManager {
    static MUNThemeManager * _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[MUNThemeManager alloc] init];
    });
    
    return _sharedManager;
}


- (id)init
{
    if (self = [super init]) {
        
        [self resetValues];
        
    }
    
    return self;
}


- (void)resetValues
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults valueForKey:@"themeName"]) {
        self.themeFile = [[NSBundle mainBundle] pathForResource:[defaults valueForKey:@"themeName"] ofType:@"plist"];
    }
    else {
        self.themeFile = [[NSBundle mainBundle] pathForResource:@"defaultTheme" ofType:@"plist"];
    }
    
    

    self.colourTheme = [[NSDictionary alloc] initWithContentsOfFile:self.themeFile];
    
    self.themeName = [self.colourTheme valueForKey:@"MUNThemeName"];
    self.windowBackgroundColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNWindowBackgroundColor"]];
    self.highlightColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNHighlightColor"]];
    self.highToneColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNHighToneColor"]];
    self.lowToneColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNLowToneColor"]];
    self.headerTextColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNHeaderTextColor"]];
    self.chatShadowColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNChatShadowColor"]];
    self.bodyTextColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNBodyTextColor"]];
    self.highToneDividerColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNHighToneDividerColor"]];
    self.lowToneDividerColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNLowToneDividerColor"]];
    self.timestampTextColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNTimestampTextColor"]];
    self.datelineTextColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNDatelineTextColor"]];
    self.titleBarStartColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNTitleBarStartColor"]];
    self.titleInactiveBarStartColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNInactiveTitleBarStartColor"]];
    self.titleBarEndColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNTitleBarEndColor"]];
    self.titleInactiveBarEndColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNInactiveTitleBarEndColor"]];
    self.titleBorderColor = [self colorFromHexString:[self.colourTheme valueForKey:@"MUNTitleBorderColor"]];
    self.themeFontHeader = [NSFont fontWithName:[self.colourTheme valueForKey:@"MUNThemeFont"] size:[[self.colourTheme valueForKey:@"MUNHeaderFontSize"] floatValue]];
    self.themeFontBody = [NSFont fontWithName:[self.colourTheme valueForKey:@"MUNThemeFont"] size:[[self.colourTheme valueForKey:@"MUNBodyFontSize"] floatValue]];
    self.themeFontSmallerHeader = [NSFont fontWithName:[self.colourTheme valueForKey:@"MUNBoldThemeFont"] size:[[self.colourTheme valueForKey:@"MUNSmallerFontSize"] floatValue]];
    self.themeFontSmaller = [NSFont fontWithName:[self.colourTheme valueForKey:@"MUNThemeFont"] size:[[self.colourTheme valueForKey:@"MUNSmallerFontSize"] floatValue]];
    self.themeFontChatName = [NSFont fontWithName:[self.colourTheme valueForKey:@"MUNThemeFont"] size:[[self.colourTheme valueForKey:@"MUNChatNameSize"] floatValue]];
    self.brandNewChatButtonName = [self.colourTheme valueForKey:@"MUNNewChatButtonName"];
    self.chatsButtonName = [self.colourTheme valueForKey:@"MUNChatsButtonName"];
}


// Assumes input like "#00FF00" (#RRGGBB).
// Courtesy of "darrinm" at http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string

- (NSColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [NSColor colorWithCalibratedRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end
