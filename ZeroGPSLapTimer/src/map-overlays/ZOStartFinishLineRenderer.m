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

@interface ZOStartFinishLineRenderer () <ZOTrackObjectDelegate>

@end

@implementation ZOStartFinishLineRenderer


- (id)initWithOverlay:(id<MKOverlay>)overlay {
	self = [super initWithOverlay:overlay];
	if ( self ) {
		ZOStartFinishLine* startFinishLineOverlay = (ZOStartFinishLine*)overlay;

		startFinishLineOverlay.delegate = self;

		
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
	ends[0] = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.line.start )];
	ends[1] = [self pointForMapPoint:MKMapPointForCoordinate( startFinishLineOverlay.line.end )];
	CGRect rect = [self rectForMapRect:startFinishLineOverlay.boundingMapRect];

	
	UIGraphicsPushContext( context ); {
		if ( startFinishLineOverlay.isSelected ) {
			CGContextSetLineWidth( context, 12 );
			CGContextSetFillColorWithColor( context, [UIColor blueColor].CGColor );
			CGContextSetStrokeColorWithColor( context, [UIColor blackColor].CGColor );
			CGContextSetAlpha( context, 0.3 );
			CGContextFillEllipseInRect( context, rect );
			CGContextSetAlpha( context, 0.8 );
			CGContextStrokeEllipseInRect( context, rect );
		}

		CGContextBeginPath( context );
		CGContextSetLineWidth( context, 12 );
		CGContextSetStrokeColorWithColor( context, [UIColor greenColor].CGColor );
		CGContextMoveToPoint( context, ends[0].x, ends[0].y );
		CGContextAddLineToPoint( context, ends[1].x, ends[1].y );
		CGContextStrokePath( context );
		
	} UIGraphicsPopContext();
	
}



#pragma mark ZOTrackObjectDelegate


- (void) zoTrackObject:(id<ZOTrackObject>) trackObject isSelected:(BOOL)isSelected {
	[self setNeedsDisplay];
}
- (void) zoTrackObject:(id<ZOTrackObject>) trackObject movedCoordinate:(CLLocationCoordinate2D)coord {
	[self setNeedsDisplay];
}


@end
