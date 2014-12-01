//
//  ExclusiveSelectionList.h
//  Flickr Local
//
//  Created by Will Smith on 11/23/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExclusiveSelectionList : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *options; // assumes a dictionary of booleans, which will be represented by a checkmark for YES

@end
