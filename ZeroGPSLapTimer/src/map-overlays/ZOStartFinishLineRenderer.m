//
//  ZOStartFinishLineAnnotationView.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOStartFinishLineRenderer.h"

static const int kFinishLineInitialWidth = 10;

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

@interface ZOStartFinishLineAnnotationRenderer () {
	UIBezierPath*			_line;
	CLLocationCoordinate2D	_lineEnds[2];
}

@end

@implementation ZOStartFinishLineAnnotationRenderer

- (id)initWithOverlay:(id<MKOverlay>)overlay {
	self = [super initWithOverlay:overlay];
	if ( self ) {
		CLLocationCoordinate2D centerCoord = [overlay coordinate];
		_lineEnds[0] = MKCoordinateOffsetFromCoordinate( centerCoord, -kFinishLineInitialWidth/2, 0 );
		_lineEnds[1] = MKCoordinateOffsetFromCoordinate( centerCoord, +kFinishLineInitialWidth/2, 0 );
		
		CGPoint ends[2];
		ends[0] = [self pointForMapPoint:MKMapPointForCoordinate( _lineEnds[0] )];
		ends[1] = [self pointForMapPoint:MKMapPointForCoordinate( _lineEnds[1] )];
		
		_line = [UIBezierPath bezierPath];
		[_line moveToPoint:ends[0]];
		[_line addLineToPoint:ends[1]];
		
	}
	return self;
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect
             zoomScale:(MKZoomScale)zoomScale {
	return YES;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context {
	
	[super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
	
	UIGraphicsPushContext( context ); {
		[[UIColor redColor] setStroke];
		[_line setLineWidth:2];
		[_line stroke];
	} UIGraphicsPopContext();
	
}

@end
