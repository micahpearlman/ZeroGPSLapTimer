//
//  ZOLocation.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOWaypoint.h"
#import "NSCoder+ZOTrackObject.h"
#import "ZOTrackObjectDelegate.h"

static const float kWayPointDiameter = 5.0f;

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

- (id) initWithCLLocation:(CLLocation*)location {
	
	if ( self = [super init]  ) {
		_location = location;
		self.coordinate = location.coordinate;
//		MKMapPoint point = MKMapPointForCoordinate( self.coordinate );
//		self.boundingMapRect = MKMapRectMake(point.x, point.y, 20.0, 20.0);
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	if ( self = [super init] ) {
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
		self.boundingMapRect = [aDecoder decodeMKMapRectForKey:@"boundingMapRect"];
		_location = [aDecoder decodeObjectForKey:@"location"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
	[aCoder encodeMKMapRect:self.boundingMapRect forKey:@"boundingMapRect"];
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
	CLLocation* interpolatedLocation = [self.location timeInterpolateToLocation:waypoint.location factor:factor];
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

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate {
	_coordinate = coordinate;
	
	// bounding map rect
	MKMapPoint mapPointCenter = MKMapPointForCoordinate(_coordinate);
	double mapPointRadius = (kWayPointDiameter/2.0f) * kWayPointDiameter;
	MKMapPoint upperLeftMapPoint = MKMapPointMake(mapPointCenter.x - mapPointRadius, mapPointCenter.y - mapPointRadius );
	self.boundingMapRect = MKMapRectMake( upperLeftMapPoint.x, upperLeftMapPoint.y, mapPointRadius * 2, mapPointRadius * 2);

	
	// create a new location for the new coordinate
	_location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:_location.altitude horizontalAccuracy:_location.horizontalAccuracy verticalAccuracy:_location.verticalAccuracy course:_location.course speed:_location.speed timestamp:_location.timestamp];
	
	// inform any delegates
	for ( id<ZOTrackObjectDelegate> delegate in _delegates ) {
		if ( [delegate respondsToSelector:@selector(zoTrackObject:movedCoordinate:)]) {
			[delegate zoTrackObject:self movedCoordinate:self.coordinate];
		}
	}
	
}

@end
