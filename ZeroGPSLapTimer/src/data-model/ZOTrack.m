//
//  ZOTrackOverlay.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/9/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOTrack.h"
#import "ZOStartFinishLine.h"
#import "NSCoder+MapKit.h"

@interface ZOTrack () <ZOTrackObjectDelegate> {
	NSMutableArray*				_trackObjects;	// id<ZOTrackObjectProtocol>
	CLLocationCoordinate2D		_coordinate;
	NSMutableArray*				_sessionInfos;
	ZOSession*					_currentSession;
	MKMapRect					_boundingMapRect;
}

@end

@implementation ZOTrack

@synthesize coordinate = _coordinate;
@dynamic boundingMapRect;
@synthesize trackObjects = _trackObjects;
@synthesize isSelected;
@synthesize delegate;
@synthesize name;
@synthesize trackInfo;
@synthesize sessionInfos = _sessionInfos;
//@dynamic currentSession;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord boundingMapRect:(MKMapRect)mapRect {
	self = [super init];
	if ( self ) {
		_trackObjects = [[NSMutableArray alloc] init];
		_sessionInfos = [[NSMutableArray alloc] init];
		self.coordinate = coord;
		_boundingMapRect = mapRect;
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if ( self ) {
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
		_boundingMapRect = [aDecoder decodeMKMapRectForKey:@"boundingMapRect"];
		_trackObjects = [aDecoder decodeObjectForKey:@"trackObjects"];
		_sessionInfos = [aDecoder decodeObjectForKey:@"sessions"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
	[aCoder encodeMKMapRect:self.boundingMapRect forKey:@"boundingMapRect"];
	[aCoder encodeObject:_trackObjects forKey:@"trackObjects"];
	[aCoder encodeObject:_sessionInfos forKey:@"sessions"];
	
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
//	if ( MKMapRectContainsPoint( self.boundingMapRect, mapPoint ) ) {
//		[trackObjectsAtCoordinate addObject:self];
		
		for ( id<ZOTrackObject> trackObject in _trackObjects ) {
			
			if ( MKMapRectContainsPoint( trackObject.boundingMapRect, mapPoint ) ) {
				[trackObjectsAtCoordinate addObject:trackObject];
			}
		}

//	}
	
	return trackObjectsAtCoordinate;
	
}

- (id<ZOTrackObject>) addStartFinishLineAtCoordinate:(CLLocationCoordinate2D)coord {
	ZOStartFinishLine* startFinishLine = [[ZOStartFinishLine alloc] initWithCoordinate:coord];
	[self addTrackObject:startFinishLine];
	return startFinishLine;
}



- (id<ZOTrackObject>) checkTrackObjectsIntersectLineSegment:(CLCoordinateLineSegment)line withIntersectResult:(CLLocationCoordinate2D*)result {
	for ( id<ZOTrackObject> trackObject in _trackObjects ) {
		if ( [trackObject respondsToSelector:@selector(checkLineSegmentIntersects:withResult:)]) {
			if ( [trackObject checkLineSegmentIntersects:line withResult:result] ) {
				return trackObject;	// intersects.  BUGBUG: could intersect multiple track objects!
			}
		}
	}
	
	return nil;
}

#pragma mark Sessions

- (void) addSessionInfo:(NSDictionary*)sessionInfo {
	[_sessionInfos addObject:sessionInfo];
	[self archive];
}

- (void) removeSessionInfo:(NSDictionary *)sessionInfo {
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:[sessionInfo objectForKey:@"archive-path"] error:&error];
	[_sessionInfos removeObject:sessionInfo];
	
	[self archive];
}


#pragma mark Archiving

- (void) archive {
	[NSKeyedArchiver archiveRootObject:self toFile:[self.trackInfo objectForKey:@"archive-path"]];
}

+ (ZOTrack*) trackFromTrackInfo:(NSDictionary*)trackInfo {
	ZOTrack* track = (ZOTrack*)[NSKeyedUnarchiver unarchiveObjectWithFile:[trackInfo objectForKey:@"archive-path"]];
	track.trackInfo = trackInfo;
	return track;

}

- (void) deleteFromDisk {
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:[self.trackInfo objectForKey:@"archive-path"] error:&error];
	// TODO: check for error
}

#pragma mark boundingMapRect

- (void) setBoundingMapRect:(MKMapRect)boundingMapRect {
	_boundingMapRect = boundingMapRect;
	if ( [self.delegate respondsToSelector:@selector(zoTrackObject:isDirty:)]) {
		[self.delegate zoTrackObject:self isDirty:YES];
	}
}

- (MKMapRect) boundingMapRect {
	return _boundingMapRect;
}





@end
