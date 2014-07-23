//
//  INOUserTools.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-03.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOUserTools.h"
#import "NSDate+Helper.h"

@implementation INOUserTools

+ (INOUserTools *)sharedTools {
    static INOUserTools *_sharedTools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTools = [[INOUserTools alloc] init];
    });
    
    return _sharedTools;
}

- (void)saveAvatarForUser:(ANKUser*)user
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    NSString *newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ThreadOne/avatars/%@", user.userID]];
    
    // set up avatars directory if it doesn't exist
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[newPath stringByDeletingLastPathComponent] isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[newPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL shouldDownload = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:NO]) {
        NSDictionary * fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
        if ([fileAttributes[@"NSFileModificationDate"] daysAgo] > 1) {
            shouldDownload = YES;
        }
    }
    else {
        shouldDownload = YES;
    }
    
    if (shouldDownload) {
        NSURLRequest *request = [NSURLRequest requestWithURL:user.avatarImage.URL];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:newPath append:NO];
        
        [operation start];
    }
    
}

- (NSImage*)fetchAvatarForUser:(ANKUser*)user
{
    NSImage * avatarImage;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    NSString *newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ThreadOne/avatars/%@", user.userID]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:NO]) {
        avatarImage = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:newPath]];
        
    }
    else {
        avatarImage = [[NSImage alloc] initWithContentsOfURL:user.avatarImage.URL];
    }
    
    
    return avatarImage;
}

@end
