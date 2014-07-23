//
//  INOChatViewController.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-02-25.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MUNChannelTableView.h"

@interface INOChatViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, MUNChannelTableEventDelegate>

@property (weak, nonatomic) IBOutlet MUNChannelTableView * channelTable;
@property (readwrite, strong) NSMutableArray * channelData;

- (void)loadDataForChannelTable;

@end
