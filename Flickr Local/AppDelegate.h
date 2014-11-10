//
//  AppDelegate.h
//  Flickr Local
//
//  Created by Will Smith on 11/3/14.
//  Copyright (c) 2014 Will Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/* 
 
 Tasks:
 
 * Array of lats/lons
 * Query Flickr with chosen lat/lon
 
 Lincoln Memorial: (38.889262 , -77.048568)
 
 */





/*
 
 Classes:
 
 * Media container (UIView) that we subclass for Flickr image or Hoodie article
 * Image view controller
 * Stored locations
 * Extended FlickrFetcher
 
 */

@end

