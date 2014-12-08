//
//  HoodieVC.m
//  Flickr Local
//
//  Created by Will Smith on 11/20/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "HoodieVC.h"
#import "FlickrFetcher.h"
#import "MappedContent.h"
#import "MapVC_old.h"
#import "HoodieTableViewCell.h"

@interface HoodieVC ()
@property (strong, nonatomic) Fetcher *fetcher;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *itemsToDisplay;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation HoodieVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // configure the table view
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchData];
    
    self.mapView.delegate = self;
    
    // https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/CreateConfigureTableView/CreateConfigureTableView.html
    // perhaps only if the table view is instantiated in code instead of in storyboard?
    //self.view = self.tableView;
}

- (Fetcher *)fetcher
{
    if (!_fetcher) {
        _fetcher = [[FlickrFetcher alloc] init];
        _fetcher.delegate = self;
    }
    return _fetcher;
}

- (void)setLocationWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
    self.latitude = latitude;
    self.longitude = longitude;
    [self fetchData];
}

- (void)fetchData
{
    [self.fetcher fetchDataWithLatitude:self.latitude andLongitude:self.longitude];
}

- (void)receiveData:(NSArray *)fetchedResults
{
    self.itemsToDisplay = fetchedResults;
    [self.tableView reloadData];

    MappedContent *firstItemToDisplay = (MappedContent *)self.itemsToDisplay[0];
    [self reorientMapWithAnnotation:firstItemToDisplay];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemsToDisplay count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return TOP_CAPTION_HEIGHT + IMAGE_HEIGHT + BOTTOM_CAPTION_HEIGHT + VERTICAL_MARGIN;
    return 400;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HoodieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HoodieTableViewCell"];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HoodieTableViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.imageContainerView.backgroundColor = [UIColor redColor];

    MappedContent *itemToDisplay = (MappedContent *)self.itemsToDisplay[indexPath.row];
    cell.textBox.text = itemToDisplay.title;
    cell.leftUpperLabel.text = itemToDisplay.subtitle;
    
    // if the image data exists display it immediately. if not, add a block off the main queue to go grab and store it.
    if (itemToDisplay.actualImage != nil) {
        cell.imageContainerView.image = itemToDisplay.actualImage;
    }
    else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:itemToDisplay.largeURL]];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                if (!error) {
                    //NSLog(@"request.URL: %@", [request.URL absoluteString]);
                    //NSLog(@"photo.thumbnailURL: %@", photo.thumbnailURL);
                    itemToDisplay.actualImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                }
            }];
        [task resume];
    }
    return cell;
    
    /*
     
     WORKING
     
    static NSString *customTableCell = @"Hoodie Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customTableCell forIndexPath:indexPath];
    MappedContent *itemToDisplay = (MappedContent *)self.itemsToDisplay[indexPath.row];
    cell.textLabel.text = itemToDisplay.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Current row: %ld", (long)indexPath.row];
    return cell;
     */

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Visible rows: %@", [self.tableView indexPathsForVisibleRows]);
    
    NSIndexPath *topmostIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    MappedContent *itemToDisplay = (MappedContent *)self.itemsToDisplay[topmostIndexPath.row];
    NSDictionary *userInfo = @{ @"topmostItem" : itemToDisplay };
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(reorientMapWithTimer:)
                                                userInfo:userInfo
                                                 repeats:NO];
}

- (void)reorientMapWithAnnotation:(MappedContent *)itemToMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:itemToMap];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(itemToMap.coordinate, 1.0, 1.0);
    [self.mapView setRegion:region animated:YES];

    //[self.mapView setCenterCoordinate:itemToMap.coordinate animated:YES];
    //[self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (void)reorientMapWithTimer:(NSTimer *)timer
{
    NSLog(@"Timer fired.");
    MappedContent *currentTopmostItem = (MappedContent *)timer.userInfo[@"topmostItem"];
    NSLog(@"Item: %@", currentTopmostItem.title);
    [self reorientMapWithAnnotation:currentTopmostItem];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    // courtesy: http://stackoverflow.com/questions/6808876/how-do-i-animate-mkannotationview-drop
    MKAnnotationView *aV;
    
    for (aV in views) {
        
        // Don't pin drop if annotation is user location
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        // Check if current annotation is inside visible map rect, else go to next one
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = aV.frame;
        
        // Move annotation out of view
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
        
        // Animate drop
        [UIView animateWithDuration:0.5 delay:0.04*[views indexOfObject:aV] options: UIViewAnimationOptionCurveLinear animations:^{
            
            aV.frame = endFrame;
            
            // Animate squash
        } completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                    
                } completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            aV.transform = CGAffineTransformIdentity;
                        }];
                    }
                }];
            }
        }];
    }
}

#pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([segue.identifier isEqualToString:@"Pop Up Map"]) {
         if ([segue.destinationViewController isKindOfClass:[MapVC_old class]]) {
             MapVC_old *mapvc = (MapVC_old *)segue.destinationViewController;
             NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
             if (indexPath) {
                 MappedContent *itemToMap = (MappedContent *)self.itemsToDisplay[indexPath.row];
                 mapvc.itemToMap = itemToMap;
             }
         }
     }
 }

@end











