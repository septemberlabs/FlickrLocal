//
//  FlickrFetcher.h
//
//  Created for Stanford CS193p Fall 2013.
//  Copyright 2013 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fetcher.h"

// key paths to photos or places at top-level of Flickr results
#define FLICKR_RESULTS_PHOTOS @"photos.photo"
#define FLICKR_RESULTS_PLACES @"places.place"

// keys (paths) to values in a photo dictionary
#define FLICKR_PHOTO_TITLE @"title"
#define FLICKR_PHOTO_DESCRIPTION @"description._content"
#define FLICKR_PHOTO_ID @"id"
#define FLICKR_PHOTO_OWNER @"ownername"
#define FLICKR_PHOTO_UPLOAD_DATE @"dateupload" // in seconds since 1970
#define FLICKR_PHOTO_PLACE_ID @"place_id"

// keys (paths) to values in a places dictionary (from TopPlaces)
#define FLICKR_PLACE_NAME @"_content"
#define FLICKR_PLACE_ID @"place_id"

// keys applicable to all types of Flickr dictionaries
#define FLICKR_LATITUDE @"latitude"
#define FLICKR_LONGITUDE @"longitude"
#define FLICKR_TAGS @"tags"

typedef enum {  // from https://www.flickr.com/services/api/misc.urls.html
    /* added by Will */
    FlickrPhotoFormat240 = 4, // small, 240 on longest side
    FlickrPhotoFormat320 = 8, // small, 320 on longest side
    FlickrPhotoFormat500 = 16, // medium, 500 on longest side
    
    FlickrPhotoFormatSquare = 1,    // thumbnail
	FlickrPhotoFormatLarge = 2,     // normal size
	FlickrPhotoFormatOriginal = 64  // high resolution
} FlickrPhotoFormat;

@interface FlickrFetcher : Fetcher // added by Will (originally subclassed from NSObject)

+ (NSURL *)URLForQuery:(NSString *)query;

+ (NSURL *)URLforTopPlaces;

+ (NSURL *)URLforPhotosInPlace:(id)flickrPlaceId maxResults:(int)maxResults;

+ (NSURL *)URLforPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format;

+ (NSURL *)URLforRecentGeoreferencedPhotos;

+ (NSURL *)URLforInformationAboutPlace:(id)flickrPlaceId;

+ (NSString *)extractNameOfPlace:(id)placeId fromPlaceInformation:(NSDictionary *)place;
+ (NSString *)extractRegionNameFromPlaceInformation:(NSDictionary *)placeInformation;

/* added by Will */
+ (NSURL *)URLforLatLon:(CLLocationCoordinate2D)latlon withinRadius:(float)radius;

/* Photo dictionary looks like this:

 accuracy = 16;
 context = 0;
 dateupload = 1415584129;
 description =     {
 "_content" = "King St. at Scroggins Rd. Alexandria VA";
 };
 farm = 4;
 "geo_is_contact" = 0;
 "geo_is_family" = 0;
 "geo_is_friend" = 0;
 "geo_is_public" = 1;
 id = 15133512503;
 isfamily = 0;
 isfriend = 0;
 ispublic = 1;
 latitude = "38.820697";
 longitude = "-77.079368";
 originalformat = jpg;
 originalsecret = afb43ee163;
 owner = "65057563@N00";
 ownername = sssdc1;
 "place_id" = elpmX2ZTUb1Fiz94;
 secret = 2664a6d316;
 server = 3938;
 tags = "alexandria arlington virginia washingtondc dc districtofcolumbia unitedstates historic marker boundarystone";
 title = "DC boundary stone SE3";
 woeid = 2378131;
 */

@end
