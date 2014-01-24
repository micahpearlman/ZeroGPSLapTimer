//
//  ZOLap.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/18/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOLap.h"
#import "NSCoder+MapKit.h"
#import "ZOTrackObjectDelegate.h"

@interface ZOLap () {
	NSPointerArray* _delegates; // id<ZOTrackObjectDelegate>
	BOOL			_isSelected;
	NSMutableArray*	_waypoints;	// ZOWayPoint

}

@end

@implementation ZOLap

@synthesize waypoints = _waypoints;
@synthesize coordinate;
@synthesize boundingMapRect;
@dynamic delegate;
@dynamic isSelected;
@dynamic time;
@dynamic timeString;

- (id) initWithWaypoints:(NSArray*)waypoints coordinate:(CLLocationCoordinate2D)coordinate_ boundingMapRect:(MKMapRect)boundingMapRect_
 {
	if ( self = [super init] ) {
		self.coordinate = coordinate_;
		self.boundingMapRect = boundingMapRect_;
		_waypoints = [[NSMutableArray alloc] initWithArray:waypoints];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	if ( self = [super init] ) {
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
		self.boundingMapRect = [aDecoder decodeMKMapRectForKey:@"boundingMapRect"];
		_waypoints = [aDecoder decodeObjectForKey:@"waypoints"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
	[aCoder encodeMKMapRect:self.boundingMapRect forKey:@"boundingMapRect"];
	[aCoder encodeObject:_waypoints forKey:@"waypoints"];
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
	for ( id<ZOTrackObjectDelegate> delegate in _delegates ) {
		if ( [delegate respondsToSelector:@selector(zoTrackObject:isSelected:)]) {
			[delegate zoTrackObject:self isSelected:isSelected];
		}
	}
}

- (NSTimeInterval) time {
	ZOWaypoint* firstWaypoint = [_waypoints firstObject];
	ZOWaypoint* lastWaypoint = [_waypoints lastObject];
	return [lastWaypoint.timestamp timeIntervalSinceDate:firstWaypoint.timestamp];
}

- (NSString*) timeString {
	NSTimeInterval lapTime = self.time;
	NSTimeInterval minutes = lapTime / 60.0;
	NSTimeInterval seconds = fmod( lapTime, 60.0);
	return [NSString stringWithFormat:@"%d:%4.2f", (int)minutes, seconds];

}

@end
