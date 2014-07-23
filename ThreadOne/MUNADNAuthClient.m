//
//  MUNADNAuthClient.m
//  Munenori
//
//  Created by Aaron Vegh on 2013-08-23.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNADNAuthClient.h"
#import "AFJSONRequestOperation.h"
#import "INOAppDelegate.h"
//#import "MUNUser.h"

static NSString * const kAFAppDotNetAuthBaseURLString = @"https://account.app.net/";

@implementation MUNADNAuthClient

+ (MUNADNAuthClient *)sharedClient {
    static MUNADNAuthClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MUNADNAuthClient alloc] initWithBaseURL:[NSURL URLWithString:kAFAppDotNetAuthBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    

	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Content-Type" value:@"application/json"];
    
    return self;
}


@end
