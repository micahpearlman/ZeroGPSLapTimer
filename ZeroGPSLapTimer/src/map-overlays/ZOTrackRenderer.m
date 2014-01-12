//
//  ZOTrackRenderer.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/9/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOTrackRenderer.h"
#import "ZOTrack.h"
#import "ZOTrackObjectDelegate.h"
#import "ZOStartFinishLine.h"
#import "ZOStartFinishLineRenderer.h"

@interface ZOTrackRenderer () <ZOTrackObjectDelegate> {
}

@end

@implementation ZOTrackRenderer

- (id)initWithOverlay:(id<MKOverlay>)overlay {
	self = [super initWithOverlay:overlay];
	if ( self ) {
		ZOTrack* track = (ZOTrack*)overlay;
		track.delegate = self;
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
	
	
	
	ZOTrack* track = (ZOTrack*)self.overlay;
	
	UIGraphicsPushContext( context ); {
				
		
		CGContextSetFillColorWithColor( context, [UIColor grayColor].CGColor );
		CGContextSetAlpha( context, 0.1 );
		CGContextFillRect( context, [self rectForMapRect:track.boundingMapRect] );
		
		CGContextSetLineWidth( context, 12 );
		CGContextSetAlpha( context, 0.5 );
		CGContextSetStrokeColorWithColor( context, [UIColor redColor].CGColor );
		CGContextStrokeRect( context, [self rectForMapRect:track.boundingMapRect] );
		
	} UIGraphicsPopContext();
	

	
}

#pragma mark ZOTrackObjectDelegate

- (void) zoTrackObject:(id<ZOTrackObject>)trackObject isSelected:(BOOL)isSelected {
	
}

- (void) zoTrackObject:(id<ZOTrackObject>)trackObject movedCoordinate:(CLLocationCoordinate2D)coord {
	[self setNeedsDisplay];
}


@end
