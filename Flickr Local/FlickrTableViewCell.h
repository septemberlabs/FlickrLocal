//
//  FlickrTableViewCell.h
//  Flickr Local
//
//  Created by Will Smith on 11/19/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIImageView *imageContainer;
@end
