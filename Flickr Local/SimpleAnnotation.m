//
//  SimpleAnnotation.m
//  Flickr Local
//
//  Created by Will Smith on 12/4/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "SimpleAnnotation.h"

@implementation SimpleAnnotation

- (id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location
{
    self = [super init];
    
    if (self) {
        _title = newTitle;
        _coordinate = location;
    }
    return self;
}

@end
