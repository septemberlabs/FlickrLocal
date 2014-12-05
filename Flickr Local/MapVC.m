//
//  MapVC.m
//  Flickr Local
//
//  Created by Will Smith on 11/29/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "MapVC.h"
#import "SimpleAnnotation.h"
#import <AddressBookUI/AddressBookUI.h>

@interface MapVC ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIImage *customPin;
@property (strong, nonatomic) NSArray *searchResults; // of MKPlacemark
@end


@implementation MapVC

@synthesize searchResults = _searchResults;

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
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableCellIdentifier = @"searchResultsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reusableCellIdentifier];
    }
    MKPlacemark *placemark = (MKPlacemark *)[self.searchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.text = placemark.name;
    
    // make the detail text the fully formatted address of the place.
    cell.detailTextLabel.text = [self prepareAddressString:placemark withoutUS:YES];
    
    return cell;
}

// give the option to suppress "United States" from the formatted address string.
- (NSString *)prepareAddressString:(MKPlacemark *)placemark withoutUS:(BOOL)withoutUS
{
    NSMutableArray *linesOfAddress = placemark.addressDictionary[ @"FormattedAddressLines"];
    if (withoutUS) {
        // the last object in the array is the country.
        NSString *country = [linesOfAddress lastObject];
        if ([country isEqualToString:@"United States"]) {
            [linesOfAddress removeLastObject];
        }
    }
    NSString *addressString = [linesOfAddress componentsJoinedByString:@", "];
    return addressString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.searchDisplayController setActive:NO animated:YES];
    
    MKPlacemark *selectedSearchResult = self.searchResults[indexPath.row];

    NSString *formattedAddressString = [self prepareAddressString:selectedSearchResult withoutUS:YES];
    
    // create a new annotation in order to set title and subtitle how we want. using MKPlacemark as the annotation doesn't permit that flexibility.
    SimpleAnnotation *annotation = [[SimpleAnnotation alloc] initWithTitle:selectedSearchResult.name Location:selectedSearchResult.coordinate];
    annotation.subtitle = formattedAddressString;

    self.searchDisplayController.searchBar.text = formattedAddressString;
    
    // clear existing annotations and add our new one.
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView addAnnotation:annotation];
    [self.mapView showAnnotations:[self.mapView annotations] animated:YES];
}

- (NSArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [NSArray array];
        self.searchResults = _searchResults;
    }
    return _searchResults;
}

- (void)setSearchResults:(NSArray *)searchResults
{
    _searchResults = searchResults;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - Search function
- (void)executeSearch:(NSString *)searchString
{
    // Create and initialize a search request object.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    // TO DO: set the region to the DMV
    CLLocationCoordinate2D zeroMilestone; zeroMilestone.latitude = 38.895108; zeroMilestone.longitude = -77.036548;
    request.region = MKCoordinateRegionMakeWithDistance(zeroMilestone, 50.0, 50.0);
    
    // Create and initialize a search object.
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // Start the search and display the results as annotations on the map.
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
         if (!error) {
             NSMutableArray *placemarks = [NSMutableArray array];
             for (MKMapItem *item in response.mapItems) {
                 [placemarks addObject:item.placemark];
             }
             self.searchResults = placemarks;
         }
         else {
             NSLog(@"Search failed: %@", error.localizedDescription);
         }
    }];
}

#pragma mark - Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self executeSearch:searchBar.text];
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
    //tableView.hidden = YES;
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
    //tableView.hidden = YES;
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
    [self executeSearch:searchString];
    return YES;
}

@end