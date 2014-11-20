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

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location;

@end
