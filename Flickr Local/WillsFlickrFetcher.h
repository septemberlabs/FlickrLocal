//
//  WillsFlickrFetcher.h
//  Flickr Local
//
//  Created by Will Smith on 11/3/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "FlickrFetcher.h"
@import CoreLocation;

@interface WillsFlickrFetcher : FlickrFetcher

+ (NSURL *)URLforLatLon:(CLLocationCoordinate2D)latlon withinRadius:(float)radius;

@end
