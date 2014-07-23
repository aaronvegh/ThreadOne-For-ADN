//
//  INOADNSocketController.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-08.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOADNSocketController.h"
#import <SocketRocket/SRWebSocket.h>
#import "MUNUser.h"

@interface INOADNSocketController ()

@property (readwrite, nonatomic) SRWebSocket * webSocket;

@end

@implementation INOADNSocketController

- (id)init
{
    if (self = [super init]) {
        NSMutableURLRequest * socketRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"wss://stream-channel.app.net/stream/user?auto_delete=1&include_annotations=1"]];
        
        [socketRequest setValue:[NSString stringWithFormat:@"BEARER %@", [[MUNUser sharedInstance] accessToken]] forHTTPHeaderField:@"Authorization"];
        
        self.webSocket = [[SRWebSocket alloc] initWithURLRequest:socketRequest];
        self.webSocket.delegate = self;
        
        [self.webSocket open];

    }
    
    return self;
}

- (void)dealloc
{
    self.webSocket.delegate = nil;
    self.webSocket = nil;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    //NSLog(@"Connection Manager Websocket Connected");
    
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    //NSLog(@"Connection Manager Websocket Failed With Error %@", error);
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSError * e;
    NSDictionary * returnMessage = [NSJSONSerialization JSONObjectWithData: [message dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options: NSJSONReadingMutableContainers
                                                                     error: &e];
    if (![returnMessage valueForKey:@"data"]) {
        self.connectionId = [[returnMessage valueForKey:@"meta"] valueForKey:@"connection_id"];
        [self subscribeToChannels];
    }
    else if ([returnMessage[@"meta"][@"type"] isEqualToString:@"message"]) {
        ANKMessage *newMessage = [[ANKMessage alloc] initWithJSONDictionary:[[returnMessage valueForKey:@"data"] objectAtIndex:0]];
        
        if (![newMessage.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]]) {
            
            // TODO: put the sound feedback in a smarter place, nimwit.
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"] isEqualToString:@"none"] && ![[[NSUserDefaults standardUserDefaults] valueForKey:@"soundTypeOption"] isEqualToString:@"notifications"]) {
                
                NSString *audioFile;
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"] isEqualToString:@"ThreadOne"]) {
                    audioFile = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], @"01_descending"];
                }
                else {
                    audioFile = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], @"ZoopDown"];
                }
                
                NSData *audioData = [NSData dataWithContentsOfFile:audioFile options:NSDataReadingMappedIfSafe error:nil];
                NSSound *zoopDown = [[NSSound alloc] initWithData:audioData];
                [zoopDown play];
            }
            
            
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            [notification setTitle:[NSString stringWithFormat:@"%@ says", newMessage.user.username]];
            [notification setInformativeText:newMessage.text];
            [notification setDeliveryDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]]];
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"] isEqualToString:@"none"] && [[[NSUserDefaults standardUserDefaults] valueForKey:@"soundTypeOption"] isEqualToString:@"notifications"]) {
                [notification setSoundName:@"ZoopDown"];
            }
            NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
            [center scheduleNotification:notification];
            
        }
        else {
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"] isEqualToString:@"none"] && ![[[NSUserDefaults standardUserDefaults] valueForKey:@"soundTypeOption"] isEqualToString:@"notifications"]) {
                
                NSString *audioFile;
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"] isEqualToString:@"ThreadOne"]) {
                    audioFile = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], @"01_ascending"];
                }
                else { //([[[NSUserDefaults standardUserDefaults] valueForKey:@"sounds"] isEqualToString:@"Munenori"]) {
                    audioFile = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], @"ZoopUp"];
                }
                
                NSData *audioData = [NSData dataWithContentsOfFile:audioFile options:NSDataReadingMappedIfSafe error:nil];
                NSSound *zoopUp = [[NSSound alloc] initWithData:audioData];
                [zoopUp play];
                
                //[self hideLoadingViewWithMessage:newMessage];
            }
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newIncomingMessageFromADN" object:nil];
    
    }
    else if ([returnMessage[@"meta"][@"type"] isEqualToString:@"channel"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newIncomingMessageFromADN" object:nil];
    }
    
    //NSLog(@"Message received: %@", message);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    //NSLog(@"Connection Manager Socket closed. Code: %ld, Reason: %@", (long)code, reason);
    self.webSocket = nil;
}

- (void)subscribeToChannels
{
    // subscribe to channels
    AFHTTPClient * subClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://alpha-api.app.net"]];
    [subClient setDefaultHeader:@"Accept" value:@"application/json"];
    [subClient setDefaultHeader:@"Content-Type" value:@"application/json"];
    [subClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", [[MUNUser sharedInstance] accessToken]]];

    NSDictionary * streamIDDict = @{@"connection_id" : self.connectionId, @"include_marker" : @1, @"channel_types" : @"net.app.core.pm"};
    
    [subClient getPath:@"/stream/0/channels" parameters:streamIDDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
       //NSLog(@"Got channels: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: robust, stellar error checking and responses.
        //NSLog(@"Got failure: %@", error);
    }];

}

@end
