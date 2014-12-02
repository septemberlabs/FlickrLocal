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

    return pinView;
}

#pragma mark - Search Display Controller TVC

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection called.");
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath called.");
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView called.");
    return 0;
}

#pragma mark - Search Bar

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidEndEditing called.");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked called with text: %@", searchBar.text);
    
    // Create and initialize a search request object.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    NSString *query = searchBar.text;
    request.naturalLanguageQuery = query;
    // TO DO: set the region to the DMV
    // request.region = self.map.region;
    
    // Create and initialize a search object.
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // Start the search and display the results as annotations on the map.
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        if (!error) {
            NSMutableArray *placemarks = [NSMutableArray array];
            for (MKMapItem *item in response.mapItems) {
                [placemarks addObject:item.name];
            }
            //[self.map removeAnnotations:[self.map annotations]];
            //[self.map showAnnotations:placemarks animated:NO];
        }
        else {
            NSLog(@"Search failed: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"1 searchDisplayControllerWillBeginSearch called.");
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"2 searchDisplayControllerDidBeginSearch called.");
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"3 searchDisplayControllerWillEndSearch called.");
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"4 searchDisplayControllerDidEndSearch called.");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"5 didLoadSearchResultsTableView called.");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"6 willUnloadSearchResultsTableView called.");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"7 willShowSearchResultsTableView called.");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"8 didShowSearchResultsTableView called.");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"9 willHideSearchResultsTableView called.");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"10 didHideSearchResultsTableView called.");
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"11 shouldReloadTableForSearchString called.");
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSLog(@"12 shouldReloadTableForSearchScope called.");
    return YES;
}

@end