//
//  MUNBluePillButton.m
//  ThreadOne
//
//  Created by Aaron Vegh on 1/1/2014.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "MUNBluePillButton.h"
#import "MUNThemeManager.h"

@implementation MUNBluePillButton

- (void)awakeFromNib
{
    NSMutableParagraphStyle * buttonTitleStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    buttonTitleStyle.alignment = NSCenterTextAlignment;
    NSDictionary * att = @{NSParagraphStyleAttributeName : buttonTitleStyle, NSForegroundColorAttributeName : [NSColor whiteColor], NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontBody]};
    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:self.title attributes:att]];
}

- (BOOL)wantsUpdateLayer
{
    return YES;
}

- (void)updateLayer
{
    self.layer.cornerRadius = 15.0;
    if ([self.cell isHighlighted]) {
        self.layer.backgroundColor = [[[MUNThemeManager sharedManager] highToneColor] CGColor];
    }
    else {
        self.layer.backgroundColor = [[[MUNThemeManager sharedManager] highlightColor] CGColor];
    }
}


@end