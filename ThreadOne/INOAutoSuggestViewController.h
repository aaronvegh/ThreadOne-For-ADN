//
//  INOAutoSuggestViewController.h
//  INOTokenMaker
//
//  Created by Aaron Vegh on 10/21/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INOAutoSuggestPopoverView.h"
@class INOAutoSuggestTableView;

@interface INOAutoSuggestViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil partialText:(NSString*)text sender:(NSTextField*)sender;
- (NSMutableString*)userStringFromArray;
- (ANKUser*)userForSelectionIndex:(NSInteger)index;
- (NSRange)rangeForSelectionIndex:(NSInteger)index;

@property (readwrite, strong) NSTextField * senderField;
@property (readwrite, strong) IBOutlet INOAutoSuggestPopoverView * popoverView;
@property (readwrite, strong) NSMutableArray * userArray;
@property (readwrite, strong) NSString * partialText;
@property (readwrite, strong) IBOutlet INOAutoSuggestTableView * tableView;
@property (readwrite, strong) NSMutableArray * chosenUserArray;

@end
