//
//  ZOLocation.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOWaypoint.h"
#import "NSCoder+MapKit.h"
#import "ZOTrackObjectDelegate.h"

static const float kWayPointDiameter = 5.5f;

@interface ZOWaypoint () <NSCopying> {
	CLLocation*				_location;
	NSPointerArray*			_delegates; // id<ZOTrackObjectDelegate>
	BOOL					_isSelected;
	CLLocationCoordinate2D	_coordinate;
}



@end

@implementation ZOWaypoint

@synthesize location = _location;
@dynamic	coordinate;
@synthesize boundingMapRect;
@dynamic delegate;
@dynamic isSelected;
@dynamic timestamp;
@dynamic altitude;
@dynamic radius;
@dynamic speed;

- (id) initWithCLLocation:(CLLocation*)location {
	
	if ( self = [super init]  ) {
		_location = location;
		self.coordinate = location.coordinate;
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	if ( self = [super init] ) {
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
		_location = [aDecoder decodeObjectForKey:@"location"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
 	[aCoder encodeObject:self.location forKey:@"location"];
}

- (id) copyWithZone:(NSZone *)zone {
	id copy = [[[self class] alloc] initWithCLLocation:[_location copy]];
	return copy;
}

+ (NSArray*) ZOLocationArrayFromCLLocationArray:(NSArray*)locations {
	NSMutableArray* zolocations = [[NSMutableArray alloc] init];
	for ( CLLocation* location in locations ) {
		ZOWaypoint* zolocation = [[ZOWaypoint alloc] initWithCLLocation:location];
		[zolocations addObject:zolocation];
	}
	return zolocations;
}

#pragma Interpolation

- (ZOWaypoint*) timeInterpolateToWayPoint:(ZOWaypoint*)waypoint factor:(double)factor {
	CLLocation* interpolatedLocation = [self.location interpolateToLocation:waypoint.location factor:factor];
	ZOWaypoint* interpolatedWaypoint = [[ZOWaypoint alloc] initWithCLLocation:interpolatedLocation];
	return interpolatedWaypoint;
}

#pragma mark Property implementation

- (void) setDelegate:(id<ZOTrackObjectDelegate>)delegate {
	if ( _delegates == nil ) {
		_delegates = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
	}
	[_delegates addPointer:(__bridge void *)(delegate)];
}

- (BOOL) isSelected {
	return _isSelected;
}

- (void) setIsSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	// inform any delegates
	for ( id<ZOTrackObjectDelegate> delegate in _delegates ) {
		if ( [delegate respondsToSelector:@selector(zoTrackObject:isSelected:)]) {
			[delegate zoTrackObject:self isSelected:isSelected];
		}
	}
}

- (NSDate*) timestamp {
	return self.location.timestamp;
}

- (CLLocationDistance) altitude {
	return self.location.altitude;
}

- (CLLocationCoordinate2D) coordinate {
	return _coordinate;
}

- (CLLocationDistance) radius {
	return kWayPointDiameter;
}

- (CLLocationSpeed) speed {
	return self.location.speed;
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate {
	_coordinate = coordinate;

	// create a new location for the new coordinate
	_location = [[CLLocation alloc] initWithCoordinate:coordinate
											  altitude:_location.altitude
									horizontalAccuracy:_location.horizontalAccuracy
									  verticalAccuracy:_location.verticalAccuracy
												course:_location.course
												 speed:_location.speed
											 timestamp:_location.timestamp];
	
	// inform any delegates
	for ( id<ZOTrackObjectDelegate> delegate in _delegates ) {
		if ( [delegate respondsToSelector:@selector(zoTrackObject:movedCoordinate:)]) {
			[delegate zoTrackObject:self movedCoordinate:self.coordinate];
		}
	}
}


@end
