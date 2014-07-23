//
//  INOChannelTools.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-02-26.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INOChannelTools : NSObject

+ (id)sharedTools;

- (void)getChannels;
- (void)channelName:(ANKChannel*)channel;
- (NSString*)getTitleForChannel:(ANKChannel*)channel;
- (NSInteger)numberOfChatParticipants:(ANKChannel*)channel;
- (void)unsubscribe:(ANKChannel*)channel;

@end
