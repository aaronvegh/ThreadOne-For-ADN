//
//  INOAutoSuggestViewController.m
//  INOTokenMaker
//
//  Created by Aaron Vegh on 10/21/2013.
//  Copyright (c) 2013 Aaron Vegh. All rights reserved.
//

#import "INOAutoSuggestViewController.h"
#import "INOAutoSuggestTableView.h"
#import "INOUserTools.h"

@interface INOAutoSuggestViewController ()

@property (readwrite, strong) NSMutableSet * fullData;

@end

@implementation INOAutoSuggestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil partialText:(NSString*)text sender:(NSTextField*)sender
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.partialText = text;
        self.senderField = sender;
        [self addObserver: self
               forKeyPath: @"partialText"
                  options: NSKeyValueObservingOptionNew
                  context: NULL];
        self.chosenUserArray = [NSMutableArray array];
        
        // get the users for followers and follwees so we can have a quicker search
        self.fullData = [NSMutableSet set];
        [[ANKClient sharedClient] fetchUsersFollowingUser:[[ANKClient sharedClient] authenticatedUser] completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
            for (ANKUser * user in responseObject) {
                [self.fullData addObject:user];
            }
        }];
        
        [[ANKClient sharedClient] fetchUsersUserFollowing:[[ANKClient sharedClient] authenticatedUser] completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
            for (ANKUser * user in responseObject) {
                [self.fullData addObject:user];
            }
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeUserFromChosenUsers:) name:@"removeUserFromChosenUsers" object:nil];
    }
    
    return self;
}

- (void)awakeFromNib
{
    
    
    [self.tableView setDoubleAction:@selector(selectUser:)];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSString * newValue = [[change objectForKey:@"new"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString * searchValue = [newValue stringByReplacingOccurrencesOfString:[self userStringFromArray] withString:@""];
    
    self.userArray = [NSMutableArray arrayWithArray:[[self.fullData allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[c] %@", searchValue]]];
    
    // search all users on ADN as well, and append results to the user array
    [[ANKClient sharedClient] searchForUsersWithQuery:searchValue completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
        for (ANKUser * user in responseObject) {
            [self.userArray addObject:user];
        }
        
        [self updateSuggestList];
    }];
    
    [self updateSuggestList];
}

- (void)updateSuggestList
{
    if (self.userArray.count > 0) {
        [self.view setHidden:NO];
        [self.tableView reloadData];
    }
    else {
        [self.view setHidden:YES];
    }
}

- (NSMutableString*)userStringFromArray
{
    NSMutableString * returnString = [NSMutableString string];
    
    for (ANKUser * user in self.chosenUserArray) {
        [returnString appendFormat:@"@%@, ", user.username];
    }
    
    return returnString;
}

- (ANKUser*)userForSelectionIndex:(NSInteger)index
{
    ANKUser * pickedUser;
    
    for (NSDictionary * dict in self.chosenUserArray) {
        if (NSLocationInRange(index, NSRangeFromString([dict valueForKey:@"range"]))) {
            pickedUser = [dict valueForKey:@"user"];
        }
    }
    
    return pickedUser;
}

- (NSRange)rangeForSelectionIndex:(NSInteger)index
{
    NSRange pickedRange = NSMakeRange(0, 0);
    
    for (NSDictionary * dict in self.chosenUserArray) {
        if (NSLocationInRange(index, NSRangeFromString([dict valueForKey:@"range"]))) {
            pickedRange = NSRangeFromString([dict valueForKey:@"range"]);
        }
    }
    
    return pickedRange;
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.userArray count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView * cell = [tableView makeViewWithIdentifier:@"cellView" owner:self];
    ANKUser * thisUser = (ANKUser*)[self.userArray objectAtIndex:row];
    if (self.userArray.count > row) {
        cell.textField.stringValue = [thisUser username];
        cell.imageView.image = [[INOUserTools sharedTools] fetchAvatarForUser:thisUser];
    }
    else {
        
    }
    
    
    return cell;
}


- (void)removeUserFromChosenUsers:(NSNotification*)notification
{
    ANKUser * user = [notification.userInfo valueForKey:@"userObj"];
    
    [self.chosenUserArray removeObject:user];
}

- (void)selectUser:(id)sender
{
    ANKUser * newUser = [[self userArray] objectAtIndex:[self.tableView.selectedRowIndexes firstIndex]];
    
    [self.chosenUserArray addObject:newUser];
    
    [self resignFirstResponder];
    
    // create token and add to userDisplayView
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShowUsers" object:nil];
    
    [self.view setHidden:YES];
}



@end
