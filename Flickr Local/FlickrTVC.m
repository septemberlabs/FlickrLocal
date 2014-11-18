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
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSMutableDictionary *imagesForTVC;
@property (strong, nonatomic) NSURLSession *urlSession;
@end

#define LATLON_RADIUS (0.5) // radius from the given lat/lon for which to return photos
#define CELL_HEIGHT 400 // height of entire cell
#define TOP_CAPTION_HEIGHT 50 // caption above photo
#define IMAGE_HEIGHT 300 // height of image within cell
#define BOTTOM_CAPTION_HEIGHT 50 // caption under photo
#define VERTICAL_MARGIN 200 // margin between cells

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

- (NSMutableDictionary *)imagesForTVC
{
    if (!_imagesForTVC) {
        _imagesForTVC = [NSMutableDictionary dictionary];
    }
    return _imagesForTVC;
}

- (NSURLSession *)urlSession
{
    if (!_urlSession) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = YES;
        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    return _urlSession;
}

- (void)startFlickrFetch
{
    //CLLocationCoordinate2D home = {38.925162, -77.044052};
    //CLLocationCoordinate2D lincolnMemorial = {38.889262, -77.048568};
    //CLLocationCoordinate2D office = {38.914384, -77.041262};
    CLLocationCoordinate2D kingsCloister = {38.816724, -77.075691};
    //CLLocationCoordinate2D jacksonHoleSquare = {43.479990, -110.761819};
    
    CLLocationCoordinate2D targetLocation = kingsCloister;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[WillsFlickrFetcher URLforLatLon:targetLocation withinRadius:LATLON_RADIUS]];
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request
            completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                if (!error) {
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
                else {
                    NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TOP_CAPTION_HEIGHT + IMAGE_HEIGHT + BOTTOM_CAPTION_HEIGHT + VERTICAL_MARGIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* TO DO:
        * Paint the text in the top caption using attributed strings and hyperlinking photographer name
        * Paint the text in the bottom caption using attributed strings and dynamic height
        * Get the photo looking correct (scaling, etc.)
        * Allow selection of the photo
        * Best practices for photo loading
     */
    
    static NSString *customTableCell = @"FlickrPhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customTableCell forIndexPath:indexPath];
    
    //[[cell.superview layer] setBorderWidth:2.0f];
    [[cell.contentView layer] setBorderWidth:2.0f];

    // set variables used throughout the method
    CGFloat width = cell.contentView.frame.size.width;
    NSDictionary *photo = self.photos[indexPath.row];
    NSString *photo_id = photo[@"id"];

    // prepare the top caption label
    CGRect topCaptionFrame = CGRectMake(0, 0, width, TOP_CAPTION_HEIGHT);
    UILabel *topCaptionLabel = [[UILabel alloc] initWithFrame:topCaptionFrame];
    topCaptionLabel.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:topCaptionLabel];
    
    // prepare the top caption content
    NSString *owner = photo[@"ownername"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    double secondsSince1970 = [[NSString stringWithString:photo[@"dateupload"]] doubleValue];
    NSDate *dateUploaded = [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
    NSString *dateUploadedString = [dateFormatter stringFromDate:dateUploaded];
    
    NSLog(@"ownername: %@", owner);
    NSLog(@"date uploaded: %@", dateUploadedString);
    
    // prepare the image view
    CGRect cellImageViewFrame = CGRectMake(0, TOP_CAPTION_HEIGHT, width, IMAGE_HEIGHT);
    UIImageView *cellImageView = [[UIImageView alloc] initWithFrame:cellImageViewFrame];
    cellImageView.opaque = NO; // disable unnecessary alpha blending
    cellImageView.contentMode = UIViewContentModeScaleAspectFill; // this is UIView's default anyway
    cellImageView.clipsToBounds = YES;
    cellImageView.backgroundColor = [UIColor redColor];
    [cell.contentView addSubview:cellImageView];
    
    // prepare the bottom caption label
    CGRect bottomCaptionFrame = CGRectMake(0, TOP_CAPTION_HEIGHT + IMAGE_HEIGHT, width, BOTTOM_CAPTION_HEIGHT);
    UILabel *bottomCaptionLabel = [[UILabel alloc] initWithFrame:bottomCaptionFrame];
    bottomCaptionLabel.backgroundColor = [UIColor blueColor];
    [cell.contentView addSubview:bottomCaptionLabel];

    // prepare the bottom caption content
    NSString *captionContent = [NSString stringWithFormat:@"Photo %@, title: %@", photo_id, photo[@"title"]];
    bottomCaptionLabel.text = captionContent;

    // prepare the photo content
    UIImage *cellImage = [self.imagesForTVC objectForKey:photo_id];
    if (cellImage != nil) {
        cellImageView.image = cellImage;
    }
    else {
        // go get the photo asynchronously
        NSURLRequest *request = [NSURLRequest requestWithURL:[WillsFlickrFetcher URLforPhoto:photo format:FlickrPhotoFormat320]];
        //NSLog(@"thumbnail url requested: %@", [[WillsFlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatSquare] absoluteString]);
        NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request
                completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                    if (!error) {
                        NSData *imageData = [NSData dataWithContentsOfURL:localFile];
                        //NSString *localFilename = [localFile absoluteString];
                        //NSLog(@"localFilename: %@", localFilename);
                        UIImage *image = [UIImage imageWithData:imageData];
                        [self.imagesForTVC setObject:image forKey:photo_id];
                        cellImageView.image = image;
                    }
                    else {
                        NSLog(@"Failed to download thumbnail for photo %@: %@", photo_id, error.localizedDescription);
                    }
                }];
        [task resume];
    }

    return cell;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrPhotoCell_old" forIndexPath:indexPath];
//    NSDictionary *photo = self.photos[indexPath.row];
//    NSString *photo_id = photo[@"id"];
//    cell.textLabel.text = photo_id;
//    cell.detailTextLabel.text = photo[@"title"];
//    UIImage *cellImage = [self.imagesForTVC objectForKey:photo_id];
//    if (cellImage != nil) {
//        cell.imageView.image = cellImage;
//    }
//    else {
//        // go get photo asynchronously
//        NSURLRequest *request = [NSURLRequest requestWithURL:[WillsFlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatSquare]];
//        //NSLog(@"thumbnail url requested: %@", [[WillsFlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatSquare] absoluteString]);
//        NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request
//                completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
//                    if (!error) {
//                        NSData *imageData = [NSData dataWithContentsOfURL:localFile];
//                        //NSString *localFilename = [localFile absoluteString];
//                        //NSLog(@"localFilename: %@", localFilename);
//                        UIImage *image = [UIImage imageWithData:imageData];
//                        [self.imagesForTVC setObject:image forKey:photo_id];
//                        cell.imageView.image = image;
//                    }
//                    else {
//                        NSLog(@"Failed to download thumbnail for photo %@: %@", photo_id, error.localizedDescription);
//                    }
//                }];
//        [task resume];
//    }
//    return cell;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
