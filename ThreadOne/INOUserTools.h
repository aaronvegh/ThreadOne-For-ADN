//
//  INOUserTools.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-03.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INOUserTools : NSObject

+ (id)sharedTools;
- (void)saveAvatarForUser:(ANKUser*)user;
- (NSImage*)fetchAvatarForUser:(ANKUser*)user;

@end
