//
//  NSData+NSData_MIMEType.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-09-06.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "NSData+NSData_MIMEType.h"

@implementation NSData (NSData_MIMEType)

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

@end
