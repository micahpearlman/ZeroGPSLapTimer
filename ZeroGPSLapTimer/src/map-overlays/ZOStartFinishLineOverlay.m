//
//  ZOStartFinishLineAnnotation.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOStartFinishLineOverlay.h"

static const float kFinishLineInitialWidth = 15.0f;

CLLocationCoordinate2D MKCoordinateOffsetFromCoordinate(CLLocationCoordinate2D coordinate, CLLocationDistance offsetLatMeters, CLLocationDistance offsetLongMeters) {
    MKMapPoint offsetPoint = MKMapPointForCoordinate(coordinate);
	
    CLLocationDistance metersPerPoint = MKMetersPerMapPointAtLatitude(coordinate.latitude);
    double latPoints = offsetLatMeters / metersPerPoint;
    offsetPoint.y += latPoints;
    double longPoints = offsetLongMeters / metersPerPoint;
    offsetPoint.x += longPoints;
	
    CLLocationCoordinate2D offsetCoordinate = MKCoordinateForMapPoint(offsetPoint);
    return offsetCoordinate;
}


@interface ZOStartFinishLineOverlay () {
	CLLocationCoordinate2D	_coordinate;
	MKMapRect				_boundingMapRect;
	
	CLLocationCoordinate2D	_lineEnds[2];
	BOOL					_isSelected;

}

@end

@implementation ZOStartFinishLineOverlay


@synthesize boundingMapRect		= _boundingMapRect;
@synthesize delegate;
@dynamic	lineEnds;
@dynamic	isSelected;
@dynamic	coordinate;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord {
	self = [super init];
	if ( self ) {
		[self setCoordinate:coord];
	}
	
	return self;
}

- (CLLocationCoordinate2D*)lineEnds {
	return _lineEnds;
}

- (BOOL) isSelected {
	return _isSelected;
}

- (void) setIsSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	if ( [delegate respondsToSelector:@selector(zoStartFinishLineOverlay:isSelected:)]) {
		[delegate zoStartFinishLineOverlay:self isSelected:isSelected];
	}
}

- (CLLocationCoordinate2D) coordinate {
	return _coordinate;
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate {
	_coordinate = coordinate;

	_lineEnds[0] = MKCoordinateOffsetFromCoordinate( _coordinate, -kFinishLineInitialWidth/2, 0 );
	_lineEnds[1] = MKCoordinateOffsetFromCoordinate( _coordinate, +kFinishLineInitialWidth/2, 0 );
	
	
	MKMapPoint mapPointCenter = MKMapPointForCoordinate(_coordinate);
	double mapPointRadius = (kFinishLineInitialWidth/2.0f) * kFinishLineInitialWidth;
	MKMapPoint upperLeftMapPoint = MKMapPointMake(mapPointCenter.x - mapPointRadius, mapPointCenter.y - mapPointRadius );
	
	self.boundingMapRect = MKMapRectMake( upperLeftMapPoint.x, upperLeftMapPoint.y, mapPointRadius * 2, mapPointRadius * 2);

	if ( [delegate respondsToSelector:@selector(zoStartFinishLineOverlay:movedTo:)] ) {
		[delegate zoStartFinishLineOverlay:self movedTo:coordinate];
	}
}

@end
