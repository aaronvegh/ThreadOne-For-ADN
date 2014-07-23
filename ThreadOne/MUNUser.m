//
//  MUNUser.m
//  Munenori
//
//  Created by Aaron Vegh on 2013-07-19.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNUser.h"
#import "SSKeychain.h"
#import "INOAppDelegate.h"

@implementation MUNUser

+ (MUNUser *)sharedInstance
{
    static MUNUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MUNUser alloc] init];
    });
    return sharedInstance;
}

- (BOOL)updateAuthenticationToken:(NSString *)token forUserID:(NSString *)userID
{
    BOOL success = NO;
    
    if ([token isEqualToString:@""]) {
        success = [SSKeychain deletePasswordForService:kADNAccessId account:userID];
    } else {
        success = [SSKeychain setPassword:token forService:@"ThreadOne" account:userID];
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:userID forKey:@"username"];
        [prefs synchronize];
    }
    
    return success;
}

- (NSString *)accessToken
{
    if (!_accessToken) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"]) {
            NSString *keychainToken = [SSKeychain passwordForService:@"ThreadOne" account:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
            if (keychainToken) {
                _accessToken = keychainToken;
            }
        }
        
    }
    return _accessToken;
}

- (NSString*)userId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
}



@end
