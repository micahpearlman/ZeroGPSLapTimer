//
//  ZOSession.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOSession.h"
#import "NSCoder+ZOTrackObject.h"
#import "ZOWaypoint.h"
#import "CLLocation+measuring.h"
#import "ZOTrack.h"
#import "ZOLap.h"

@interface ZOSession () {
	NSMutableArray* _waypoints;	// ZOLocations
	NSPointerArray* _delegates; // id<ZOTrackObjectDelegate>
	NSTimer*		_playbackTimer;
	ZOSessionState	_state;
	ZOWaypoint*		_waypointCursor;
	NSMutableArray*	_laps;
}

@end

@implementation ZOSession

@synthesize coordinate;
@synthesize boundingMapRect;
@synthesize isSelected;
@synthesize waypoints = _waypoints;
@synthesize sessionInfo;
@synthesize state = _state;
@dynamic totalTime;
@dynamic delegate;
@dynamic isPlaybackPaused;
@dynamic laps;

- (id) init {
	if ( self = [super init] ) {
		self.waypoints = [[NSMutableArray alloc] init];
		
	}
	return self;
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord boundingMapRect:(MKMapRect)boundingMapRect_ sessionInfo:(NSDictionary*)sessionInfo_ {
	
	if ( self = [self init] ) {
		self.coordinate = coord;
		self.boundingMapRect = boundingMapRect_;
		self.sessionInfo = sessionInfo_;
		_state = ZOSessionState_Undefined;
		
		// TODO: set track from track name
	}
	
	return self;
}



- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if ( self ) {
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
		self.boundingMapRect = [aDecoder decodeMKMapRectForKey:@"boundingMapRect"];
		self.waypoints = [aDecoder decodeObjectForKey:@"locations"];
		_state = ZOSessionState_Undefined;
		
		// TODO: set track from track name
	}
	return self;
}



- (void) encodeWithCoder:(NSCoder *)aCoder {
	
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
	[aCoder encodeMKMapRect:self.boundingMapRect forKey:@"boundingMapRect"];
	[aCoder encodeObject:self.waypoints forKey:@"locations"];
}


- (void) addWaypoint:(ZOWaypoint*)location {
	
	ZOSessionState newState = ZOSessionState_Offtrack;
	ZOWaypoint* stateChangeWaypoint = location;
	
	// check if location is off track
	if ( MKMapRectContainsPoint( self.track.boundingMapRect, MKMapPointForCoordinate(location.coordinate))) {
		ZOWaypoint* lastLocation = [_waypoints lastObject];
		if ( lastLocation ) {	// check that this is not the first object being added
			
			stateChangeWaypoint = [self checkWaypointsIntersectTrackObjects:lastLocation end:location];
			
			if ( stateChangeWaypoint ) {
				newState = ZOSessionState_StartLap;
			}
		}
		
		[_waypoints addObject:location];

		
	} else {	// off track
		newState = ZOSessionState_Offtrack;
	}
	
	// notify state monitor delegate if state change
	if ( newState != _state ) {
		[self.stateMonitorDelegate zoSession:self
							stateChangedFrom:_state
										  to:newState
								  atWaypoint:stateChangeWaypoint];
	}
	
	_state = newState;

	// BUGBUG: not reporting dirty with this method
}

- (void) addWaypoints:(NSArray *)locations {
	
	// add locations one by one
	for ( ZOWaypoint* location in locations ) {
		[self addWaypoint:location];
	}
	

	for ( id<ZOTrackObjectDelegate> delegate in _delegates ) {
		if ( [delegate respondsToSelector:@selector(zoTrackObject:isDirty:)] ) {
			[delegate zoTrackObject:self isDirty:YES];
		}
	}
}

