//
//  INONewPostLoadingView.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-04-21.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface INONewPostLoadingView : NSTableView <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, readwrite) NSMutableArray * loadingMessages;

@end
