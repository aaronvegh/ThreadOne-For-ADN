//
//  INOLoadingTableViewCell.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-11.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOLoadingTableViewCell.h"
#import "ITProgressIndicator.h"
#import "MUNThemeManager.h"

@implementation INOLoadingTableViewCell

-(void) awakeFromNib
{
    self.wantsLayer = YES;
    
    self.indicator.color = [[MUNThemeManager sharedManager] highlightColor];
    self.indicator.animates = YES;
    
}

@end
