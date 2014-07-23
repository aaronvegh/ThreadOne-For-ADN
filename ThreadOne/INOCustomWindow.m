//
//  INOCustomWindow.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2/24/2014.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOCustomWindow.h"
#import "INAppStoreWindow.h"
#import "MUNThemeManager.h"
#import "MUNTitleHeaderView.h"
#import "MUNUser.h"

@implementation INOCustomWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    
    self.titleBarHeight = 85;
    
    self.showsTitle = YES;
    self.verticallyCenterTitle = NO;
    self.centerFullScreenButton = NO;
    self.centerTrafficLightButtons = NO;
    
    
    [self configureWindowStyle];
    
    
    return self;
    
}


- (void)configureWindowStyle
{
    self.titleFont = [[MUNThemeManager sharedManager] themeFontHeader];
    self.titleTextColor = [[MUNThemeManager sharedManager] bodyTextColor];
    self.trafficLightButtonsTopMargin = 12;
    
    NSShadow * titleShadow = [[NSShadow alloc] init];
    titleShadow.shadowColor = [[MUNThemeManager sharedManager] bodyTextColor];
    titleShadow.shadowBlurRadius = 0;
    titleShadow.shadowOffset = NSMakeSize(0, 0);
    self.titleTextShadow = titleShadow;
    
    self.titleBarStartColor = [[MUNThemeManager sharedManager] titleBarStartColor];
    self.titleBarEndColor = [[MUNThemeManager sharedManager] titleBarEndColor];
    self.baselineSeparatorColor = [[MUNThemeManager sharedManager] titleBorderColor];
    
    self.inactiveTitleBarStartColor = [[MUNThemeManager sharedManager] titleInactiveBarStartColor];
    self.inactiveTitleBarEndColor = [[MUNThemeManager sharedManager] titleInactiveBarEndColor];
    self.inactiveTitleTextColor = [[MUNThemeManager sharedManager] datelineTextColor];
    
    NSShadow * titleInactiveShadow = [[NSShadow alloc] init];
    titleInactiveShadow.shadowColor = [[MUNThemeManager sharedManager] lowToneColor];
    titleInactiveShadow.shadowBlurRadius = 0;
    titleInactiveShadow.shadowOffset = NSMakeSize(0, 0);
    self.inactiveTitleTextShadow = titleInactiveShadow;

}


@end