- (ZOWaypoint*) checkWaypointsIntersectTrackObjects:(ZOWaypoint*)start end:(ZOWaypoint*)end {
	ZOWaypoint* intersectWaypoint = nil;
	
	CLCoordinateLineSegment line;
	line.start = start.coordinate;
	line.end = end.coordinate;
	CLLocationCoordinate2D intersection;
	id<ZOTrackObject> intersectObject = [self.track checkTrackObjectsIntersectLineSegment:line withIntersectResult:&intersection];
	if ( intersectObject ) {
		
		// create a new waypoint interpolated to the intersection
		CLLocationDistance lineLength = CLCoordinateLineSegmentDistance( line );
		CLLocationDistance distanceToIntersection = [start.location distanceFromCoordinate:intersection];
		CLLocationDistance distanceRatio = distanceToIntersection / lineLength;
		CLLocation* interpolatedLocation = [start.location interpolateToLocation:end.location factor:distanceRatio];
		intersectWaypoint = [[ZOWaypoint alloc] initWithCLLocation:interpolatedLocation];
	}
	
	return intersectWaypoint;
	
}

- (ZOWaypoint*) waypointAtTimeInterval:(NSTimeInterval)timeInterval {
	if ( timeInterval > self.totalTime ) {
		return nil;
	}
	
	if ( !([_waypoints count] > 1) ) {
		return nil;
	}
	
	ZOWaypoint* start = [_waypoints firstObject];
	ZOWaypoint* bracketWaypoints[2] = {nil, nil};
	NSTimeInterval bracketTimes[2];
	for ( int i = 0; i < [_waypoints count] - 1; i++ ) {
		bracketWaypoints[0] = [_waypoints objectAtIndex:i];
		bracketWaypoints[1] = [_waypoints objectAtIndex:i+1];

		bracketTimes[0] = [bracketWaypoints[0].timestamp timeIntervalSinceDate:start.timestamp];
		bracketTimes[1] = [bracketWaypoints[1].timestamp timeIntervalSinceDate:start.timestamp];
		if ( timeInterval >= bracketTimes[0] && timeInterval <= bracketTimes[1] ) {
			break;	// found it
		}
	}
	
	
	NSTimeInterval timeSinceFirstBracket = timeInterval - bracketTimes[0];
	NSTimeInterval timeBetweenBrackets = bracketTimes[1] - bracketTimes[0];
	double interpolationFactor = timeSinceFirstBracket / timeBetweenBrackets;	// normalize the time distance 0..1
	ZOWaypoint* interpolatedWayPoint = [bracketWaypoints[0] timeInterpolateToWayPoint:bracketWaypoints[1] factor:interpolationFactor];

	return interpolatedWayPoint;
}

#pragma mark Archiving

+ (NSDictionary*) newSessionInfoAtDate:(NSDate*)date track:(ZOTrack *)track {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString* timeString = [dateFormatter stringFromDate:date];
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	NSString* sessionArchivePath = [documentDirectoryPath stringByAppendingPathComponent:[timeString stringByAppendingString:@".session"]];
	
	NSDictionary* newSession = @{ @"type" : @"session",
								  @"name" : timeString,
								  @"archive-path" : sessionArchivePath,
								  @"track-name" : track.name
								  };
	return newSession;

}



- (void) archive {
	[NSKeyedArchiver archiveRootObject:self toFile:[self.sessionInfo objectForKey:@"archive-path"]];
}

+ (ZOSession*) unarchiveFromSessionInfo:(NSDictionary*)sessionInfo {
	ZOSession* session = (ZOSession*)[NSKeyedUnarchiver unarchiveObjectWithFile:[sessionInfo objectForKey:@"archive-path"]];
	session.sessionInfo = sessionInfo;
	return session;	
}

- (void) deleteFromDisk {
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:[self.sessionInfo objectForKey:@"archive-path"] error:&error];
	// TODO: check for error
}

#pragma mark Playback

- (void) startPlaybackAtStartTime:(NSTimeInterval)startTime withTimeInterval:(NSTimeInterval)timeInterval andScale:(double)scale {
	self.playbackTimeInterval = timeInterval;
	self.playbackScale = scale;
	self.playbackTime = startTime;
	[self setIsPlaybackPaused:NO];
}

