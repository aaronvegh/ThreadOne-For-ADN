//
//  NSData+NSData_MIMEType.h
//  ThreadOne
//
//  Created by Aaron Vegh on 2013-09-06.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSData_MIMEType)
+ (NSString *)contentTypeForImageData:(NSData *)data;
@end
