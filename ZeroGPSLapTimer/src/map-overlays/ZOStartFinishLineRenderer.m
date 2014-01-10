//
//  ZOStartFinishLineAnnotationView.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOStartFinishLineRenderer.h"
#import "ZOStartFinishLine.h"
#import "ZOTrackObjectDelegate.h"

@interface ZOStartFinishLineRenderer () <ZOTrackObjectDelegate> {
	UIBezierPath*			_line;
	UIBezierPath*			_circle;
	CGAffineTransform		_transform;
}

@end

@implementation ZOStartFinishLineRenderer

@synthesize parent;

- (id)initWithOverlay:(id<MKOverlay>)overlay {
	self = [super initWithOverlay:overlay];
	if ( self ) {
		ZOStartFinishLine* startFinishLineOverlay = (ZOStartFinishLine*)overlay;

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
		
		CGRect rect = [self rectForMapRect:startFinishLineOverlay.boundingMapRect];
		rect.origin.x = rect.origin.x - center.x;
		rect.origin.y = rect.origin.y - center.y;
		_circle = [UIBezierPath bezierPathWithOvalInRect:rect];

		
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
	
	ZOStartFinishLine* startFinishLineOverlay = (ZOStartFinishLine*)self.overlay;
	
	CGPoint ends[2];
	CGPoint center = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.coordinate )];
	ends[0] = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.lineEnds[0] )];
	ends[0].x = ends[0].x - center.x;
	ends[0].y = ends[0].y - center.y;
	ends[1] = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.lineEnds[1] )];
	ends[1].x = ends[1].x - center.x;
	ends[1].y = ends[1].y - center.y;
	
	
	UIGraphicsPushContext( context ); {
		CGContextConcatCTM( context, _transform );
		if ( startFinishLineOverlay.isSelected ) {
			[[UIColor redColor] setFill];
			[_circle setLineWidth:12];
			[_circle fillWithBlendMode:kCGBlendModeNormal alpha:0.5];
			[_circle stroke];
		}

		CGContextBeginPath( context );
		CGContextSetLineWidth( context, 12 );
		CGContextSetStrokeColorWithColor( context, [UIColor greenColor].CGColor );
		CGContextMoveToPoint( context, ends[0].x, ends[0].y );
		CGContextAddLineToPoint( context, ends[1].x, ends[1].y );
		CGContextStrokePath( context );
		
	} UIGraphicsPopContext();
	
}

- (void) setNeedsDisplay {
	[super setNeedsDisplay];
	
	self.isDirty = YES;
	[parent setNeedsDisplay];
}


#pragma mark ZOTrackObjectDelegate


- (void) zoTrackObject:(id<ZOTrackObject>) trackObject isSelected:(BOOL)isSelected {
	[self setNeedsDisplay];
}
- (void) zoTrackObject:(id<ZOTrackObject>) trackObject movedCoordinate:(CLLocationCoordinate2D)coord {
	CGPoint center = [self pointForMapPoint:MKMapPointForCoordinate( trackObject.coordinate )];
	_transform = CGAffineTransformMakeTranslation( center.x, center.y );
	[self setNeedsDisplay];
}


@end
