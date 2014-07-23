//
//  MUNComposeTextView.m
//  ThreadOne
//
//  Created by Aaron Vegh on 11/11/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNComposeTextView.h"
#import "INOMessageViewController.h"

@implementation MUNComposeTextView

- (void)awakeFromNib
{
    self.font = [NSFont fontWithName:@"Avenir" size:13.0];
    self.textContainerInset = NSMakeSize(0, 3);
}

- (BOOL)textView:(NSTextView *)view shouldChangeTextInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSLog(@"Characters: %@", replacementString);
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    NSString *characters;
    characters = [event characters];
    if ([characters length] > 0) {
        unichar character;
        character = [characters characterAtIndex: 0];
        NSUInteger modFlags = [NSEvent modifierFlags];
        if ((character == NSCarriageReturnCharacter || character == NSEnterCharacter) && (modFlags != NSShiftKeyMask)) {
            if (self.messageVC) {
                [self.messageVC sendMessage:nil];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sendNewChatMessage" object:self];
            }
        }
        else if (character == NSLeftArrowFunctionKey) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"remoteSwitchToChats" object:nil];
        }
        else {
            [super keyDown:event];
        }

    }
    else {
        [super keyDown:event];
    }
}

@end
