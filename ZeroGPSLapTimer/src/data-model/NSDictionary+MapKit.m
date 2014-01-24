//
//  NSDictionary+MapKit.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/24/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "NSDictionary+MapKit.h"

@implementation NSDictionary (MapKit)

+ (NSDictionary*) dictionaryFromMKMapPoint:(MKMapPoint)mapPoint {
	NSDictionary* dictionary = @{ @"x":  [NSNumber numberWithDouble:mapPoint.x],
								  @"y":  [NSNumber numberWithDouble:mapPoint.y] };
	return dictionary;
}

+ (NSDictionary*) dictionaryFromMKMapSize:(MKMapSize)mapSize {
	NSDictionary* dictionary = @{ @"width" : [NSNumber numberWithDouble:mapSize.width],
								  @"height" : [NSNumber numberWithDouble:mapSize.height] };
	return dictionary;
}
+ (NSDictionary*) dictionaryFromMKMapRect:(MKMapRect)mapRect {
	NSDictionary* dictionary = @{ @"origin": [NSDictionary dictionaryFromMKMapPoint:mapRect.origin],
								  @"size": [NSDictionary dictionaryFromMKMapSize:mapRect.size] };
	return dictionary;
}

- (MKMapPoint) MKMapPoint {
	MKMapPoint mapPoint;
	mapPoint.x = [((NSNumber*)[self objectForKey:@"x"]) doubleValue];
	mapPoint.y = [((NSNumber*)[self objectForKey:@"y"]) doubleValue];
	return mapPoint;
}

- (MKMapSize) MKMapSize {
	MKMapSize mapSize;
	mapSize.width = [((NSNumber*)[self objectForKey:@"width"]) doubleValue];
	mapSize.height = [((NSNumber*)[self objectForKey:@"height"]) doubleValue];
	return mapSize;
}
- (MKMapRect) MKMapRect {
	MKMapRect mapRect;
	mapRect.origin = [((NSDictionary*)[self objectForKey:@"origin"]) MKMapPoint];
	mapRect.size = [((NSDictionary*)[self objectForKey:@"size"]) MKMapSize];
	return mapRect;
}


@end
