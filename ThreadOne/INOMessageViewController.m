//
//  INOMessageViewController.m
//  ThreadOne
//
//  Created by Aaron Vegh on 2014-03-06.
//  Copyright (c) 2014 Aaron Vegh. All rights reserved.
//

#import "INOMessageViewController.h"
#import "INOAppDelegate.h"
#import "MUNThemeManager.h"
#import "MUNComposeView.h"
#import "MUNComposeTextView.h"
#import "MUNAttachmentView.h"
#import "MUNTheirMessageTableViewCell.h"
#import "HyperlinkTextField.h"
#import "INOUserTools.h"
#import "INOMessageTools.h"
#import "INOChannelTools.h"
#import "INOMessageTableView.h"
#import "NSData+NSData_MIMEType.h"
#import "INOLoadingTableViewCell.h"
#import "ITProgressIndicator.h"
#import "INOTimestampTableCellView.h"
#import "INONewPostLoadingView.h"

@interface INOMessageViewController ()

@property (readwrite, assign) NSInteger currentRowCount;
@property (readwrite, assign) BOOL imageUploadInProgress;
@property (readwrite, strong) INONewPostLoadingView * postLoadingView;

@end

@implementation INOMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessages:) name:@"receiveMessagesFromADN" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newIncomingMessage:) name:@"newIncomingMessageFromADN" object:nil];
        
        /* Because the scrollview observer rapidly fires notifications on scrolling,
         I want to throttle the number of hits against the API when the scrollview hits the top
         Therefore I assign this BOOL to determine whether a network action is happening,
         hopefully limiting multiple hits on the API to just one. */
        self.messagesAreBeingFetched = NO;
        
        NSScrollView *contentView = [self.messageTable enclosingScrollView];
        [contentView setPostsBoundsChangedNotifications:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:contentView];
        
        self.messageLoadingView.autoresizingMask = NSViewMinXMargin|NSViewMaxXMargin;
        self.messageLoadingView.wantsLayer = YES;
        self.messageLoadingView.layer.backgroundColor = [[NSColor grayColor] CGColor];
        
        self.imageUploadInProgress = NO;
        
        // initialize and setup newpostloadingview
        
        self.postLoadingView = [[INONewPostLoadingView alloc] init];
        self.postLoadingView.frame = CGRectMake(0, self.messageTable.frame.origin.y, self.messageTable.bounds.size.width, 0);
        self.postLoadingView.wantsLayer = YES;
        self.postLoadingView.layer.borderColor = [[NSColor blueColor] CGColor];
        self.postLoadingView.layer.borderWidth = 2.0;
    }
    
    return self;
}



- (void)loadDataForChannel:(ANKChannel*)channel
{
    
    if (!self.messagesAreBeingFetched) {
        
        [self animateLoadingViewIn];
        self.messagesAreBeingFetched = YES;
        self.messageData = nil;
        self.channel = channel;
        
        if (self.fetchState != MessageFetchStateFirstRun) {
            
            [[INOMessageTools sharedTools] getMessagesForChannel:channel usingClient:self.messageClient withFetchState:self.fetchState];
        }
        else {
            [[INOMessageTools sharedTools] getMessagesForChannel:channel usingClient:nil withFetchState:self.fetchState];
        }
        
        self.headerChatTitle.stringValue = [[INOChannelTools sharedTools] getTitleForChannel:self.channel];
        self.headerChatParticipants.stringValue = [NSString stringWithFormat:@"%ld Participants", [[INOChannelTools sharedTools] numberOfChatParticipants:self.channel]];
    }
    
}

- (void)newIncomingMessage:(NSNotification*)aNotification
{
    self.fetchState = MessageFetchStateIncoming;
    
    if (self.messageClient) {
        [[INOMessageTools sharedTools] getMessagesForChannel:self.channel usingClient:self.messageClient withFetchState:self.fetchState];
    }
    else {
        [[INOMessageTools sharedTools] getMessagesForChannel:self.channel usingClient:nil withFetchState:self.fetchState];
    }
}

