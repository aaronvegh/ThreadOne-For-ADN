//
//  MUNNewChatTextField.m
//  ThreadOne
//
//  Created by Aaron Vegh on 11/17/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNNewChatTextField.h"

@implementation MUNNewChatTextField

- (void)keyUp:(NSEvent *)event
{
    NSString *characters;
    characters = [event characters];
    
    unichar character;
    character = [characters characterAtIndex: 0];
    
    if (character == NSDownArrowFunctionKey) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendArrowDown" object:nil];
    }
    else if (character == NSDeleteCharacter) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteInTextField" object:nil];
    }
    else if (character == NSCarriageReturnCharacter || character == NSEnterCharacter) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"createNewChannel" object:nil];
    }
}


@end
