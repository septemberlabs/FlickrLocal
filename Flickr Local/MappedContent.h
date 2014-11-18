//
//  MappedContent.h
//  Flickr Local
//
//  Created by Will Smith on 11/18/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MappedContent : NSObject <MKAnnotation>

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

/*
 universal:
 * hold lat/lon
 * display table view cell?
 * how to get data
 */

@end
