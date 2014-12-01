//
//  MapVC.h
//  Flickr Local
//
//  Created by Will Smith on 11/20/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MappedContent.h"

@interface MapVC_old : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) MappedContent *itemToMap;

@end
