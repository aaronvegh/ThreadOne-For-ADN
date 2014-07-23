//
//  MUNNewUserToken.m
//  ThreadOne
//
//  Created by Aaron Vegh on 11/24/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNNewUserToken.h"
#import "ANKUser.h"
#import "INOUserTools.h"

@implementation MUNNewUserToken

- (id)initWithFrame:(NSRect)frame User:(ANKUser*)user
{
    if (self = [super initWithFrame:frame]) {
        self.user = user;

        NSImageView * imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        imageView.image = [[INOUserTools sharedTools] fetchAvatarForUser:self.user];
        
        NSAttributedString * usernameString = [[NSAttributedString alloc] initWithString:[[self.user username] mutableCopy] attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Avenir" size:14.0]}];
        
        NSRect usernameSize = [usernameString boundingRectWithSize:NSMakeSize(100, 100) options:NSStringDrawingUsesLineFragmentOrigin];
        
        NSTextField * textField = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 0, usernameSize.size.width + 40, 22)];
        [textField setBackgroundColor:[NSColor clearColor]];
        [textField setBordered:NO];
        [textField setEditable:NO];
        textField.attributedStringValue = usernameString;
        
        [self addSubview:textField];
        [self addSubview:imageView];
        
        self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, usernameSize.size.width + 30, 22);
    }
    
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"User: %@, Frame: %@", self.user.username, NSStringFromRect(self.frame)];
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    NSBezierPath * borderPath = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:3.0 yRadius:3.0];
//    
//    [[NSColor grayColor] set];
//    [borderPath fill];
//
//}


@end
