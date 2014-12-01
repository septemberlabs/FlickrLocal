//
//  MapVC.m
//  Flickr Local
//
//  Created by Will Smith on 11/20/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapVC_old.h"

@interface MapVC_old ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapVC_old

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapViewAnnotations]; // we put this here and in the itemToMap setter because we don't know the order that they are called, so we need to be sure we update in the latter of the two (ie, both).
}

- (void)updateMapViewAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self.itemToMap];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (void)setItemToMap:(MappedContent *)itemToMap
{
    _itemToMap = itemToMap;
    [self updateMapViewAnnotations]; // we put this here and in the setMapView setter because we don't know the order that they are called, so we need to be sure we update in the latter of the two (ie, both).
}

@end
