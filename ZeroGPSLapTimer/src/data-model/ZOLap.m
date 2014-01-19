//
//  ZOLap.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/18/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOLap.h"
#import "NSCoder+ZOTrackObject.h"
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

@end
