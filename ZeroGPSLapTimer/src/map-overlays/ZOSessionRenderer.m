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
	
	
	
//	ZOTrack* track = (ZOTrack*)self.overlay;
//	
//	UIGraphicsPushContext( context ); {
//		
//		
//		CGContextSetFillColorWithColor( context, [UIColor grayColor].CGColor );
//		CGContextSetAlpha( context, 0.1 );
//		CGContextFillRect( context, [self rectForMapRect:track.boundingMapRect] );
//		
//		CGContextSetLineWidth( context, 12 );
//		CGContextSetAlpha( context, 0.5 );
//		CGContextSetStrokeColorWithColor( context, [UIColor redColor].CGColor );
//		CGContextStrokeRect( context, [self rectForMapRect:track.boundingMapRect] );
//		
//	} UIGraphicsPopContext();
	
	
	
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
