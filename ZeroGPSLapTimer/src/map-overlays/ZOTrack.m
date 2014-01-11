//
//  ZOTrackOverlay.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/9/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOTrack.h"
#import "ZOStartFinishLine.h"
#import "NSCoder+ZOTrackObject.h"

@interface ZOTrack () {
	NSMutableArray*				_trackObjects;	// id<ZOTrackObjectProtocol>
	CLLocationCoordinate2D		_coordinate;
}

@end

@implementation ZOTrack

@synthesize coordinate = _coordinate;
@synthesize boundingMapRect;
@synthesize trackObjects = _trackObjects;
@synthesize isSelected;
@synthesize delegate;
@synthesize name;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord boundingMapRect:(MKMapRect)mapRect {
	self = [super init];
	if ( self ) {
		_trackObjects = [[NSMutableArray alloc] init];
		self.coordinate = coord;
		self.boundingMapRect = mapRect;
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if ( self ) {
		
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
	[aCoder encodeMKMapRect:self.boundingMapRect forKey:@"boundingMapRect"];
	[aCoder encodeObject:_trackObjects forKey:@"trackObjects"];
	
}


- (void) addTrackObject:(id<ZOTrackObject>)trackObject {
	// TODO: set boundingMapRect
	[_trackObjects addObject:trackObject];
}

- (void) removeTrackObject:(id<ZOTrackObject>)trackObject {
	if ( trackObject == self ) {
		return;
	}
	// TODO: set boundingMapRect
	[_trackObjects removeObject:trackObject];
}


- (NSArray*) trackObjectsAtCoordinate:(CLLocationCoordinate2D)coord {
	NSMutableArray* trackObjectsAtCoordinate = [[NSMutableArray alloc] init];
	MKMapPoint mapPoint = MKMapPointForCoordinate( coord );
	if ( MKMapRectContainsPoint( self.boundingMapRect, mapPoint ) ) {
		[trackObjectsAtCoordinate addObject:self];
		
		for ( id<ZOTrackObject> trackObject in _trackObjects ) {
			
			if ( MKMapRectContainsPoint( trackObject.boundingMapRect, mapPoint ) ) {
				[trackObjectsAtCoordinate addObject:trackObject];
			}
		}

	}
	
	return trackObjectsAtCoordinate;
	
}

- (id<ZOTrackObject>) addStartFinishLineAtCoordinate:(CLLocationCoordinate2D)coord {
	ZOStartFinishLine* startFinishLine = [[ZOStartFinishLine alloc] initWithCoordinate:coord];
	[self addTrackObject:startFinishLine];
	return startFinishLine;
}

@end
