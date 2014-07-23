//
//  INOMessageTools.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-03.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MessageFetchStateFirstRun,
    MessageFetchStateUpdateThread,
    MessageFetchStateIncoming
} MessageFetchState;

@interface INOMessageTools : NSObject

+ (id)sharedTools;
- (void)getMessagesForChannel:(ANKChannel*)channel usingClient:(ANKClient*)thisMessageClient withFetchState:(MessageFetchState)state;
- (NSString*)timeAgo:(ANKMessage*)message;
- (NSString*)cacheDirectoryForAttachments;

@property (readwrite, assign) MessageFetchState * fetchState;

@end
