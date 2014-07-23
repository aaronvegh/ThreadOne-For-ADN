//
//  MUNThemeManager.h
//  ThreadOne
//
//  Created by Aaron Vegh on 12/9/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUNThemeManager : NSObject

+ (MUNThemeManager*)sharedManager;
- (void)resetValues;

@property (readwrite, strong) NSString * themeFile;
@property (readwrite, strong) NSDictionary * colourTheme;
@property (readwrite, strong) NSString * themeName;
@property (readwrite, strong) NSColor * windowBackgroundColor;
@property (readwrite, strong) NSColor * highlightColor;
@property (readwrite, strong) NSColor * highToneColor;
@property (readwrite, strong) NSColor * lowToneColor;
@property (readwrite, strong) NSColor * headerTextColor;
@property (readwrite, strong) NSColor * chatShadowColor;
@property (readwrite, strong) NSColor * bodyTextColor;
@property (readwrite, strong) NSColor * highToneDividerColor;
@property (readwrite, strong) NSColor * lowToneDividerColor;
@property (readwrite, strong) NSColor * timestampTextColor;
@property (readwrite, strong) NSColor * datelineTextColor;
@property (readwrite, strong) NSColor * titleBarStartColor;
@property (readwrite, strong) NSColor * titleInactiveBarStartColor;
@property (readwrite, strong) NSColor * titleBarEndColor;
@property (readwrite, strong) NSColor * titleInactiveBarEndColor;
@property (readwrite, strong) NSColor * titleBorderColor;
@property (readwrite, strong) NSFont * themeFontHeader;
@property (readwrite, strong) NSFont * themeFontBody;
@property (readwrite, strong) NSFont * themeFontSmallerHeader;
@property (readwrite, strong) NSFont * themeFontSmaller;
@property (readwrite, strong) NSFont * themeFontChatName;
@property (readwrite, strong) NSString * brandNewChatButtonName;
@property (readwrite, strong) NSString * chatsButtonName;

@end