- (void)receiveMessages:(NSNotification*)aNotification
{
    /*  Controlling the flow of messages to this method has been one of the hairiest parts of developing this app.
        This code is the result of a great deal of trial and error, and remains one of my "fear points" going forward...
     */
    
    self.messageData = aNotification.object[@"data"];
    
    // insert dateline objects
    NSMutableArray * newMessageData = [NSMutableArray array];
    int c = 0;
    ANKMessage * lastMessage;
    for (ANKMessage * message in self.messageData) {
        if (c > 0) {
            lastMessage = self.messageData[c - 1];
        }
        else {
            lastMessage = nil;
        }
        
        if (lastMessage && ([message.createdAt timeIntervalSinceDate:lastMessage.createdAt] > 3599)) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"MMM dd, yyyy • HH:mm"];
            [newMessageData addObject:[format stringFromDate:message.createdAt]];
            [newMessageData addObject:message];
        }
        else {
            [newMessageData addObject:message];
        }
        
        c++;
    }
    
    self.messageData = newMessageData;
    
    [self.messageTable reloadData];
    
    
    if (self.fetchState == MessageFetchStateUpdateThread) {
        NSScrollView * scrollView = [self.messageTable enclosingScrollView];
        CGRect visibleRect = scrollView.contentView.visibleRect;
        NSRange range = [self.messageTable rowsInRect:visibleRect];
        NSInteger firstOldRowIndex = self.messageData.count - self.currentRowCount + range.length - 2;
        [self.messageTable scrollRowToVisible:firstOldRowIndex];
    }
    
    self.messageClient = aNotification.object[@"client"];
    
    if (self.messagesAreBeingFetched) {
        self.messagesAreBeingFetched = NO;
        if (self.fetchState == MessageFetchStateFirstRun) {
            // get older new messages, then go back and get all new ones
            self.fetchState = MessageFetchStateIncoming;
            [self loadDataForChannel:self.channel];
        }
        else {
            self.fetchState = MessageFetchStateUpdateThread;
        }
        
    }
    
    if (self.fetchState == MessageFetchStateFirstRun || self.fetchState == MessageFetchStateIncoming) {
        [self scrollToEnd];
    }
    
    [self animateLoadingViewOut];
    
    self.updateTime = [NSDate date];

}


