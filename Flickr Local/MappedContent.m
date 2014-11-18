//
//  MappedContent.m
//  Flickr Local
//
//  Created by Will Smith on 11/18/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "MappedContent.h"

@implementation MappedContent

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = self.latitude;
    coordinate.longitude = self.longitude;
    
    return coordinate;
}

@end
