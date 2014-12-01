//
//  OptionsTVC.m
//  Flickr Local
//
//  Created by Will Smith on 11/23/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "OptionsTVC.h"
#import "ExclusiveSelectionList.h"

@interface OptionsTVC ()
@property (weak, nonatomic) IBOutlet UITableViewCell *orderByCell;
@end

static NSString *const USER_DEFAULTS_DISPLAY_ORDER_KEY = @"displayOrder";
static NSString *const USER_DEFAULTS_RADIUS = @"radius";

@implementation OptionsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateGUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateGUI];
}

- (void)updateGUI
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *orderByValues = [standardDefaults dictionaryForKey:USER_DEFAULTS_DISPLAY_ORDER_KEY];
    for (id key in orderByValues) {
        NSNumber *entryValue = (NSNumber *)[orderByValues valueForKey:key]; // pull out as an NSNumber, then use boolValue getter
        if (entryValue.boolValue) {
            self.orderByCell.detailTextLabel.text = key;
        }
    }
    
    float radius = [standardDefaults floatForKey:USER_DEFAULTS_RADIUS];
    self.radiusLabel.text = [NSString stringWithFormat:@"%.1f miles", radius];
    self.radiusSlider.value = radius;
}

- (IBAction)radiusChange:(id)sender
{
    self.radiusLabel.text = [NSString stringWithFormat:@"%.1f miles", self.radiusSlider.value];
    [[NSUserDefaults standardUserDefaults] setFloat:self.radiusSlider.value forKey:USER_DEFAULTS_RADIUS];
}

@end