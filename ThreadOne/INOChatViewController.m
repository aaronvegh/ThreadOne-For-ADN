//
//  INOChatViewController.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-02-25.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOAppDelegate.h"
#import "INOWindowController.h"
#import "MUNADNAuthClient.h"
#import "INOChatViewController.h"
#import "MUNChannelTableViewCell.h"
#import "INOChannelTools.h"
#import "INOMessageTools.h"
#import "MUNThemeManager.h"
#import "MUNSubduedTableRowView.h"
#import "MUNBluePillButton.h"
#import "MUNUser.h"
#import "MUNChannelTableView.h"
#import "INOMessageViewController.h"
#import "INOMessageTableView.h"
#import "INOLoadingTableViewCell.h"

@interface INOChatViewController ()

@property (readwrite, strong) INOAppDelegate * appDelegate;
@property (readwrite, strong) INOWindowController * windowController;

@property (readwrite, strong) NSMutableParagraphStyle * titleParagraphStyle;
@property (readwrite, strong) NSMutableParagraphStyle * myMessageParagraphStyle;
@property (readwrite, strong) NSMutableParagraphStyle * theirMessageParagraphStyle;

@property (readwrite, strong) IBOutlet NSPanel * loginSheet;
@property (readwrite, strong) IBOutlet NSTextField * loginMessage;
@property (readwrite, strong) IBOutlet NSTextField * loginChoiceText;
@property (readwrite, strong) IBOutlet NSTextField * username;
@property (readwrite, strong) IBOutlet NSTextField * password;
@property (readwrite, strong) AFJSONRequestOperation * authOperation;
@property (readwrite, strong) IBOutlet MUNBluePillButton * loginButton;

@end

@implementation INOChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.appDelegate = (INOAppDelegate*)[[NSApplication sharedApplication] delegate];
        self.windowController = self.appDelegate.windowController;
        
        self.channelData = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChannels:) name:@"receiveChannelsFromADN" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChannelName:) name:@"receiveChannelNameFromADN" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataForChannelTable) name:@"newIncomingMessageFromADN" object:nil];
        
        [self loadDataForChannelTable];
        [self.channelTable reloadData];
    
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveChannelsFromADN" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveChannelLatestMessageFromADN" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveChannelNameFromADN" object:nil];
}

- (void)awakeFromNib
{
    self.channelTable.tableDelegate = self;
    self.channelTable.delegate = self;
    self.channelTable.dataSource = self;
    
    self.titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    self.titleParagraphStyle.alignment = NSLeftTextAlignment;
    self.titleParagraphStyle.lineSpacing = 10.0;
    self.titleParagraphStyle.minimumLineHeight = 10;
    //self.titleParagraphStyle.maximumLineHeight = 30;
    self.titleParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.myMessageParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    self.myMessageParagraphStyle.alignment = NSRightTextAlignment;
    self.myMessageParagraphStyle.lineSpacing = 0.0;
    self.myMessageParagraphStyle.minimumLineHeight = 10;
    //self.myMessageParagraphStyle.maximumLineHeight = 15;
    self.myMessageParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.theirMessageParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    self.theirMessageParagraphStyle.alignment = NSLeftTextAlignment;
    self.theirMessageParagraphStyle.lineSpacing = 0.0;
    self.theirMessageParagraphStyle.minimumLineHeight = 10;
    //self.theirMessageParagraphStyle.maximumLineHeight = 15;
    self.theirMessageParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.channelTable.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
    
    if (![[MUNUser sharedInstance] accessToken]) {
        NSMutableParagraphStyle * titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        titleParagraphStyle.alignment = NSCenterTextAlignment;
        
        NSMutableAttributedString * choiceText = [[NSMutableAttributedString alloc] initWithString:@"ThreadOne is built with App.Net.\nLog in below, or sign up for a free account now." attributes:@{NSParagraphStyleAttributeName : titleParagraphStyle, NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontBody]}];
        NSRange affectedRange =  NSMakeRange(50, 30);
        [choiceText addAttribute:NSLinkAttributeName value:[NSURL URLWithString:@"https://join.app.net/signup"] range:affectedRange];
        [choiceText addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0.063 green:0.247 blue:0.984 alpha:1] range:affectedRange];
        [choiceText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:affectedRange];
        
        self.loginChoiceText.attributedStringValue = choiceText;
        [self.loginChoiceText setAllowsEditingTextAttributes:YES];
        [self.loginChoiceText setSelectable:YES];
        
        INOAppDelegate * delegate = (INOAppDelegate*)[[NSApplication sharedApplication] delegate];
        
        // show the login sheet
        [NSApp beginSheet:self.loginSheet
           modalForWindow:delegate.windowController.window
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
    }
    
    NSNib *loadingNib = [[NSNib alloc] initWithNibNamed:@"INOLoadingTableViewCell" bundle:nil];
    [self.channelTable registerNib:loadingNib forIdentifier:@"loadingView"];
    
}

