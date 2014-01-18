//
//  ZOSession.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOSession.h"
#import "NSCoder+ZOTrackObject.h"
#import "ZOLocation.h"
#import "CLLocation+measuring.h"
#import "ZOTrack.h"

@interface ZOSession () {
	NSMutableArray* _locations;	// ZOLocations
	NSPointerArray* _delegates; // id<ZOTrackObjectDelegate>
	ZOSessionState	_state;
}

@end

@implementation ZOSession

@synthesize coordinate;
@synthesize boundingMapRect;
@synthesize isSelected;
@synthesize locations = _locations;
@synthesize sessionInfo;
@synthesize state = _state;
@dynamic delegate;

- (id) init {
	if ( self = [super init] ) {
		self.locations = [[NSMutableArray alloc] init];
		
	}
	return self;
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord boundingMapRect:(MKMapRect)boundingMapRect_ sessionInfo:(NSDictionary*)sessionInfo_ {
	
	if ( self = [self init] ) {
		self.coordinate = coord;
		self.boundingMapRect = boundingMapRect_;
		self.sessionInfo = sessionInfo_;
		_state = ZOSessionState_Offtrack;
	}
	
	return self;
}



- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if ( self ) {
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
		self.boundingMapRect = [aDecoder decodeMKMapRectForKey:@"boundingMapRect"];
		self.locations = [aDecoder decodeObjectForKey:@"locations"];
		_state = ZOSessionState_Offtrack;
	}
	return self;
}



- (void) encodeWithCoder:(NSCoder *)aCoder {
	
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
	[aCoder encodeMKMapRect:self.boundingMapRect forKey:@"boundingMapRect"];
	[aCoder encodeObject:self.locations forKey:@"locations"];
}

- (void) addLocation:(ZOLocation*)location {
	ZOLocation* lastLocation = [_locations lastObject];
	if ( lastLocation ) {	// check that this is not the first object being added
		CLCoordinateLineSegment line;
		line.start = lastLocation.coordinate;
		line.end = location.coordinate;
		CLLocationCoordinate2D intersection;
		id<ZOTrackObject> intersectObject = [self.track checkTrackObjectsIntersectLineSegment:line withIntersectResult:&intersection];
		if ( intersectObject ) {
			ZOSessionState newState = _state == ZOSessionState_Offtrack ? ZOSessionState_Lapping : ZOSessionState_Offtrack;
			[self.stateMonitorDelegate zoSession:self stateChangedFrom:_state to:newState atLocation:nil]; // TODO: interpolate location
			_state = newState;
		}
	}
	
	[_locations addObject:location];
	
	// BUGBUG: not reporting dirty with this method
}

- (void) addLocations:(NSArray *)locations {
	
	// add locations one by one
	for ( ZOLocation* location in locations ) {
		[self addLocation:location];
	}
	

	for ( id<ZOTrackObjectDelegate> delegate in _delegates ) {
		if ( [delegate respondsToSelector:@selector(zoTrackObject:isDirty:)] ) {
			[delegate zoTrackObject:self isDirty:YES];
		}
	}
}

+ (NSDictionary*) newSessionInfoAtDate:(NSDate*)date {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString* timeString = [dateFormatter stringFromDate:date];
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	NSString* sessionArchivePath = [documentDirectoryPath stringByAppendingPathComponent:[timeString stringByAppendingString:@".session"]];
	
	NSDictionary* newSession = @{ @"type" : @"session",
								  @"name" : timeString,
								  @"archive-path" : sessionArchivePath };
	return newSession;

}

#pragma mark Archiving

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

#pragma mark Property implementation

- (void) setDelegate:(id<ZOTrackObjectDelegate>)delegate {
	if ( _delegates == nil ) {
		_delegates = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
	}
	[_delegates addPointer:(__bridge void *)(delegate)];
}



@end
