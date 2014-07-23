//
//  MUNChannelTableView.h
//  Munenori
//
//  Created by Aaron Vegh on 2013-08-16.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MUNChannelTableEventDelegate <NSObject>

- (void)openChannelCommand;

@end
//
//@protocol MUNChannelTableEventDelegate;

@interface MUNChannelTableView : NSTableView

@property (weak, atomic) id <MUNChannelTableEventDelegate> tableDelegate;

@end