- (void)awakeFromNib
{
    
    self.attachmentView.uploadDelegate = self;
    
    self.titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    self.titleParagraphStyle.alignment = NSLeftTextAlignment;
    self.titleParagraphStyle.lineSpacing = 0;
    self.titleParagraphStyle.minimumLineHeight = 10;
    self.titleParagraphStyle.maximumLineHeight = 30;
    self.titleParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.messageParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    self.messageParagraphStyle.alignment = NSLeftTextAlignment;
    self.messageParagraphStyle.minimumLineHeight = 14;
    self.messageParagraphStyle.maximumLineHeight = 18;
    self.messageParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.myMessageParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    self.myMessageParagraphStyle.alignment = NSRightTextAlignment;
    self.myMessageParagraphStyle.minimumLineHeight = 14;
    self.myMessageParagraphStyle.maximumLineHeight = 18;
    self.myMessageParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.theirTitleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    self.theirTitleParagraphStyle.alignment = NSLeftTextAlignment;
    self.myTitleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    self.myTitleParagraphStyle.alignment = NSRightTextAlignment;
    
    self.messageTable.backgroundColor = [[MUNThemeManager sharedManager] windowBackgroundColor];
    
    self.messagePostField.font = [[MUNThemeManager sharedManager] themeFontBody];
    self.messagePostField.delegate = self;
    
    self.headerChatTitle.font = [[MUNThemeManager sharedManager] themeFontChatName];
    self.headerChatParticipants.font = [[MUNThemeManager sharedManager] themeFontSmaller];
    self.headerChatTitle.textColor = [[MUNThemeManager sharedManager] bodyTextColor];
    self.headerChatParticipants.textColor = [[MUNThemeManager sharedManager] bodyTextColor];
    
    [self.messageTable setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    
    [self.composeView setWantsLayer:YES];
    self.composeView.layer.backgroundColor = [[[MUNThemeManager sharedManager] windowBackgroundColor] CGColor];
    [self.horizontalRule setWantsLayer:YES];
    self.horizontalRule.layer.backgroundColor = [[[MUNThemeManager sharedManager] titleBorderColor] CGColor];
    
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[[[MUNThemeManager sharedManager] windowBackgroundColor] CGColor]];
    
    self.headerView.wantsLayer = YES;
    self.headerView.layer.backgroundColor = [[[MUNThemeManager sharedManager] windowBackgroundColor] CGColor];
    
    self.horizontalRule.layer.backgroundColor = [[[MUNThemeManager sharedManager] titleBorderColor] CGColor];
    
    self.annotationArray = [NSMutableArray array];
    self.attachmentArray = [NSMutableArray array];
    [self.progressIndicator setHidden:YES];
    
    NSNib *theirNib = [[NSNib alloc] initWithNibNamed:@"MUNTheirMessageTableViewCell" bundle:nil];
    [self.messageTable registerNib:theirNib forIdentifier:@"theirMessageView"];
    
    NSNib *myNib = [[NSNib alloc] initWithNibNamed:@"MUNMyMessageTableViewCell" bundle:nil];
    [self.messageTable registerNib:myNib forIdentifier:@"myMessageView"];
    
    NSNib *loadingNib = [[NSNib alloc] initWithNibNamed:@"INOLoadingTableViewCell" bundle:nil];
    [self.messageTable registerNib:loadingNib forIdentifier:@"loadingView"];
    
    NSNib *timestampNib = [[NSNib alloc] initWithNibNamed:@"INOTimestampTableCellView" bundle:nil];
    [self.messageTable registerNib:timestampNib forIdentifier:@"timestampView"];
    
    self.messagePostField.messageVC = self;
    
    self.indicator.color = [[MUNThemeManager sharedManager] highlightColor];
    self.indicator.animates = YES;
    
    
}


