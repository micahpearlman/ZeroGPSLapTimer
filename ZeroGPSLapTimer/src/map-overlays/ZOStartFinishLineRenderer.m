//
//  ZOStartFinishLineAnnotationView.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOStartFinishLineRenderer.h"
#import "ZOStartFinishLineOverlay.h"

@interface ZOStartFinishLineRenderer () {
	UIBezierPath*			_line;
}

@end

@implementation ZOStartFinishLineRenderer

- (id)initWithOverlay:(id<MKOverlay>)overlay {
	self = [super initWithOverlay:overlay];
	if ( self ) {
		ZOStartFinishLineOverlay* startFinishLineOverlay = (ZOStartFinishLineOverlay*)overlay;
		
		CGPoint ends[2];
		ends[0] = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.lineEnds[0] )];
		ends[1] = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.lineEnds[1] )];
		
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
		[_line setLineWidth:12];
		[_line stroke];
	} UIGraphicsPopContext();
	
}

@end
