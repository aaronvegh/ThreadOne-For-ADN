//
//  MUNUser.h
//  Munenori
//
//  Created by Aaron Vegh on 2013-07-19.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUNUser : NSObject
@property (strong, nonatomic) NSString *accessToken;

+ (MUNUser *)sharedInstance;

- (BOOL)updateAuthenticationToken:(NSString *)token forUserID:(NSString *)userID;
- (NSString*)userId;

@end