# pragma mark - Table View Data Source and Delegate Methods


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger objects;
    
    if (self.messageData.count > 0) {
        return self.messageData.count;
    }
    else {
        return 1;
    }
    
    return objects;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if (self.messageData.count > 0) {
        ANKMessage * thisMessage = [self.messageData objectAtIndex:row];
        
        
        if ([[self.messageData objectAtIndex:row] isKindOfClass:[NSString class]]) {
            INOTimestampTableCellView * result = [self.messageTable makeViewWithIdentifier:@"timestampView" owner:self];
        
            result.dateline.stringValue = [self.messageData objectAtIndex:row];
            
            return result;
        }
        else {
            
            if (thisMessage) {
                if (thisMessage.isDeleted) {
                    return [[NSTableCellView alloc] init];
                }
                else {
                    MUNTheirMessageTableViewCell *result;
                    NSMutableAttributedString * thisMessageAttributedString;
                    
                    if ([thisMessage.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]]) {
                        result = [self.messageTable makeViewWithIdentifier:@"myMessageView" owner:self];
                        result.me = YES;
                        result.messageField.me = YES;
                        
                        thisMessageAttributedString = [[NSMutableAttributedString alloc] initWithString:thisMessage.text attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontBody], NSParagraphStyleAttributeName : self.myMessageParagraphStyle, NSForegroundColorAttributeName : [[MUNThemeManager sharedManager] bodyTextColor]}];
                        

                    }
                    else {
                        result = [self.messageTable makeViewWithIdentifier:@"theirMessageView" owner:self];
                        result.me = NO;
                        result.messageField.me = NO;
                        
                        thisMessageAttributedString = [[NSMutableAttributedString alloc] initWithString:thisMessage.text attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontBody], NSParagraphStyleAttributeName : self.messageParagraphStyle, NSForegroundColorAttributeName : [[MUNThemeManager sharedManager] bodyTextColor]}];
                        
                    }
                    

                    result.thisMessage = thisMessage;
                    
                    if ([thisMessage.entities.links count] > 0) {
                        
                        for (ANKLinkEntity * link in thisMessage.entities.links) {
                            [thisMessageAttributedString beginEditing];
                            NSRange affectedRange = NSMakeRange(link.position, link.length);
                            [thisMessageAttributedString addAttribute:NSLinkAttributeName value:link.URL range:affectedRange];
                            [thisMessageAttributedString addAttribute:NSForegroundColorAttributeName value:[[MUNThemeManager sharedManager] highlightColor] range:affectedRange];
                            [thisMessageAttributedString endEditing];
                        }
                    }
                    
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
                    
                    if (result.me) {
                        [displayName addAttribute:NSParagraphStyleAttributeName value:self.myTitleParagraphStyle range:NSMakeRange(0, [[displayName string] length])];
                    }
                    
                    result.userName.attributedStringValue = displayName;
                    
                    NSParagraphStyle * style;
                    if (result.me) {
                        style = self.theirTitleParagraphStyle;
                    }
                    else {
                        style = self.myTitleParagraphStyle;
                    }
                    NSAttributedString * timeAgoString = [[NSAttributedString alloc] initWithString:[[INOMessageTools sharedTools] timeAgo:thisMessage] attributes:@{NSForegroundColorAttributeName : [[MUNThemeManager sharedManager] bodyTextColor], NSParagraphStyleAttributeName : style}];
                    result.timeAgo.attributedStringValue = timeAgoString;

                    [result.attachmentView setSubviews:[NSArray array]];
                    [result generateImageAttachmentView];
                    if (result.me) {
                        [result.attachmentView setFrame:NSMakeRect(8, result.backgroundView.frame.size.height - 70, 35, 35)];
                    }
                    else {
                        [result.attachmentView setFrame:NSMakeRect(result.backgroundView.frame.size.width - 43, result.backgroundView.frame.size.height - 70, 35, 35)];
                    }
                    
                    NSDictionary * userInfoDict = @{@"message" : thisMessage, @"row" : result};
                    
                    NSInteger update;
                    if ([thisMessage.createdAt timeIntervalSinceNow] > 60) {
                        update = 60;
                    }
                    else {
                        update = 1;
                    }
                    [result.timeAgoTimer invalidate];
                    result.timeAgoTimer = [NSTimer scheduledTimerWithTimeInterval:update target:self selector:@selector(updateMessageTimer:) userInfo:userInfoDict repeats:YES];
                    
                    return result;
                }
            }
        
            else {
                return nil;
            }
        }
    }
    else {
        return nil;
    }
    
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (self.messageData.count > 0) {
        
        if ([[self.messageData objectAtIndex:row] isKindOfClass:[NSString class]]) {
            return 35;
        }
        else {
            ANKMessage * thisMessage = [self.messageData objectAtIndex:row];
            if (thisMessage) {
                if (thisMessage.isDeleted) {
                    return 1;
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
                return self.messageTable.frame.size.height;
            }
        }
    }
    else {
        return self.messageTable.frame.size.height;
    }
}

- (CGFloat)calculateIdealHeightForSize:(NSSize)size content:(NSString*)content
{
    NSAttributedString * thisMessageAttributedString = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName : [[MUNThemeManager sharedManager] themeFontBody], NSParagraphStyleAttributeName : self.messageParagraphStyle, NSForegroundColorAttributeName : [NSColor blackColor]}];
    
    NSRect headerRect = [thisMessageAttributedString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin];
    CGFloat minHeight = ceil(headerRect.size.height);
    
    return minHeight;
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
    return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    return NO;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[NSTableRowView alloc] init];
}

- (void)updateMessageTimer:(NSTimer*)timer
{
    NSDictionary * dict = [timer userInfo];
    MUNTheirMessageTableViewCell * cell = (MUNTheirMessageTableViewCell*)[dict valueForKey:@"row"];
    ANKMessage * thisMessage = [dict valueForKey:@"message"];
    
    NSParagraphStyle * style;
    if ([thisMessage.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]]) {
        style = self.theirTitleParagraphStyle;
    }
    else {
        style = self.myTitleParagraphStyle;
    }
    
    NSAttributedString * timeAgoString = [[NSAttributedString alloc] initWithString:[[INOMessageTools sharedTools] timeAgo:thisMessage] attributes:@{NSForegroundColorAttributeName : [[MUNThemeManager sharedManager] bodyTextColor], NSParagraphStyleAttributeName : style}];
    cell.timeAgo.attributedStringValue = timeAgoString;
}

