//
//  ZOStartFinishLineAnnotationView.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOStartFinishLineRenderer.h"
#import "ZOStartFinishLineOverlay.h"

@interface ZOStartFinishLineRenderer () <ZOStartFinishLineOverlayDelegate> {
	UIBezierPath*			_line;
	UIBezierPath*			_circle;
	CGAffineTransform		_transform;
}

@end

@implementation ZOStartFinishLineRenderer

- (id)initWithOverlay:(id<MKOverlay>)overlay {
	self = [super initWithOverlay:overlay];
	if ( self ) {
		ZOStartFinishLineOverlay* startFinishLineOverlay = (ZOStartFinishLineOverlay*)overlay;

		startFinishLineOverlay.delegate = self;
		
		
		CGPoint ends[2];
		CGPoint center = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.coordinate )];
		ends[0] = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.lineEnds[0] )];
		ends[0].x = ends[0].x - center.x;
		ends[0].y = ends[0].y - center.y;
		ends[1] = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.lineEnds[1] )];
		ends[1].x = ends[1].x - center.x;
		ends[1].y = ends[1].y - center.y;
		
		_line = [UIBezierPath bezierPath];
		[_line moveToPoint:ends[0]];
		[_line addLineToPoint:ends[1]];

		
		_transform = CGAffineTransformMakeTranslation( center.x, center.y );
		
		_circle = [UIBezierPath bezierPathWithOvalInRect:[self rectForMapRect:startFinishLineOverlay.boundingMapRect]];

		
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
	
	ZOStartFinishLineOverlay* startFinishLineOverlay = (ZOStartFinishLineOverlay*)self.overlay;
	
	UIGraphicsPushContext( context ); {
		if ( startFinishLineOverlay.isSelected ) {
			[[UIColor redColor] setFill];
			[_circle setLineWidth:12];
			[_circle fillWithBlendMode:kCGBlendModeNormal alpha:0.5];
			[_circle stroke];
		}

		CGContextConcatCTM( context, _transform );
		[[UIColor greenColor] setStroke];
		[_line setLineWidth:12];
		[_line stroke];
		
	} UIGraphicsPopContext();
	
}


#pragma mark ZOStartFinishLineOverlayDelegate

- (void)zoStartFinishLineOverlay:(ZOStartFinishLineOverlay*)startFinishOverlay isSelected:(BOOL)isSelected {
	[self setNeedsDisplay];
}
- (void)zoStartFinishLineOverlay:(ZOStartFinishLineOverlay*)startFinishOverlay movedTo:(CLLocationCoordinate2D)coordinate {
	
	CGPoint center = [self pointForMapPoint:MKMapPointForCoordinate( startFinishOverlay.coordinate )];
	_transform = CGAffineTransformMakeTranslation( center.x, center.y );

	[self setNeedsDisplay];
}


@end
