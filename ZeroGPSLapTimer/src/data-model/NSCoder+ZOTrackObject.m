//
//  NSCoder+ZOTrackObject.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/10/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "NSCoder+ZOTrackObject.h"

@implementation NSCoder (ZOTrackObject)

#pragma mark CLLocationCoordinate2D
- (void) encodeCLLocationCoordinate2D:(CLLocationCoordinate2D)coordinate forKey:(NSString*)key {
	[self encodeDouble:coordinate.latitude forKey:[key stringByAppendingString:@"+latitude"]];
	[self encodeDouble:coordinate.longitude forKey:[key stringByAppendingString:@"+longitude"]];
	
}

- (CLLocationCoordinate2D) decodeCLLocationCoordinate2DForKey:(NSString*)key {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = [self decodeDoubleForKey:[key stringByAppendingString:@"+latitude"]];
	coordinate.longitude = [self decodeDoubleForKey:[key stringByAppendingString:@"+longitude"]];
	return coordinate;
}

#pragma mark MKMapRect
- (void) encodeMKMapRect:(MKMapRect)mapRect forKey:(NSString*)key {
	[self encodeMKMapPoint:mapRect.origin forKey:[key stringByAppendingString:@"+origin"]];
	[self encodeMKMapSize:mapRect.size forKey:[key stringByAppendingString:@"+size"]];
}

- (MKMapRect) decodeMKMapRectForKey:(NSString*)key {
	MKMapRect mapRect;
	mapRect.origin = [self decodeMKMapPointForKey:[key stringByAppendingString:@"+origin"]];
	mapRect.size = [self decodeMKMapSizeForKey:[key stringByAppendingString:@"+size"]];
	return mapRect;
}


#pragma mark MKMapPoint
- (void) encodeMKMapPoint:(MKMapPoint)mapPoint forKey:(NSString*)key {
	[self encodeDouble:mapPoint.x forKey:[key stringByAppendingString:@"+x"]];
	[self encodeDouble:mapPoint.y forKey:[key stringByAppendingString:@"+y"]];
}

- (MKMapPoint) decodeMKMapPointForKey:(NSString*)key {
	MKMapPoint mapPoint;
	mapPoint.x = [self decodeDoubleForKey:[key stringByAppendingString:@"+x"]];
	mapPoint.y = [self decodeDoubleForKey:[key stringByAppendingString:@"+y"]];
	return mapPoint;
}

#pragma mark MKMapSize
- (void) encodeMKMapSize:(MKMapSize)mapSize forKey:(NSString*)key {
	[self encodeDouble:mapSize.width forKey:[key stringByAppendingString:@"+width"]];
	[self encodeDouble:mapSize.height forKey:[key stringByAppendingString:@"+height"]];
}

- (MKMapSize) decodeMKMapSizeForKey:(NSString*)key {
	MKMapSize mapSize;
	mapSize.width = [self decodeDoubleForKey:[key stringByAppendingString:@"+width"]];
	mapSize.height = [self decodeDoubleForKey:[key stringByAppendingString:@"+height"]];
	return mapSize;
}


@end
