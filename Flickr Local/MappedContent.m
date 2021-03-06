//
//  MappedContent.m
//  Flickr Local
//
//  Created by Will Smith on 11/18/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "MappedContent.h"

@implementation MappedContent

@synthesize coordinate = _coordinate;

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
