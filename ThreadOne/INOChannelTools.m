//
//  INOChannelTools.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-02-26.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOChannelTools.h"
#import "INOUserTools.h"
#import "MUNUser.h"

@implementation INOChannelTools

/* TODO: Yes, I'm caching the Channels in local plist files. Yes, Core Data, I know. */

+ (INOChannelTools *)sharedTools {
    static INOChannelTools *_sharedTools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTools = [[INOChannelTools alloc] init];
    });
    
    return _sharedTools;
}

- (void)getChannels
{
    ANKClient *paginatedClient = [[ANKClient sharedClient] copy];
    ANKGeneralParameters * params = [[ANKGeneralParameters alloc] init];
    params.includeRecentMessage = YES;
    paginatedClient.generalParameters = params;
    
    __block BOOL isMore = YES;
    __block NSMutableArray * channelData = [NSMutableArray array];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("paginationQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        
        while (isMore) {
            [paginatedClient fetchCurrentUserPrivateMessageChannelsWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
                
                [channelData addObjectsFromArray:responseObject];
                
                // update the pagination so that the next fetch is for the next page of objects
                paginatedClient.pagination.beforeID = meta.minID;
                
                // update isMore to reflect if there is more data available
                isMore = [[NSNumber numberWithInt:meta.moreDataAvailable] boolValue];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveChannelsFromADN" object:channelData];
                
                dispatch_semaphore_signal(semaphore);

            }];
            
            // wait for the signal from the completion block
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        
        
    });
    
 
}

- (void)channelName:(ANKChannel*)channel
{
    
    __block NSString * channelName = @"";
    
    NSMutableArray * writers = [channel.writers.userIDs mutableCopy];
    
    if (channel.owner) { // turns out if the account has been deleted, this object may not exist!
        [writers addObject:channel.owner.userID];
    }
    
    NSMutableString * chatters = [NSMutableString string];
    
    
    if ([[self getTitleForChannel:channel] length] > 0) {
        NSDictionary * returnData = @{@"channelId" : channel.channelID, @"name" : [self getTitleForChannel:channel]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveChannelNameFromADN" object:returnData];
    }
    else {
        // get the names of the chatters and concatenate their first names in
        [[ANKClient sharedClient] fetchUsersWithIDs:writers completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
            
            for (ANKUser * user in responseObject) {
                if (![user.username isEqual:[[ANKClient sharedClient] authenticatedUser].username]) {
                    [chatters appendFormat:@"%@, ", [[user.name componentsSeparatedByString:@" "] objectAtIndex:0]];
                }
                [[INOUserTools sharedTools] saveAvatarForUser:user];
            }
            
            if (chatters.length > 0) {
                channelName = (NSMutableString*)[chatters substringWithRange:NSMakeRange(0, [chatters length] - 2)];
                
                [self setTitle:channelName forChannel:channel];
                
                NSDictionary * returnData = @{@"channelId" : channel.channelID, @"name" : channelName};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveChannelNameFromADN" object:returnData];
            }
            
            
            
        }];
    }
    
    

}

- (NSString*)getTitleForChannel:(ANKChannel*)channel
{
    NSArray * channelData;
    NSString * title = [NSString string];
    
    NSString * filePath = [self cacheFileForChannels];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO]) {
        
        channelData = [[NSArray alloc] initWithContentsOfFile:filePath];
        
        NSPredicate * channelPredicate = [NSPredicate predicateWithFormat:@"channelID = %@", channel.channelID];
        if ([[channelData filteredArrayUsingPredicate:channelPredicate] count] > 0) {
            NSDictionary * result = [[channelData filteredArrayUsingPredicate:channelPredicate] objectAtIndex:0];
            title = result[@"title"];
        }
    }
    
    return title;
    
}

- (void)setTitle:(NSString*)title forChannel:(ANKChannel*)channel
{
    NSString * filePath = [self cacheFileForChannels];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO]) {
        
        NSDictionary * newChannelObject = @{@"channelID" : channel.channelID, @"title" : title};
        
        NSMutableArray * channelData = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        if (!channelData) {
            channelData = [NSMutableArray array];
        }
        
        NSDictionary * existingDictionary;
        
        NSPredicate * channelPredicate = [NSPredicate predicateWithFormat:@"channelID = %@", channel.channelID];
        if ([[channelData filteredArrayUsingPredicate:channelPredicate] count] > 0) {
            existingDictionary = [[channelData filteredArrayUsingPredicate:channelPredicate] objectAtIndex:0];
        }
        
        if (existingDictionary) {
            NSInteger objIndex = [channelData indexOfObject:existingDictionary];
            [channelData replaceObjectAtIndex:objIndex withObject:newChannelObject];
        }
        else {
            [channelData addObject:newChannelObject];
        }
        
        [channelData writeToFile:filePath atomically:YES];

    }
    
}

- (NSInteger)numberOfChatParticipants:(ANKChannel*)channel
{
    
    NSString * chatTitle = [self getTitleForChannel:channel];
    
    NSArray * participantArray = [chatTitle componentsSeparatedByString:@","];
    
    if ([participantArray count] > 0) {
        return [participantArray count] + 1;
    }
    else {
        return 2;
    }
    
}

- (void)unsubscribe:(ANKChannel*)channel
{
    [[ANKClient sharedClient] unsubscribeToChannel:channel completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didUnsubscribeFromChannel" object:nil];
        }
    }];
}

- (NSString*)cacheFileForChannels
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *channelDataFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ThreadOne/channelData.plist"];
    
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[channelDataFilePath stringByDeletingLastPathComponent] isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[channelDataFilePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:channelDataFilePath isDirectory:NO]) {
        [[NSFileManager defaultManager] createFileAtPath:channelDataFilePath contents:[NSData data] attributes:nil];
    }
    return channelDataFilePath;
}

@end
