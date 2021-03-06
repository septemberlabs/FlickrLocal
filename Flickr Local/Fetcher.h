//
//  Fetcher.h
//  Flickr Local
//
//  Created by Will Smith on 11/18/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@protocol FetcherView; // forward declaration

@interface Fetcher : NSObject

@property (nonatomic, weak) id<FetcherView> delegate; // once fetch is executed, resulting data is sent to this delegate
@property (strong, nonatomic) NSURLSession *urlSession;

- (void)fetchDataWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude; // essentially an abstract method that all subclasses must implement

// constants used for pre-chosen locations
extern CLLocationCoordinate2D const home;
extern CLLocationCoordinate2D const lincolnMemorial;
extern CLLocationCoordinate2D const office;
extern CLLocationCoordinate2D const kingsCloister;
extern CLLocationCoordinate2D const jacksonHoleSquare;
extern float const LATLON_RADIUS;

@end


// delegate protocol
@protocol FetcherView <NSObject>
@required
- (void)receiveData:(NSArray *)fetchedResults;
@end // end of delegate protocol
