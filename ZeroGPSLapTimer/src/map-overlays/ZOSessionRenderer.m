//
//  ZOSessionRenderer.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOSessionRenderer.h"
#import "ZOSession.h"
#import "ZOTrackObjectDelegate.h"
#import "ZOWaypoint.h"

@interface ZOSessionRenderer () <ZOTrackObjectDelegate>

@end

@implementation ZOSessionRenderer

- (id)initWithOverlay:(id<MKOverlay>)overlay {
	self = [super initWithOverlay:overlay];
	if ( self ) {
		ZOSession* session = (ZOSession*)overlay;
		session.delegate = self;
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
	
	ZOSession* session = (ZOSession*)self.overlay;
	if ( [session.waypoints count] > 1 ) {
		UIGraphicsPushContext( context ); {
			CGContextBeginPath( context );
			CGContextSetLineWidth( context, 4 );
			CGContextSetStrokeColorWithColor( context, [UIColor blueColor].CGColor );
			CGPoint point;
			for ( ZOWaypoint* waypoint in session.waypoints ) {
				point = [self pointForMapPoint:MKMapPointForCoordinate( waypoint.coordinate) ];

				if ( waypoint != [session.waypoints firstObject] ) {
					CGContextAddLineToPoint( context, point.x, point.y );
				} else {	// first point
					CGContextMoveToPoint( context, point.x, point.y );
				}
			}
			
			
			CGContextStrokePath( context );
		} UIGraphicsPopContext();
		
	}
	
	
}

#pragma mark ZOTrackObjectDelegate

- (void) zoTrackObject:(id<ZOTrackObject>)trackObject isSelected:(BOOL)isSelected {
	
}

- (void) zoTrackObject:(id<ZOTrackObject>)trackObject movedCoordinate:(CLLocationCoordinate2D)coord {
	[self setNeedsDisplay];
}

- (void) zoTrackObject:(id<ZOTrackObject>)trackObject isDirty:(BOOL)isDirty {
	[self setNeedsDisplay];
}

@end
