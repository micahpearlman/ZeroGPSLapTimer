//
//  ZOTrackOverlay.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/9/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ZOTrackObject.h"
#import "ZOSession.h"


@interface ZOTrack : NSObject <ZOTrackObject>

@property (nonatomic, assign)	CLLocationCoordinate2D coordinate;
@property (nonatomic, assign)	MKMapRect boundingMapRect;
@property (nonatomic, readonly)	NSArray* trackObjects;
@property (nonatomic, retain)	NSArray* sessionInfos;		// NSDictionary of session infos
@property (nonatomic, assign)	BOOL isSelected;
@property (nonatomic, assign)	id<ZOTrackObjectDelegate> delegate;
@property (nonatomic, copy)		NSString* name;
@property (nonatomic, retain)	NSDictionary* trackInfo;
@property (nonatomic, retain)	NSDictionary* currentSessionInfo;
@property (nonatomic, retain)	ZOSession* currentSession;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord boundingMapRect:(MKMapRect)boundingMapRect;

/// track objects
- (void) addTrackObject:(id<ZOTrackObject>)trackObject;
- (void) removeTrackObject:(id<ZOTrackObject>)trackObject;
- (NSArray*) trackObjectsAtCoordinate:(CLLocationCoordinate2D)coordinate;
- (id<ZOTrackObject>) addStartFinishLineAtCoordinate:(CLLocationCoordinate2D)coord;


/// sessions
- (ZOSession*) addSessionAtDate:(NSDate*)time;

/// archiving
- (void) archive;
+ (ZOTrack*) unarchiveFromTrackInfo:(NSDictionary*)trackInfo;


@end

@protocol ZOTrackProtocol <NSObject>


@end
