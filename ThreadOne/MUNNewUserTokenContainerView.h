//
//  MUNNewUserTokenContainerView.h
//  ThreadOne
//
//  Created by Aaron Vegh on 11/24/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MUNNewUserTokenContainerView : NSView

@property (strong, readwrite) NSArray * tokenArray;
@property (strong, readwrite) NSView * userDisplayView;
@property (strong, readwrite) NSView * animationContainerView;

-(void)refreshView;
-(void)resizeDocumentView;

@end
