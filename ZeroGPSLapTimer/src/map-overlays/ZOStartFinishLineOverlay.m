//
//  ZOStartFinishLineAnnotation.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOStartFinishLineOverlay.h"

@interface ZOStartFinishLineOverlay () {
	CLLocationCoordinate2D	_coordinate;
	MKMapRect				_boundingMapRect;

}

@end

@implementation ZOStartFinishLineOverlay

@synthesize coordinate			= _coordinate;
@synthesize boundingMapRect		= _boundingMapRect;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord {
	self = [super init];
	if ( self ) {
		self.coordinate = coord;
		
		MKMapPoint origin = MKMapPointForCoordinate(coord);
		MKMapSize size = MKMapSizeWorld;
        size.width /= 4.0;
        size.height /= 4.0;
        self.boundingMapRect = (MKMapRect) { origin, size };
        MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
        self.boundingMapRect = MKMapRectIntersection(self.boundingMapRect, worldRect);


	}
	
	return self;
}
@end
