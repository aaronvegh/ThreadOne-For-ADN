//
//  INONewPostLoadingView.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-04-21.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INONewPostLoadingView.h"
#import "MUNThemeManager.h"
#import "MUNTheirMessageTableViewCell.h"
#import "HyperlinkTextField.h"
#import "INOUserTools.h"
#import "INOMessageTools.h"

@interface INONewPostLoadingView ()

@property (readwrite, strong) NSMutableParagraphStyle * myMessageParagraphStyle;
@property (readwrite, strong) NSMutableParagraphStyle * myTitleParagraphStyle;

@end

@implementation INONewPostLoadingView

- (id)init
{
    if (self = [super init]) {
        self.loadingMessages = [NSMutableArray array];
        
        self.myMessageParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        self.myMessageParagraphStyle.alignment = NSRightTextAlignment;
        self.myMessageParagraphStyle.minimumLineHeight = 14;
        self.myMessageParagraphStyle.maximumLineHeight = 18;
        self.myMessageParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.myTitleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        self.myTitleParagraphStyle.alignment = NSRightTextAlignment;
        
        NSNib *myNib = [[NSNib alloc] initWithNibNamed:@"MUNMyMessageTableViewCell" bundle:nil];
        [self registerNib:myNib forIdentifier:@"myMessageView"];
    }
    
    return self;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.loadingMessages.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    ANKMessage * thisMessage = [self.loadingMessages objectAtIndex:row];
    
    MUNTheirMessageTableViewCell * result = [tableView makeViewWithIdentifier:@"myMessageView" owner:self];
    result.me = YES;
    result.messageField.me = YES;
    
    NSMutableAttributedString * thisMessageAttributedString = [[NSMutableAttributedString alloc] initWithString:thisMessage.text attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontBody], NSParagraphStyleAttributeName : self.myMessageParagraphStyle, NSForegroundColorAttributeName : [[MUNThemeManager sharedManager] bodyTextColor]}];
    
    result.thisMessage = thisMessage;
    
    [result.messageField setAttributedStringValue:thisMessageAttributedString];
    
    result.avatarView.image = [[INOUserTools sharedTools] fetchAvatarForUser:thisMessage.user];
    
    [result.avatarView setWantsLayer:YES];
    result.avatarView.layer.cornerRadius = 5.0;
    result.avatarView.layer.masksToBounds = YES;
    result.avatarView.layer.borderColor = [[NSColor grayColor] CGColor];
    result.avatarView.layer.borderWidth = 1.0;
    
    NSMutableAttributedString * displayName = [[NSMutableAttributedString alloc] initWithString:[thisMessage.user name] attributes:@{NSForegroundColorAttributeName : [[MUNThemeManager sharedManager] bodyTextColor]}];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"usernameDisplay"] boolValue]) {
        [displayName appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" @%@", [thisMessage.user username]] attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontSmaller], NSForegroundColorAttributeName : [[MUNThemeManager sharedManager] bodyTextColor]}]];
        
    }
    
    [displayName addAttribute:NSParagraphStyleAttributeName value:self.myTitleParagraphStyle range:NSMakeRange(0, [[displayName string] length])];
    
    result.userName.attributedStringValue = displayName;
    
    
    return result;

    
}


- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    ANKMessage * thisMessage = [self.loadingMessages objectAtIndex:row];
    if (thisMessage) {
        if (thisMessage.isDeleted) {
            return 0;
        }
        else {
            CGSize rectSize = NSMakeSize(tableView.frame.size.width - 132, 0);
            CGFloat messageFrameHeight = [self calculateIdealHeightForSize:rectSize content:thisMessage.text];
            if ([thisMessage.annotations count] > 0) {
                return MAX(messageFrameHeight + 70, 85);
            }
            else {
                return messageFrameHeight + 55;
            }
            
            
        }
        
    }
    else {
        return 0;
    }
}

- (CGFloat)calculateIdealHeightForSize:(NSSize)size content:(NSString*)content
{
    NSAttributedString * thisMessageAttributedString = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontBody], NSParagraphStyleAttributeName : self.myMessageParagraphStyle, NSForegroundColorAttributeName : [NSColor blackColor]}];
    
    NSRect headerRect = [thisMessageAttributedString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin];
    CGFloat minHeight = ceil(headerRect.size.height);
    
    return minHeight;
}

@end
