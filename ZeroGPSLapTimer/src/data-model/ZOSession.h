//
//  ZOSession.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZOTrackObject.h"
#import "ZOTrackObjectDelegate.h"
#import "ZOWaypoint.h"

@class ZOTrack;
@class ZOLap;

typedef enum {
	ZOSessionState_Undefined,
	ZOSessionState_Offtrack,	// off the track bounding area
	ZOSessionState_Pits,
	ZOSessionState_StartLap,
	ZOSessionState_EndLap,
	ZOSessionState_EndSession
} ZOSessionState;

@protocol ZOSessionStateDelegate;

@interface ZOSession : NSObject <ZOTrackObject>

@property (nonatomic, assign)	CLLocationCoordinate2D coordinate;
@property (nonatomic, assign)	MKMapRect boundingMapRect;
@property (nonatomic, assign)	BOOL isSelected;
@property (atomic, readonly)	NSArray* waypoints;
@property (nonatomic, retain)	NSDictionary* sessionInfo;
@property (nonatomic, weak)		ZOTrack* track;
@property (nonatomic, assign)	id<ZOTrackObjectDelegate> delegate;
@property (nonatomic, readonly)	ZOSessionState state;
@property (nonatomic, assign)	id<ZOSessionStateDelegate> stateMonitorDelegate;
@property (nonatomic, readonly) NSTimeInterval totalTime;
@property (nonatomic, assign)	double playbackScale;
@property (nonatomic, assign)	NSTimeInterval playbackTime;
@property (nonatomic, assign)	NSTimeInterval playbackTimeInterval;	// NOTE: need to pause and unpause for this property to take effect
@property (nonatomic, assign)	BOOL isPlaybackPaused;
@property (nonatomic, readonly)	NSArray* laps;	// ZOLaps

// make delegate writeonly: http://stackoverflow.com/questions/4266197/write-only-property-in-objective-c
- (id<ZOTrackObjectDelegate>) delegate UNAVAILABLE_ATTRIBUTE;

//- (id) initWithCoordinate:(CLLocationCoordinate2D)coord boundingMapRect:(MKMapRect)boundingMapRect sessionInfo:(NSDictionary*)sessionInfo;
- (id) initWithTrack:(ZOTrack*)track;

/// Waypoint
- (void) addWaypoints:(NSArray*)waypoints;	// ZOWaypoint
- (void) addWaypoint:(ZOWaypoint*)waypoint;
- (ZOWaypoint*) waypointAtTimeInterval:(NSTimeInterval)timeInterval;
- (void) endSession;

/// Lap
- (void) startLapAtWaypoint:(ZOWaypoint*)waypoint;


/// archiving
- (void) archive;
+ (ZOSession*) sessionFromSessionInfo:(NSDictionary*)sessionInfo;
- (void) deleteFromDisk;
+ (NSDictionary*) newSessionInfoAtDate:(NSDate*)date track:(ZOTrack*)track;

/// playback
- (void) startPlaybackAtStartTime:(NSTimeInterval)startTime withTimeInterval:(NSTimeInterval)timeInterval andScale:(double)scale;



@end

@protocol ZOSessionStateDelegate <NSObject>
@required
- (void) zoSession:(ZOSession*)session stateChangedFrom:(ZOSessionState)from to:(ZOSessionState)to atWaypoint:(ZOWaypoint*)location;
@optional
- (void) zoSession:(ZOSession*)session playbackCursorAtWaypoint:(ZOWaypoint*)waypoint;
@end
