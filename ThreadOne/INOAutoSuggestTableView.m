//
//  INOAutoSuggestTableView.m
//  INOTokenMaker
//
//  Created by Aaron Vegh on 10/27/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "INOAutoSuggestTableView.h"
#import "INOAppDelegate.h"
#import "INOAutoSuggestViewController.h"
#import "MUNNewUserToken.h"

@implementation INOAutoSuggestTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
    }
    return self;
}

- (void)keyUp:(NSEvent *)event
{
    NSString *characters;
    characters = [event characters];
    
    unichar character;
    character = [characters characterAtIndex: 0];
    
    INOAutoSuggestViewController * vc = (INOAutoSuggestViewController*)self.dataSource;
    
    if (character == NSUpArrowFunctionKey) {
        if (self.selectedRow == 0) {
            [self resignFirstResponder];
            
            [[self window] makeFirstResponder:vc.senderField];
            NSText* textEditor = [self.window fieldEditor:YES forObject:vc.senderField];
            [textEditor setSelectedRange:NSMakeRange(vc.senderField.stringValue.length, 0)];
        }
    }
    else if (character == NSCarriageReturnCharacter || character == NSEnterCharacter) {
        
        [self chooseUser];
    
    }
    
    [super keyUp:event];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    
    NSInteger clickedRow = [self rowAtPoint:localLocation];
    
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:clickedRow] byExtendingSelection:NO];

    [self chooseUser];
    
    [super mouseDown:theEvent];
}

- (void)chooseUser
{
    INOAutoSuggestViewController * vc = (INOAutoSuggestViewController*)self.dataSource;
    
    ANKUser * newUser = [[vc userArray] objectAtIndex:[self.selectedRowIndexes firstIndex]];
    
    [vc.chosenUserArray addObject:newUser];
    
    [self resignFirstResponder];
    
    // create token and add to userDisplayView
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShowUsers" object:nil];
    
    [vc.view setHidden:YES];
}

@end
