//
//  INOADNSocketController.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-08.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

@protocol INOSocketDelegate <NSObject>

- (void)socketDidDisconnect;

@end

@interface INOADNSocketController : NSObject <SRWebSocketDelegate>

@property (strong, readwrite) NSString * connectionId;
@property (strong, readwrite) id<INOSocketDelegate> socketDelegate;

@end