- (void)loadDataForChannelTable
{
    [[INOChannelTools sharedTools] getChannels];
}



# pragma mark -
# pragma mark Notifications

- (void)receiveChannels:(NSNotification*)aNotification
{
    NSMutableArray * newData = [NSMutableArray array];
    for (ANKChannel * channel in aNotification.object) {
        [[INOChannelTools sharedTools] channelName:channel];
        [newData addObject:@{@"channelId" : channel.channelID,
                             @"data" : channel,
                             @"channelName" : [[INOChannelTools sharedTools] getTitleForChannel:channel]}];
    }

    self.channelData = newData;

    BOOL completeChannels = YES;
    for (NSDictionary * dict in self.channelData) {
        if ([dict[@"channelName"] length] == 0) {
            completeChannels = NO;
        }
    }
    
    if (completeChannels) {
        [self.channelTable reloadData];
    }

}

- (void)receiveChannelName:(NSNotification*)aNotification
{
    if (self.channelData.count > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"channelId = %@", aNotification.object[@"channelId"]];
        
        NSArray * updatedChannels = [self.channelData filteredArrayUsingPredicate:predicate];
        if (updatedChannels.count > 0) {
            NSDictionary * updatedChannel = [updatedChannels objectAtIndex:0];
            
            if (updatedChannel) {
                NSMutableDictionary * newDict = [updatedChannel mutableCopy];
                [newDict setObject:aNotification.object[@"name"] forKey:@"channelName"];
                [self.channelData replaceObjectAtIndex:[self.channelData indexOfObject:updatedChannel] withObject:newDict];
            }
            
            BOOL completeChannels = YES;
            for (NSDictionary * dict in self.channelData) {
                if ([dict[@"channelName"] length] == 0) {
                    completeChannels = NO;
                }
            }
            
            if (completeChannels) {
                [self.channelTable reloadData];
            }
        }
        
    }
    
}


# pragma mark -
# pragma mark Table View Delegate and Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    if ([self.channelData count] > 0) {
        return [self.channelData count];
    }
    else {
        return 1;
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    
    
    if (self.channelData.count > 0) {
        ANKChannel * thisChannel = [self.channelData objectAtIndex:row][@"data"];
        MUNChannelTableViewCell *result = [self.channelTable makeViewWithIdentifier:@"tableViewCell" owner:self];
        result.wantsLayer = YES;
        
        result.channel = thisChannel;
    
        if ([[self.channelData objectAtIndex:row][@"channelName"] length] == 0) {
            [[INOChannelTools sharedTools] channelName:thisChannel];
            
            NSMutableDictionary * newDict = [[self.channelData objectAtIndex:row] mutableCopy];
            [newDict setObject:@"" forKey:@"channelName"];
            [self.channelData replaceObjectAtIndex:row withObject:newDict];
            newDict = nil;
        }
        else {
            NSAttributedString * titleAttributedString = [[NSAttributedString alloc] initWithString:[self.channelData objectAtIndex:row][@"channelName"] attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontHeader], NSParagraphStyleAttributeName : self.titleParagraphStyle}];
            result.titleField.attributedStringValue = titleAttributedString;
            
        }
        
        [result generateAvatarView:thisChannel];
        
        ANKMessage * lastMessage = [thisChannel latestMessage];
        
        if (lastMessage) {
            NSAttributedString * lastMessageAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@: %@", lastMessage.user.username, lastMessage.text] attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontBody], NSParagraphStyleAttributeName : self.theirMessageParagraphStyle, NSForegroundColorAttributeName : [[MUNThemeManager sharedManager] bodyTextColor]}];
            result.lastMessage.attributedStringValue = lastMessageAttributedString;
            [result.lastMessage setSelectable:NO];
            lastMessageAttributedString = nil;
        }

        // TODO: Unread marker "pip" not quite doing what I want...
        
