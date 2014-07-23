//
//  MUNChannelTableViewCell.m
//  Munenori
//
//  Created by Aaron Vegh on 2013-06-29.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNChannelTableViewCell.h"
#include <QuartzCore/QuartzCore.h>
#import "MUNThemeManager.h"
#import "UIImageView+AFNetworking.h"


@implementation MUNChannelTableViewCell

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)awakeFromNib
{
    self.titleField.font = [[MUNThemeManager sharedManager] themeFontHeader];
    self.lastMessage.font = [[MUNThemeManager sharedManager] themeFontBody];
    self.titleField.textColor = [[MUNThemeManager sharedManager] bodyTextColor];
    self.lastMessage.textColor = [[MUNThemeManager sharedManager] bodyTextColor];
}

- (void)generateAvatarView:(ANKChannel*)channel
{
    self.avatarView.subviews = [NSArray array];
    [self.avatarView setWantsLayer:YES];

    NSMutableArray * writers = [channel.writers.userIDs mutableCopy];
    [writers addObject:channel.owner.userID];
    
    [writers removeObject:[[ANKClient sharedClient] authenticatedUser].userID];
    
    NSInteger counter = 0;
    for (NSString * userId in writers) {
        if (counter < 2 && writers.count < 4) {
            NSImageView * avatar = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 50 - (counter * 35), 30, 30)];
            NSImage *avatarImage;
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
            
            NSString *newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ThreadOne/avatars/%@", userId]];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:NO]) {
                avatarImage = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:newPath]];
            }
            else {
                avatarImage = [NSImage imageNamed:@"generic-icon.png"];
            }
            
            
            avatar.image = avatarImage;
            avatarImage = nil;
            [avatar setWantsLayer: YES];
            avatar.layer.cornerRadius = 5.0;
            avatar.layer.masksToBounds = YES;
            
            [self.avatarView addSubview:avatar];

            avatar = nil;
        }
        else if (counter == 2) {
            NSView * numView = [[NSView alloc] initWithFrame:NSMakeRect(0, 50 - (counter * 35), 30, 30)];
            [numView setWantsLayer:YES];
            numView.layer.backgroundColor = [[NSColor colorWithCalibratedRed:0.686 green:0.686 blue:0.686 alpha:1] CGColor];
            numView.layer.cornerRadius = 5.0;
            CATextLayer * numLayer = [CATextLayer layer];
            numLayer.anchorPoint = NSMakePoint(0, 0.125);
            numLayer.bounds = NSMakeRect(0, 0, 20, 20);
            numLayer.string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", writers.count] attributes:@{ NSFontAttributeName : [NSFont fontWithName:@"Avenir-Light" size:13.0], NSForegroundColorAttributeName : [NSColor whiteColor]}];
            numLayer.alignmentMode = kCAAlignmentCenter;
            [numView.layer addSublayer:numLayer];
            
            [self.avatarView addSubview:numView];
            
            numView = nil;
            
        }
        counter++;
    }
}

- (NSView*)unreadPip
{
    NSView * pipView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    [pipView setWantsLayer:YES];
    CALayer *layer = [CALayer layer];
    CGFloat radius = 5.0;
    [layer setBackgroundColor:[[NSColor colorWithCalibratedRed:0.078 green:0.478 blue:0.925 alpha:1] CGColor]];
    [layer setCornerRadius:radius];
    [layer setFrame:CGRectMake(0, 0, radius * 2, radius * 2)];
    [pipView.layer addSublayer:layer];
    return pipView;
}


@end
