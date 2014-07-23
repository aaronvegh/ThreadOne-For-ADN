//
//  MUNComposeTextView.h
//  ThreadOne
//
//  Created by Aaron Vegh on 11/11/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INOMessageViewController.h"

@interface MUNComposeTextView : NSTextView

@property (readwrite, strong) INOMessageViewController * messageVC;

@end