//        if ([thisChannel.has_unread isEqualToValue:[NSNumber numberWithBool:YES]]) {
//            [result.pipView addSubview:[result unreadPip]];
//            [result addSubview:result.pipView];
//            NSRect newTitleFrame = NSMakeRect(55, result.titleField.frame.origin.y, result.titleField.frame.size.width, result.titleField.frame.size.height);
//            [result.titleField setFrame:newTitleFrame];
//        }
//        else {
//            [[result pipView] setSubviews:[NSArray array]];
//            
//            NSRect newTitleFrame = NSMakeRect(38, result.titleField.frame.origin.y, result.titleField.frame.size.width, result.titleField.frame.size.height);
//            [result.titleField setFrame:newTitleFrame];
//        }
        
        if (lastMessage) {
            NSDictionary * userInfoDict = @{@"message" : lastMessage, @"row" : result};
            
            NSInteger update;
            if ([lastMessage.createdAt timeIntervalSinceNow] > 60) {
                update = 60;
            }
            else {
                update = 1;
            }
            
            [result.timeAgoTimer invalidate];
            result.timeAgoTimer = [NSTimer scheduledTimerWithTimeInterval:update target:self selector:@selector(updateChannelTimer:) userInfo:userInfoDict repeats:YES];
        }
        
        return result;
    }
    else {
        INOLoadingTableViewCell * result = [self.channelTable makeViewWithIdentifier:@"loadingView" owner:self];
        
        return result;
    }
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (self.channelData.count > 0) {
        return 110;
    }
    else {
        return 35;
    }
    
    
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[MUNSubduedTableRowView alloc] init];
}


-(IBAction)login:(id)sender {
    
    self.loginMessage.stringValue = @"";
    
    // ask for permission to see user information and send new Posts
    ANKAuthScope requestedScopes = ANKAuthScopeBasic | ANKAuthScopeMessages | ANKAuthScopeWritePost;
    
    // handler to call when finished authenticating
    id handler = ^(BOOL success, NSError *error) {
        if (success) {
            [[MUNUser sharedInstance] updateAuthenticationToken:[[ANKClient sharedClient] accessToken] forUserID:self.username.stringValue];
            
            [NSApp endSheet:self.loginSheet];
            [self.loginSheet orderOut:self];
            
            [self.windowController renderTitleHeaderView];
            [self loadDataForChannelTable];
        } else {
            self.loginMessage.stringValue = @"Could not login! Please try again.";
            NSLog(@"could not authenticate, error: %@", error);
        }
    };
    
    // authenticate, calling the handler block when complete
    [[ANKClient sharedClient] authenticateUsername:self.username.stringValue
                                          password:self.password.stringValue
                                          clientID:kADNAccessId
                               passwordGrantSecret:kADNPasswordGrant
                                        authScopes:requestedScopes
                                 completionHandler:handler];
    
    
    
}

- (void)updateChannelTimer:(NSTimer*)timer
{
    NSDictionary * dict = [timer userInfo];
    MUNChannelTableViewCell * cell = (MUNChannelTableViewCell*)[dict valueForKey:@"row"];
    ANKMessage * thisMessage = [dict valueForKey:@"message"];
    cell.timeAgo.stringValue = [NSString stringWithFormat:@"%@", [[INOMessageTools sharedTools] timeAgo:thisMessage]];
}

- (void)openChannelCommand
{
    if (self.channelData.count >= [self.channelTable selectedRow]) {
        ANKChannel * channel = [self.channelData objectAtIndex:[self.channelTable selectedRow]][@"data"];
        
        self.windowController.messageViewController.messageData = nil;
        self.windowController.messageViewController.fetchState = MessageFetchStateFirstRun;
        self.windowController.messageViewController.updateTime = nil;
        [self.windowController.messageViewController loadDataForChannel:channel];
        
        [self.windowController prepareViews:YES];
        [self.windowController switchToMessageTable];
        [self.windowController.messageViewController.messageTable reloadData];
    }
    

}

@end
