//
//  FlickrTVC.m
//  Flickr Local
//
//  Created by Will Smith on 11/9/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import "FlickrTVC.h"
#import "WillsFlickrFetcher.h"

@interface FlickrTVC ()
@end

// radius from the given lat/lon for which to return photos
#define LATLON_RADIUS (0.5)

@implementation FlickrTVC

@synthesize photos = _photos;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startFlickrFetch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)photos
{
    if (!_photos) {
        _photos = [NSArray array];
    }
    return _photos;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [[self tableView] reloadData];
}

- (void)startFlickrFetch
{
    
    CLLocationCoordinate2D lincolnMemorial = {38.889262, -77.048568};
    //CLLocationCoordinate2D home = {38.925162, -77.044052};
    //CLLocationCoordinate2D office = {38.914384, -77.041262};
    //CLLocationCoordinate2D kingsCloister = {38.816724, -77.075691};
    //CLLocationCoordinate2D jacksonHoleSquare = {43.479990, -110.761819};
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfig.allowsCellularAccess = YES;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[WillsFlickrFetcher URLforLatLon:lincolnMemorial withinRadius:LATLON_RADIUS]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                        }
                                                        else {
                                                            NSDictionary *flickrPropertyList;
                                                            NSData *flickrJSONData = [NSData dataWithContentsOfURL:localFile]; // will block if url is not local!
                                                            if (flickrJSONData) {
                                                                flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData options:0 error:NULL];
                                                            }
                                                            NSArray *photos = [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                            //NSLog(@"results: %@", flickrPropertyList);
                                                            NSLog(@"photos: %@", photos);
                                                            NSLog(@"photo: %@", photos[0]);
                                                            self.photos = photos;
                                                        }
                                                    }];
    [task resume];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrLocalPhotoCell" forIndexPath:indexPath];
    cell.textLabel.text = self.photos[indexPath.row][@"id"];
    cell.detailTextLabel.text = self.photos[indexPath.row][@"title"];
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
