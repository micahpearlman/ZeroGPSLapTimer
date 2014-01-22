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

- (void) createPath {
	ZOWaypoint* waypoint = (ZOWaypoint*)self.overlay;
	
	// generate bounding map
	MKMapPoint mapPointCenter = MKMapPointForCoordinate(waypoint.coordinate);
	double mapPointRadius = (waypoint.radius/2.0f) * waypoint.radius;
	MKMapPoint upperLeftMapPoint = MKMapPointMake(mapPointCenter.x - mapPointRadius, mapPointCenter.y - mapPointRadius );
	MKMapRect boundingMapRect = MKMapRectMake( upperLeftMapPoint.x, upperLeftMapPoint.y, mapPointRadius * 2, mapPointRadius * 2);

	// create circle
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect rect = [self rectForMapRect:boundingMapRect];
	CGPathAddEllipseInRect( path, NULL, rect );
	
	self.path = path;
}

#pragma mark ZOTrackObjectDelegate

- (void) zoTrackObject:(id<ZOTrackObject>)trackObject isSelected:(BOOL)isSelected {
	
}

- (void) zoTrackObject:(id<ZOTrackObject>)trackObject movedCoordinate:(CLLocationCoordinate2D)coord {
	[self invalidatePath];
}

- (void) zoTrackObject:(id<ZOTrackObject>)trackObject isDirty:(BOOL)isDirty {
	[self invalidatePath];
}

@end