- (void)scrollToEnd
{
    NSInteger numberOfRows = [self.messageTable numberOfRows];
    [self.messageTable scrollRowToVisible:numberOfRows - 1];
}

- (IBAction)sendMessage:(id)sender
{
    if (!self.imageUploadInProgress) {
        __block ANKMessage * newMessage = [[ANKMessage alloc] init];
        newMessage.text = self.messagePostField.string;
        
        if (self.annotationArray.count > 0) {
            ANKFile * file = self.annotationArray[0];
            if (file) {
                newMessage.annotations = @[[ANKAnnotation oembedAnnotationForFile:file]];
            }
        }
        
        [[ANKClient sharedClient] createMessage:newMessage inChannel:self.channel completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
            self.messagePostField.string = @"";
            
            self.annotationArray = [NSMutableArray array];
            self.attachmentArray = [NSMutableArray array];
            self.attachmentView.subviews = [NSArray array];
        }];
    }
    else {
        NSBeep();
    }
    

}

- (void)showLoadingViewWithMessage:(ANKMessage*)message
{
    [self.postLoadingView.loadingMessages addObject:message];
    
    //adjust loading view frame accordingly
    self.postLoadingView.frame = CGRectMake(0, self.postLoadingView.frame.origin.y, self.postLoadingView.frame.size.width, 100);
    self.messageTable.frame = CGRectMake(0, self.messageTable.frame.origin.y + 100, self.messageTable.frame.size.width, self.messageTable.frame.size.height - 100);
}

- (void)hideLoadingViewWithMessage:(ANKMessage*)message
{
    [self.postLoadingView.loadingMessages removeObject:message];
    
    //adjust loading view frame accordingly
    self.postLoadingView.frame = CGRectMake(0, self.postLoadingView.frame.origin.y, self.postLoadingView.frame.size.width, 0);
    self.messageTable.frame = CGRectMake(0, self.messageTable.frame.origin.y - 100, self.messageTable.frame.size.width, self.messageTable.frame.size.height + 100);
}

- (IBAction)attachFile:(id)sender
{
    NSOpenPanel * openDlg = [NSOpenPanel openPanel];
    [openDlg setPrompt:@"Use Image"];
    [openDlg setAllowedFileTypes:@[@"PNG", @"GIF", @"JPG", @"JPEG"]];
    [openDlg beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* files = [openDlg URLs];
            
            for(NSURL * url in files)
            {
                [self uploadImage:url];
            }
        }
        else {
            [self.progressIndicator stopAnimation:self];
            [self.progressIndicator setHidden:YES];
            
            [self.attachmentButton setHidden:NO];
        }
        
        
    }];
    
}

