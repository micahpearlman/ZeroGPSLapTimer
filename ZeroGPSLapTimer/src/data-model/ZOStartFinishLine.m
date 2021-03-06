//
//  ZOStartFinishLineAnnotation.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOStartFinishLine.h"
#import "NSCoder+MapKit.h"

static inline double zoDegreesToRadians (double degrees) {return degrees * M_PI/180.0;}

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


@interface ZOStartFinishLine () {
	CLLocationCoordinate2D	_coordinate;
	MKMapRect				_boundingMapRect;
	CLCoordinateLineSegment	_line;
	BOOL					_isSelected;
	double					_angle;

}

@end

@implementation ZOStartFinishLine


@synthesize boundingMapRect		= _boundingMapRect;
@synthesize delegate;
@synthesize line = _line;
@dynamic	isSelected;
@dynamic	coordinate;
@dynamic	rotate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord {
	self = [super init];
	if ( self ) {
		_angle = 0;
		[self setCoordinate:coord];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if ( self ) {
		_angle = [aDecoder decodeDoubleForKey:@"angle"];
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeDouble:_angle forKey:@"angle"];
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
}


- (BOOL) isSelected {
	return _isSelected;
}

- (void) setIsSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	if ( [delegate respondsToSelector:@selector(zoTrackObject:isSelected:)]) {
		[delegate zoTrackObject:self isSelected:isSelected];
	}
}

- (CLLocationCoordinate2D) coordinate {
	return _coordinate;
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate {
	_coordinate = coordinate;
	
	CGPoint lineEnds[2] = { { -kFinishLineInitialWidth/2, 0}, { +kFinishLineInitialWidth/2, 0} };
	CGAffineTransform rotationTransform = CGAffineTransformMakeRotation( -_angle );	// NOTE: negative angle!
	lineEnds[0] = CGPointApplyAffineTransform( lineEnds[0], rotationTransform );
	lineEnds[1] = CGPointApplyAffineTransform( lineEnds[1], rotationTransform );
	_line.start = MKCoordinateOffsetFromCoordinate( _coordinate, lineEnds[0].x, lineEnds[0].y );
	_line.end = MKCoordinateOffsetFromCoordinate( _coordinate, lineEnds[1].x, lineEnds[1].y );
	
	
	MKMapPoint mapPointCenter = MKMapPointForCoordinate(_coordinate);
	double mapPointRadius = (kFinishLineInitialWidth/2.0f) * kFinishLineInitialWidth;
	MKMapPoint upperLeftMapPoint = MKMapPointMake(mapPointCenter.x - mapPointRadius, mapPointCenter.y - mapPointRadius );
	
	self.boundingMapRect = MKMapRectMake( upperLeftMapPoint.x, upperLeftMapPoint.y, mapPointRadius * 2, mapPointRadius * 2);

	if ( [delegate respondsToSelector:@selector(zoTrackObject:movedCoordinate:)] ) {
		[delegate zoTrackObject:self movedCoordinate:_coordinate];
	}
}

- (double)rotate {
	return _angle;
}

- (void)setRotate:(double)rotate {
	_angle = rotate;
	self.coordinate = _coordinate;
}

- (BOOL) checkLineSegmentIntersects:(CLCoordinateLineSegment)line withResult:(CLLocationCoordinate2D*)intersection {
		
	return CLCoordinateLineSegmentIntersecting( line, _line, intersection );
}

@end