- (void) playbackTimer:(NSTimer*)timer {
	
	ZOWaypoint* newWaypointCursor = [self waypointAtTimeInterval:self.playbackTime];
	[self.stateMonitorDelegate zoSession:self playbackCursorAtWaypoint:newWaypointCursor];
	
	if ( _waypointCursor == nil ) {
		_waypointCursor = newWaypointCursor;
	}
	
	// check for intersection
	ZOWaypoint* intersect = [self checkWaypointsIntersectTrackObjects:_waypointCursor end:newWaypointCursor];
	
	if ( intersect ) {
		ZOSessionState newState = ZOSessionState_StartLap;
		// notify state monitor delegate 
		[self.stateMonitorDelegate zoSession:self
							stateChangedFrom:_state
										  to:newState
								  atWaypoint:intersect];
		
		_state = newState;

	}

	_waypointCursor = newWaypointCursor;
	self.playbackTime = self.playbackTime + timer.timeInterval;
}

- (BOOL) isPlaybackPaused {
	return ![_playbackTimer isValid];
}

- (void) setIsPlaybackPaused:(BOOL)isPlaybackPaused {
	if ( isPlaybackPaused && !self.isPlaybackPaused ) {
		[_playbackTimer invalidate];	// stop timer
	} else {	// start up the timer
		_playbackTimer = [NSTimer scheduledTimerWithTimeInterval:self.playbackTimeInterval
														  target:self
														selector:@selector(playbackTimer:)
														userInfo:nil
														 repeats:YES];
		
	}
}

#pragma mark Laps
- (NSArray*) laps {
	if ( _laps == nil ) {
		_laps = [[NSMutableArray alloc] init];
		const NSTimeInterval dt = 1.0/20.0;
		const NSTimeInterval totalTime = self.totalTime;
		ZOSessionState state = ZOSessionState_Pits;
		ZOWaypoint* previousWaypoint = [self.waypoints firstObject];
		NSMutableArray* lapWayPoints = nil;
		for ( NSTimeInterval time = 0; time < totalTime; time += dt ) {
			ZOWaypoint* newWaypointCursor = [self waypointAtTimeInterval:time];
			
			if ( newWaypointCursor == nil ) {
				break;	// at the end of the lap
			}
			
			// debug killme
//			ZOWaypoint* first = [self.waypoints firstObject];
//			{
//				CLCoordinateLineSegment line;
//				
//				line.start = first.coordinate;
//				line.end = newWaypointCursor.coordinate;
//				
//				CLLocationDistance killme = CLCoordinateLineSegmentDistance( line );
//				NSLog(@"length: %f", killme);
//			}
			
			// check for intersection
			ZOWaypoint* intersect = [self checkWaypointsIntersectTrackObjects:previousWaypoint end:newWaypointCursor];
			if ( intersect ) {
				if ( state == ZOSessionState_Pits ) {	// if first laps
					state = ZOSessionState_StartLap;
					lapWayPoints = [[NSMutableArray alloc] init];
					[lapWayPoints addObject:intersect];
				} else if ( state == ZOSessionState_StartLap ) {	// finished lap
					[lapWayPoints addObject:intersect];
					ZOLap* lap = [[ZOLap alloc] initWithWaypoints:lapWayPoints coordinate:self.coordinate boundingMapRect:self.boundingMapRect];
					[_laps addObject:lap];
				}
			} else if ( state == ZOSessionState_StartLap ) {	// currently in a lap so add waypoint to lap
				[lapWayPoints addObject:newWaypointCursor];
			}

			previousWaypoint = newWaypointCursor;
		}
	}
	
	return _laps;
}


#pragma mark Property implementation

- (void) setDelegate:(id<ZOTrackObjectDelegate>)delegate {
	if ( _delegates == nil ) {
		_delegates = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
	}
	[_delegates addPointer:(__bridge void *)(delegate)];
}

- (NSTimeInterval) totalTime {
	ZOWaypoint* first = [_waypoints firstObject];
	ZOWaypoint* last = [_waypoints lastObject];
	return [last.timestamp timeIntervalSinceDate:first.timestamp];
}




@end
