//
//  OptionsTVC.h
//  Flickr Local
//
//  Created by Will Smith on 11/23/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsTVC : UITableViewController

@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;

@end
