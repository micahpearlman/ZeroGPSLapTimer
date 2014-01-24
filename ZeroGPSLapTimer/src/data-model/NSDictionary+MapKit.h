//
//  NSDictionary+MapKit.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/24/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NSDictionary (MapKit)

+ (NSDictionary*) dictionaryFromMKMapPoint:(MKMapPoint)mapPoint;
+ (NSDictionary*) dictionaryFromMKMapSize:(MKMapSize)mapSize;
+ (NSDictionary*) dictionaryFromMKMapRect:(MKMapRect)mapRect;

- (MKMapPoint) MKMapPoint;
- (MKMapSize) MKMapSize;
- (MKMapRect) MKMapRect;

@end
