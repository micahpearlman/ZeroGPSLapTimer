//
//  NSCoder+ZOTrackObject.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/10/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface NSCoder (ZOTrackObject)

// CLLocationCoordinate2D
- (void) encodeCLLocationCoordinate2D:(CLLocationCoordinate2D)coordinate forKey:(NSString*)key;
- (CLLocationCoordinate2D) decodeCLLocationCoordinate2DForKey:(NSString*)key;

// MKMapRect
- (void) encodeMKMapRect:(MKMapRect)mapRect forKey:(NSString*)key;
- (MKMapRect) decodeMKMapRectForKey:(NSString*)key;

// MKMapPoint
- (void) encodeMKMapPoint:(MKMapPoint)mapPoint forKey:(NSString*)key;
- (MKMapPoint) decodeMKMapPointForKey:(NSString*)key;

// MKMapSize
- (void) encodeMKMapSize:(MKMapSize)mapSize forKey:(NSString*)key;
- (MKMapSize) decodeMKMapSizeForKey:(NSString*)key;

@end
