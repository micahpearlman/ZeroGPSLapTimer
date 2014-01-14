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
	NSMutableArray*				_sessions;
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
@synthesize sessions = _sessions;
@dynamic currentSession;

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
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
		self.boundingMapRect = [aDecoder decodeMKMapRectForKey:@"boundingMapRect"];
		_trackObjects = [aDecoder decodeObjectForKey:@"trackObjects"];
		_sessions = [aDecoder decodeObjectForKey:@"sessions"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
	[aCoder encodeMKMapRect:self.boundingMapRect forKey:@"boundingMapRect"];
	[aCoder encodeObject:_trackObjects forKey:@"trackObjects"];
	[aCoder encodeObject:_sessions forKey:@"sessions"];
	
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

#pragma mark Sessions

- (NSDictionary*) addSessionAtDate:(NSDate*)time {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	NSString* timeString = [dateFormatter stringFromDate:time];
	
	NSDictionary* newSession = @{ @"type" : @"session",
								  @"name" : timeString,
								  @"archive-path" : [timeString stringByAppendingPathComponent:@".session"]};
	
	[_sessions addObject:newSession];
	
	return newSession;
}

- (void) archiveSession:(ZOSession*)session {
	[NSKeyedArchiver archiveRootObject:session toFile:[session.sessionInfo objectForKey:@"archive-path"]];
}

- (ZOSession*) unarchiveSessionFromSessionInfo:(NSDictionary*)sessionInfo {
	ZOSession* session = [(ZOSession*)[NSKeyedUnarchiver unarchiveObjectWithFile:[sessionInfo objectForKey:@"archive-path"]] mutableCopy];
	session.sessionInfo = sessionInfo;
	return session;
}

- (ZOSession*) currentSession {
	if ( self.currentSessionInfo && _currentSession == nil ) {
		_currentSession = [self unarchiveSessionFromSessionInfo:self.currentSessionInfo];
	}
	return _currentSession;
}

@end