- (void)uploadImage:(NSURL*)url
{
    [self.attachmentButton setHidden:YES];
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:self];
    
    NSImage *img;
    NSData *imgData;
    if(url)
    {
        img = [[NSImage alloc]initWithContentsOfURL:url];
        imgData = [NSData dataWithContentsOfURL:url];
        
    }
    if(imgData)
    {

        __block ANKFile * file = [[ANKFile alloc] init];
        file.mimeType = [NSData contentTypeForImageData:imgData];
        file.type = @"com.innoveghtive.threadone";
        file.name = [url lastPathComponent];
        
        self.imageUploadInProgress = YES;
        
        __weak INOMessageViewController * weakSelf = self;
        [[ANKClient sharedClient] createFile:file withData:imgData completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
            if (!error) {
                [weakSelf.annotationArray addObject:responseObject];
                [weakSelf.attachmentArray addObject:img];
                [weakSelf updatePreviewView];
                
                // add a space to the message so they can send just an image
                NSString * currentField = self.messagePostField.string;
                if ([currentField length] == 0) {
                    weakSelf.messagePostField.string = @" ";
                }
            }
            
            [weakSelf.progressIndicator stopAnimation:self];
            [weakSelf.progressIndicator setHidden:YES];
            [weakSelf.attachmentButton setHidden:NO];
            
            weakSelf.imageUploadInProgress = NO;

        }];
        
        
    }
    else
    {
        INOAppDelegate * delegate = (INOAppDelegate*)[[NSApplication sharedApplication] delegate];
        NSAlert *alert = [[NSAlert alloc]init];
        [alert setMessageText:@"Application Message"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setInformativeText:@"Select Only Image"];
        [alert beginSheetModalForWindow:delegate.windowController.window
                          modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
}

- (void)updatePreviewView
{
    self.attachmentView.subviews = [NSArray array];
    if ([self.annotationArray count] > 0) {
        for (NSImage * image in self.attachmentArray) {
            NSImageView * imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
            imageView.image = image;
            [self.attachmentView addSubview:imageView];
            imageView = nil;
        }
    }
}

- (void)textViewDidChangeSelection:(NSNotification *)aNotification
{
    MUNComposeTextView * textView = [aNotification object];
    
    
    NSRect usedRect = [textView.textContainer.layoutManager usedRectForTextContainer:textView.textContainer];
    
    CGFloat newHeight = MAX(usedRect.size.height + 5, 25);
    
    NSRect messageViewStartingRect = [[[self.messageTable superview] superview] frame];
    NSRect textViewStartingRect = [[[self.messagePostField superview] superview] frame];
    NSRect composeViewStartingRect = [self.composeView frame];
    
    [[self.messagePostField superview] superview].frame = NSMakeRect(textViewStartingRect.origin.x, textViewStartingRect.origin.y, textViewStartingRect.size.width, newHeight);
    
    [self.composeView setFrame:NSMakeRect(composeViewStartingRect.origin.x, composeViewStartingRect.origin.y, composeViewStartingRect.size.width, newHeight + 15)];
    
    CGFloat totalHeight = self.view.frame.size.height;
    
    self.messageTable.superview.superview.frame = NSMakeRect(messageViewStartingRect.origin.x,
                                                             newHeight + 15,
                                                             messageViewStartingRect.size.width,
                                                             totalHeight - (newHeight + 50));
    [self scrollToEnd];
    
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    return YES;
}

- (void)scrollBoundsDidChange:(NSNotification*)aNotification
{
    if ([aNotification.object isEqual:[[self.messageTable enclosingScrollView] contentView]]) {
        
        NSScrollView * scrollView = [self.messageTable enclosingScrollView];
        CGRect visibleRect = scrollView.contentView.visibleRect;
        NSRange range = [self.messageTable rowsInRect:visibleRect];
        //NSLog(@"Range: %@", NSStringFromRange(range));
        if (range.location < 1) {
            if ([self.updateTime timeIntervalSinceNow] < -5) {
                self.updateTime = [NSDate date];
                self.currentRowCount = self.messageData.count;// - (range.length - 1);
                [self loadDataForChannel:self.channel];
            }
            
        }
    }
}

- (void)animateLoadingViewIn
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [[self.messageLoadingView animator] setFrameOrigin:NSMakePoint(0, self.view.frame.size.height - 70)];
        //[[self.messageTable animator] setFrame:NSMakeRect(0, self.messageTable.frame.origin.y + 35, self.messageTable.frame.size.width, self.messageTable.frame.size.height - 35)];
        
    } completionHandler:nil];
}

- (void)animateLoadingViewOut
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [[self.messageLoadingView animator] setFrameOrigin:NSMakePoint(0, self.view.frame.size.height - 35)];
        //[[self.messageTable animator] setFrame:NSMakeRect(0, self.messageTable.frame.origin.y + 35, self.messageTable.frame.size.width, self.messageTable.frame.size.height + 35)];
        
    } completionHandler:nil];
}


@end
