//
//  INOCustomWindow.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2/24/2014.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INAppStoreWindow.h"
@class MUNTitleHeaderView;

@interface INOCustomWindow : INAppStoreWindow

@property (strong, readwrite) MUNTitleHeaderView *titleHeaderView;

- (void)configureWindowStyle;

@end
