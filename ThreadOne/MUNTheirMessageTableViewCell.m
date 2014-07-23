//
//  MUNMessageTableViewCell.m
//  Munenori
//
//  Created by Aaron Vegh on 2013-08-16.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "MUNTheirMessageTableViewCell.h"
#import "MUNVariableHeightTextField.h"
#import "MUNImageAttachmentButton.h"
#import "MUNThemeManager.h"
#import "HyperlinkTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "INOAppDelegate.h"
#import "INOWindowController.h"
#import "PVAsyncImageView.h"
#import "INOMessageTools.h"

@implementation MUNTheirMessageTableViewCell

@synthesize me = _me;

- (NSString*)description
{
    return [NSString stringWithFormat:@"Frame: %@", NSStringFromRect(self.frame)];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.horizontalRule setWantsLayer:YES];
    [self.backgroundView setWantsLayer:YES];
    
    NSShadow * viewShadow = [[NSShadow alloc] init];
    viewShadow.shadowBlurRadius = 0.5;
    viewShadow.shadowColor = [[MUNThemeManager sharedManager] chatShadowColor];
    viewShadow.shadowOffset = NSMakeSize(0, -1);
    [self.backgroundView setShadow:viewShadow];
    
    if (self.me) {
        self.backgroundView.layer.backgroundColor = [[[MUNThemeManager sharedManager] highToneColor] CGColor];
        self.horizontalRule.layer.backgroundColor = [[[MUNThemeManager sharedManager] highToneDividerColor] CGColor];
    }
    else {
        self.backgroundView.layer.backgroundColor = [[[MUNThemeManager sharedManager] lowToneColor] CGColor];
        self.horizontalRule.layer.backgroundColor = [[[MUNThemeManager sharedManager] lowToneDividerColor] CGColor];
    }
    
}

- (void)generateImageAttachmentView
{
    
    if ([self.thisMessage.annotations count] > 0) {
        ANKAnnotation *annotation = self.thisMessage.annotations[0];
        if ([annotation.type isEqualToString:@"net.app.core.oembed"]) {
            
            // get the attachment from the local cache
            NSString * cacheDirectory = [NSString stringWithFormat:@"%@/%@", [[INOMessageTools sharedTools] cacheDirectoryForAttachments], self.thisMessage.messageID];
            
            NSString * thumbnail_path = [cacheDirectory stringByAppendingString:@"/thumb"];
            NSString * regular_path = [cacheDirectory stringByAppendingString:@"/regular"];
            
            NSImage * thumbnailImage = [[NSImage alloc] initWithContentsOfFile:thumbnail_path];
            NSImage * regularImage = [[NSImage alloc] initWithContentsOfFile:regular_path];
            
            PVAsyncImageView * imageButton = [[PVAsyncImageView alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
            
            [imageButton setWantsLayer:YES];
            imageButton.layer.cornerRadius = 3.0;
            imageButton.layer.borderWidth = 1.0;
            imageButton.layer.borderColor = [[[MUNThemeManager sharedManager] highlightColor] CGColor];
            imageButton.layer.shadowColor = [[[MUNThemeManager sharedManager] chatShadowColor] CGColor];
            imageButton.layer.shadowOffset = NSMakeSize(2.0, 2.0);
            imageButton.layer.shadowRadius = 3.0;
            [imageButton setImageScaling:NSScaleToFit];
            if (thumbnailImage) {
                imageButton.image = thumbnailImage;
            }
            else {
                [imageButton downloadImageFromURL:annotation.value[@"thumbnail_url"] withPlaceholderImage:nil errorImage:[NSImage imageNamed:@"failedAttachment"] andDisplaySpinningWheel:YES];
            }
            
            [self.attachmentView addSubview:imageButton];
            
            
            MUNImageAttachmentButton * buttonAction = [[MUNImageAttachmentButton alloc] initWithFrame:NSMakeRect(0, 0, 35, 35) image:regularImage];
            buttonAction.regularPath = annotation.value[@"url"];
            buttonAction.imageSize = NSMakeSize([annotation.value[@"width"] floatValue], [annotation.value[@"height"] floatValue]);
            buttonAction.transparent = YES;
            [buttonAction setTarget:(INOWindowController*)[[NSApp delegate] windowController]];
            [buttonAction setAction:@selector(showImage:)];
            [self.attachmentView addSubview:buttonAction];
        
        }

    }
}

- (void)loadButtonImage:(id)sender
{
    NSImage * attachmentImage = [[NSImage alloc] initWithContentsOfURL:sender[@"URL"]];
    if (attachmentImage) {
        [self performSelectorOnMainThread:@selector(setButtonImage:) withObject:@{@"button" : sender[@"button"], @"image" : attachmentImage} waitUntilDone:YES];
    }
}

- (void)setButtonImage:(id)sender
{
    MUNImageAttachmentButton * button = sender[@"button"];
    NSImage * attachmentImage = sender[@"image"];
    [attachmentImage setSize:NSMakeSize(35, 35)];
    [button setImage:attachmentImage];
    attachmentImage = nil;
}


@end
