//
//  INOMessageTools.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-03.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOMessageTools.h"

@implementation INOMessageTools

/* TODO: Yes, more local plist files for caching. Core Data. Yes. Yes. */

+ (INOMessageTools *)sharedTools {
    static INOMessageTools *_sharedTools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTools = [[INOMessageTools alloc] init];
    });
    
    return _sharedTools;
}

- (void)getMessagesForChannel:(ANKChannel*)channel usingClient:(ANKClient*)thisMessageClient withFetchState:(MessageFetchState)state
{
    ANKClient * messageClient;
    if (!thisMessageClient) {
        messageClient = [[ANKClient sharedClient] copy];
        messageClient.pagination = [ANKPaginationSettings settingsWithCount:50];
        messageClient.shouldRequestAnnotations = YES;
    }
    else {
        messageClient = thisMessageClient;
    }
    
    __block NSMutableArray * messageData = [NSMutableArray array];
    
    
    NSDictionary * cachedData = [self getCachedMessagesForChannel:[channel.channelID intValue]];
    if (cachedData.count > 0) {
        
        [messageData addObjectsFromArray:cachedData[@"data"]];
        
        if (state == MessageFetchStateIncoming) {
            messageClient.pagination.sinceID = cachedData[@"maxID"];
            messageClient.pagination.beforeID = nil;
        }
        else {
            messageClient.pagination.beforeID = cachedData[@"minID"];
            messageClient.pagination.sinceID = nil;
        }
    }
    
    
    if (!(state == MessageFetchStateFirstRun && messageData.count > 0)) {
        __block MessageFetchState fetchState = state;
        __weak INOMessageTools *weakSelf = self;
        [messageClient fetchMessagesInChannel:channel completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
            
            if (messageData.count > 0) {
                // pull any attachments from the messages and save locally
                for (ANKMessage * message in responseObject) {
                    
                    NSInteger checkIndex = [messageData indexOfObjectPassingTest:^BOOL(ANKMessage * objMessage, NSUInteger idx, BOOL *stop) {
                        return [objMessage.messageID isEqualToString:message.messageID];
                    }];
                    
                    if (checkIndex == NSNotFound) {
                        [self saveAttachmentsForMessage:message];
                        [messageData addObject:message];
                    }
                }
            }
            else {
                for (ANKMessage * message in responseObject) {
                    [messageData addObject:message];
                    [self saveAttachmentsForMessage:message];
                }
            }
            
            NSArray * resultArray;
            
            if ([responseObject count] > 0) {
                if (fetchState == MessageFetchStateFirstRun || fetchState == MessageFetchStateUpdateThread) {
                    // update the pagination so that the next fetch is for the next page of objects
                    messageClient.pagination.beforeID = meta.minID;
                }
                else if (fetchState == MessageFetchStateIncoming) {
                }
                
                messageClient.pagination.sinceID = meta.maxID;
                
                resultArray = [messageData sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"messageID" ascending:YES]]];
                
                [weakSelf saveMessages:resultArray toCacheForChannel:[channel.channelID intValue] withMinID:meta.minID andMaxID:meta.maxID];
            }
            else {
                resultArray = [messageData sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"messageID" ascending:YES]]];
            }
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveMessagesFromADN" object:@{@"client" : messageClient, @"data" : resultArray}];
        }];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveMessagesFromADN" object:@{@"client" : messageClient, @"data" : [messageData sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"messageID" ascending:YES]]] }];
    }
    
}


- (void)saveMessages:(NSArray*)messageData toCacheForChannel:(NSInteger)channel withMinID:(NSString*)minID andMaxID:(NSString*)maxID
{
    NSString * channelDataFilePath = [self cacheFileForChannel:channel];
    NSDictionary * data = @{@"minID" : minID, @"maxID" : maxID, @"data" : messageData};
    [NSKeyedArchiver archiveRootObject:data toFile:channelDataFilePath];
}

- (void)saveAttachmentsForMessage:(ANKMessage*)message
{
    NSString * attachmentDirectory = [self cacheDirectoryForAttachments];
    if ([message.annotations count] > 0) {
        ANKAnnotation *annotation = message.annotations[0];
        if ([annotation.type isEqualToString:@"net.app.core.oembed"]) {
            
            NSString * thumbnail_path = annotation.value[@"thumbnail_url"];
            NSString * path = annotation.value[@"url"];
            
            // create directory for message ID
            NSString * messagePath = [NSString stringWithFormat:@"%@/%@", attachmentDirectory, message.messageID];
            [[NSFileManager defaultManager] createDirectoryAtPath:messagePath withIntermediateDirectories:YES attributes:nil error:nil];
            
            // save thumb and regular images
            NSURLRequest *thumb_request = [NSURLRequest requestWithURL:[NSURL URLWithString:thumbnail_path]];
            AFHTTPRequestOperation *thumb_operation = [[AFHTTPRequestOperation alloc] initWithRequest:thumb_request];
            
            thumb_operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[messagePath stringByAppendingString:@"/thumb"] append:NO];
            
            [thumb_operation start];
            
            NSURLRequest *regular_request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
            AFHTTPRequestOperation *regular_operation = [[AFHTTPRequestOperation alloc] initWithRequest:regular_request];
            
            regular_operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[messagePath stringByAppendingString:@"/regular"] append:NO];
            
            [regular_operation start];

        }
    }
}

- (NSDictionary*)getCachedMessagesForChannel:(NSInteger)channel
{
    NSString * channelDataFilePath = [self cacheFileForChannel:channel];
    if ([[[NSFileManager defaultManager] contentsAtPath:channelDataFilePath] length]) {
        NSDictionary * channelData = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithFile:channelDataFilePath];
        return channelData;
    }
    else {
        return @{};
    }
    
}

- (NSString*)cacheFileForChannel:(NSInteger)channel
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *channelDataFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ThreadOne/channelData/%ld", (long)channel]];
    
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[channelDataFilePath stringByDeletingLastPathComponent] isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[channelDataFilePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:channelDataFilePath isDirectory:NO]) {
        [[NSFileManager defaultManager] createFileAtPath:channelDataFilePath contents:[NSData data] attributes:nil];
    }
    return channelDataFilePath;
}

- (NSString*)cacheDirectoryForAttachments
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *attachmentDirPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ThreadOne/attachments"];
    
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[attachmentDirPath stringByDeletingLastPathComponent] isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:attachmentDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return attachmentDirPath;
}


- (NSString*)timeAgo:(ANKMessage*)message
{
    NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:message.createdAt];
    
    NSString * response = @"";
    if (interval < 60) {
        response = [NSString stringWithFormat:@"%is ago", (int)interval];
    }
    else if (interval > 59 && interval < (60 * 60)) {
        response = [NSString stringWithFormat:@"%im ago", (int)interval / 60];
    }
    else if (interval > (60 * 60) - 1 && interval < (60 * 60 * 24)) {
        response = [NSString stringWithFormat:@"%ih ago", (int)interval / 3600];
    }
    else if (interval > (60 * 60 * 24) - 1 && interval < (60 * 60 * 24 * 7)) {
        response = [NSString stringWithFormat:@"%id ago", (int)interval / 86400];
    }
    else if (interval > (60 * 60 * 24 * 7) - 1 && interval < (60 * 60 * 24 * 365)) {
        response = [NSString stringWithFormat:@"%iw ago", (int)interval / 604800];
    }
    else {
        response = [NSString stringWithFormat:@"%iy ago", (int)interval / 31536000];
    }
    
    return response;
}

@end
