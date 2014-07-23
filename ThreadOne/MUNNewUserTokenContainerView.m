//
//  MUNNewUserTokenContainerView.m
//  ThreadOne
//
//  Created by Aaron Vegh on 11/24/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNNewUserTokenContainerView.h"
#import "MUNNewUserToken.h"


@implementation MUNNewUserTokenContainerView


-(void)refreshView
{
    self.userDisplayView = [self superview];
    self.animationContainerView = [self.userDisplayView superview];
    
    self.subviews = [NSArray array];
    
    [self resizeDocumentView];
    
    float tokenOffsetX = 0;
    float tokenOffsetY = self.frame.size.height;
    int line = 1;
    
    ANKUser * lastUser = nil;
    for (ANKUser * user in self.tokenArray)
    {
        NSSize thisUserSize = [self tokenSizeForUser:user];
        NSSize lastUserSize = [self tokenSizeForUser:lastUser];
        
        tokenOffsetX = tokenOffsetX + lastUserSize.width + 5;
        tokenOffsetY = self.frame.size.height - (line * 30);
        
        if(tokenOffsetX + thisUserSize.width > self.frame.size.width)
        {
            line++;
            tokenOffsetX = 5;
            tokenOffsetY = self.frame.size.height - (line * 30);
        }
        
        NSRect newFrame = NSMakeRect(tokenOffsetX, tokenOffsetY + 5, thisUserSize.width, thisUserSize.height);
        
        MUNNewUserToken * token = [[MUNNewUserToken alloc] initWithFrame:newFrame User:user];
        
        [self addSubview:token];
        
        lastUser = user;
    }
    
}

-(void)resizeDocumentView
{
    CGFloat totalHeight = 0;
    CGFloat totalWidth  = 0;
    
    int requiredLines = 1;
    
    //NSLog(@"animationContainer frame: %@", NSStringFromRect(self.animationContainerView.frame));
    
    for (ANKUser * user in self.tokenArray)
    {
        NSAttributedString * usernameString = [[NSAttributedString alloc] initWithString:[[user username] mutableCopy] attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Avenir" size:14.0]}];
        
        NSRect usernameSize = [usernameString boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin];
        
        NSSize tokenSize = NSMakeSize(usernameSize.size.width + 40, 25);
        
        
        totalWidth += (5 + tokenSize.width);
        
        if(totalWidth  > self.frame.size.width)
        {
            requiredLines++;
            totalWidth = (5 + tokenSize.width);
        }
    }
    
    totalHeight = requiredLines * 30;
    
    NSRect animationContainerRect = self.animationContainerView.frame;
    
    if (requiredLines > 1) {
        animationContainerRect.size.height = totalHeight;
        animationContainerRect.origin.y = self.window.frame.size.height - 105 - totalHeight;
    }
    else {
        animationContainerRect.size.height = 30;
        animationContainerRect.origin.y = self.window.frame.size.height - 105 - 30;
    }
    
    [self.animationContainerView setFrame:animationContainerRect];
    
    NSRect userDisplayRect = self.userDisplayView.frame;
    userDisplayRect.size.height = totalHeight;
    userDisplayRect.origin.y = 0;
    [self.userDisplayView setFrame:userDisplayRect];
    //NSLog(@"userDisplayFrame: %@", NSStringFromRect(self.userDisplayView.frame));
    
    NSRect thisRect = self.frame;
    thisRect.size.height = totalHeight;
    [self setFrame:thisRect];
    //NSLog(@"thisFrame: %@", NSStringFromRect(self.frame));

    
    //NSLog(@"now animationContainer frame: %@", NSStringFromRect(self.animationContainerView.frame));
    
}

- (NSSize)tokenSizeForUser:(ANKUser*)user
{
    NSSize tokenSize;
    if (user) {
        NSAttributedString * usernameString = [[NSAttributedString alloc] initWithString:[[user username] mutableCopy] attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Avenir" size:14.0]}];
        
        NSRect usernameSize = [usernameString boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin];
        
        tokenSize = NSMakeSize(usernameSize.size.width + 40, 25);
    }
    else {
        tokenSize = NSMakeSize(0, 0);
    }
    
    return tokenSize;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint center = [self convertPoint:eventLocation fromView:nil];
    
    for (MUNNewUserToken *subView in [self subviews]) {
        
        if ([self mouse:center inRect:subView.frame]) {
            
            // send a notification to remove the user from the array
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeUserFromChosenUsers" object:self userInfo:@{@"userObj":[subView user]}];
        }
    }
    
    [self refreshView];
    
}



@end
