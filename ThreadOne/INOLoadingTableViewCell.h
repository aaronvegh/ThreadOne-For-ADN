//
//  INOLoadingTableViewCell.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-11.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ITProgressIndicator;

@interface INOLoadingTableViewCell : NSTableCellView

@property (readwrite, strong) IBOutlet ITProgressIndicator * indicator;

@end
