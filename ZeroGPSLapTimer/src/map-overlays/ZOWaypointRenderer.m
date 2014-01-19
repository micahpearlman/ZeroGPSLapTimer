//
//  ZOWaypointRenderer.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/18/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOWaypointRenderer.h"
#import "ZOWaypoint.h"
#import "ZOTrackObjectDelegate.h"

@interface ZOWaypointRenderer () <ZOTrackObjectDelegate>

@end

@implementation ZOWaypointRenderer

- (id)initWithOverlay:(id<MKOverlay>)overlay {
	self = [super initWithOverlay:overlay];
	if ( self ) {
		ZOWaypoint* session = (ZOWaypoint*)overlay;
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
	
	ZOWaypoint* waypoint = (ZOWaypoint*)self.overlay;
	
	CGRect rect = [self rectForMapRect:waypoint.boundingMapRect];
	
	UIGraphicsPushContext( context ); {
		CGContextSetLineWidth( context, 12 );
		CGContextSetFillColorWithColor( context, [UIColor redColor].CGColor );
		CGContextSetStrokeColorWithColor( context, [UIColor blueColor].CGColor );
		CGContextSetAlpha( context, 0.3 );
		CGContextFillEllipseInRect( context, rect );
		CGContextSetAlpha( context, 0.8 );
		CGContextStrokeEllipseInRect( context, rect );

	} UIGraphicsPopContext();

	
//	if ( [session.waypoints count] > 1 ) {
//		UIGraphicsPushContext( context ); {
//			CGContextBeginPath( context );
//			CGContextSetLineWidth( context, 4 );
//			CGContextSetStrokeColorWithColor( context, [UIColor blueColor].CGColor );
//			CGPoint point;
//			for ( ZOWaypoint* waypoint in session.waypoints ) {
//				point = [self pointForMapPoint:MKMapPointForCoordinate( waypoint.coordinate) ];
//				
//				if ( waypoint != [session.waypoints firstObject] ) {
//					CGContextAddLineToPoint( context, point.x, point.y );
//				} else {	// first point
//					CGContextMoveToPoint( context, point.x, point.y );
//				}
//			}
//			
//			
//			CGContextStrokePath( context );
//		} UIGraphicsPopContext();
//		
//	}
	
	
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
