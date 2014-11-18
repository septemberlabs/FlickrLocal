//
//  WillsFlickrFetcher.m
//  Flickr Local
//
//  Created by Will Smith on 11/3/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "WillsFlickrFetcher.h"

@implementation WillsFlickrFetcher

+ (NSURL *)URLforLatLon:(CLLocationCoordinate2D)latlon withinRadius:(float)radius
{
    return [self URLForQuery:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&lat=%f&lon=%f&radius=%f&per_page=11&extras=original_format,tags,description,geo,date_upload,owner_name,place_url", latlon.latitude, latlon.longitude, radius]];
}

@end
