//
//  MapVC.m
//  Flickr Local
//
//  Created by Will Smith on 11/29/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "MapVC.h"

@interface MapVC ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIImage *customPin;

@end

@implementation MapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.mapView.delegate = self;
    [self.mapView setDelegate:self];
    
    CLAuthorizationStatus locationAuthorizationStatus = [CLLocationManager authorizationStatus];
    if ((locationAuthorizationStatus != kCLAuthorizationStatusRestricted) &&
        (locationAuthorizationStatus != kCLAuthorizationStatusDenied)) {

        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;

#warning We need to figure out what happens with this method call since it's asynchronous
        if (locationAuthorizationStatus == kCLAuthorizationStatusNotDetermined) {
            // new in iOS 8.0, so first check that CLLocationManager supports it.
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
        }
        
        if (![CLLocationManager locationServicesEnabled]) {
            // Display error message: User has turned off location services for the entire device
        }
        else {
            NSLog(@"You're good.");
        }
        
    }
    else {
        // Display error message: User has restricted or denied location services
    }
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // just reiterating the default
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // just reiterating the default
    [self.locationManager startUpdatingLocation];
    
    //self.mapView.showsUserLocation = YES;
    //[self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations called.");
    
    // Last object contains the most recent location
    CLLocation *currentLocation = [locations lastObject];
    
    NSLog(@"I am here: %@", currentLocation.description);

    // If the location is more than 5 minutes old, ignore it
    if ([currentLocation.timestamp timeIntervalSinceNow] > 300) {
        return;
    }

    [self.locationManager stopUpdatingLocation];
    
    MKPointAnnotation *currentLocationAnnotation = [[MKPointAnnotation alloc] init];
    [currentLocationAnnotation setCoordinate:currentLocation.coordinate];
    currentLocationAnnotation.title = @"Current location.";
    currentLocationAnnotation.subtitle = @"Drag to choose a different location.";
    [self.mapView addAnnotation:currentLocationAnnotation];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKUserLocation *fromMapView = self.mapView.userLocation;
    CLLocationCoordinate2D fromMapViewCoordinates = fromMapView.coordinate;
    NSLog(@"I am here 1: %f, %f", fromMapViewCoordinates.latitude, fromMapViewCoordinates.longitude);
    
    MKUserLocation *fromParameter = userLocation;
    CLLocationCoordinate2D fromParameterCoordinates = fromParameter.coordinate;
    NSLog(@"I am here 2: %f, %f", fromParameterCoordinates.latitude, fromParameterCoordinates.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError called: %@", error.description);
}

/*
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionDidChangeAnimated called.");
    MKPointAnnotation *pin = [[self.mapView annotations] lastObject];
    [pin setCoordinate:self.mapView.centerCoordinate];
    // for later: how to do it like Uber - http://stackoverflow.com/questions/5164141/iphone-ubercab-aka-uber-map-coordinate
}
 */

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    // Try to dequeue an existing pin view first.
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"DraggablePinAnnotationView"];
    
    if (!pinView) {
        // If an existing pin view was not available, create one.
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"DraggablePinAnnotationView"];
        pinView.draggable = NO;
        pinView.animatesDrop = YES;
        pinView.enabled = YES;
        pinView.canShowCallout = YES;
    }
    else {
        pinView.annotation = annotation;
    }

    NSLog(@"Can show callout? %d", pinView.canShowCallout);
    return pinView;
}

@end
