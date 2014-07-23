//
//  MUNNewUserToken.h
//  ThreadOne
//
//  Created by Aaron Vegh on 11/24/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MUNNewUserToken : NSView

@property (readwrite, strong) ANKUser * user;

- (id)initWithFrame:(NSRect)frame User:(ANKUser*)user;
@end
