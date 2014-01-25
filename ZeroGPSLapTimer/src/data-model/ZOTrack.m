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
}

@end

@implementation ZOTrack

@synthesize coordinate = _coordinate;
@synthesize boundingMapRect;
@synthesize trackObjects = _trackObjects;
@synthesize isSelected;
@synthesize delegate;
@synthesize name;
@synthesize trackInfo;
@synthesize sessionInfos = _sessionInfos;
@dynamic currentSession;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord boundingMapRect:(MKMapRect)mapRect {
	self = [super init];
	if ( self ) {
		_trackObjects = [[NSMutableArray alloc] init];
		_sessionInfos = [[NSMutableArray alloc] init];
		self.coordinate = coord;
		self.boundingMapRect = mapRect;
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if ( self ) {
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
		self.boundingMapRect = [aDecoder decodeMKMapRectForKey:@"boundingMapRect"];
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
/*
- (ZOSession*) createSessionAtDate:(NSDate*)time {

	NSDictionary* newSessionInfo = [ZOSession newSessionInfoAtDate:time track:self];
	[_sessionInfos addObject:newSessionInfo];
	
	ZOSession* newSession = [[ZOSession alloc] initWithCoordinate:self.coordinate
												  boundingMapRect:self.boundingMapRect
													  sessionInfo:newSessionInfo];
	
	newSession.delegate = self;
	newSession.track = self;

	// save to disk even though there is no real data
	[newSession archive];
	
	// save track
	[self archive];
	
	return newSession;
}
 */

- (void) removeSessionInfo:(NSDictionary *)sessionInfo {
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:[sessionInfo objectForKey:@"archive-path"] error:&error];
	[_sessionInfos removeObject:sessionInfo];
	if ( self.currentSessionInfo == sessionInfo ) {
		self.currentSessionInfo = nil;
		self.currentSession = nil;
	}
	
	[self archive];
}


- (ZOSession*) currentSession {
	if ( self.currentSessionInfo && _currentSession == nil ) {
		_currentSession = [ZOSession unarchiveFromSessionInfo:self.currentSessionInfo];
		_currentSession.track = self;
	}
	return _currentSession;
}

- (void) setCurrentSession:(ZOSession *)currentSession {
	_currentSession = currentSession;
}

#pragma mark Archiving

- (void) archive {
	[NSKeyedArchiver archiveRootObject:self toFile:[self.trackInfo objectForKey:@"archive-path"]];
}

+ (ZOTrack*) unarchiveFromTrackInfo:(NSDictionary*)trackInfo {
	ZOTrack* track = (ZOTrack*)[NSKeyedUnarchiver unarchiveObjectWithFile:[trackInfo objectForKey:@"archive-path"]];
	track.trackInfo = trackInfo;
	return track;

}

- (void) deleteFromDisk {
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:[self.trackInfo objectForKey:@"archive-path"] error:&error];
	// TODO: check for error
}

#pragma mark ZOTrackObjectDelegate

//- (void) zoTrackObject:(id<ZOTrackObject>)trackObject isDirty:(BOOL)isDirty {
//	ZOSession* session = (ZOSession*)trackObject;
//	
//	// check if we have crossed any track barriers
//	for (id<ZOTrackObject> trackObject in _trackObjects ) {
//		// TODO:
//	}
//}




@end
