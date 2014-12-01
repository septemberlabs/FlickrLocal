//
//  ExclusiveSelectionList.m
//  Flickr Local
//
//  Created by Will Smith on 11/23/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "ExclusiveSelectionList.h"

@interface ExclusiveSelectionList ()
@end

static NSString *const USER_DEFAULTS_DISPLAY_ORDER_KEY = @"displayOrder";

@implementation ExclusiveSelectionList

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.options = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULTS_DISPLAY_ORDER_KEY] mutableCopy];
}

- (void)setOptions:(NSMutableDictionary *)options
{
    _options = options;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableCellIdentifier = @"Checkable Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier forIndexPath:indexPath];
    
    NSArray *keys = [self.options allKeys];
    cell.textLabel.text = keys[indexPath.row];
    // the dictionary's values are booleans, so checkmark cell accessory for YES, no cell accessory for NO.
    NSNumber *selected = (NSNumber *)[self.options valueForKey:keys[indexPath.row]]; // pull out as an NSNumber, then use boolValue getter
    if (selected.boolValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // basically enumerate the cells, setting checkmark sell access for selected row, no cell accessory for all others. update the model at the same time.
    NSArray *keys = [self.options allKeys];
    for (int i = 0; i < [self.options count]; i++) {
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (i != indexPath.row) {
            currentCell.accessoryType = UITableViewCellAccessoryNone;
            [self.options setValue:@NO forKey:keys[i]];
        }
        else {
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.options setValue:@YES forKey:keys[i]];
        }
    }
    
    // update user defaults
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:USER_DEFAULTS_DISPLAY_ORDER_KEY];
    [standardUserDefaults setObject:self.options forKey:USER_DEFAULTS_DISPLAY_ORDER_KEY];
    [standardUserDefaults synchronize];
}

@end
