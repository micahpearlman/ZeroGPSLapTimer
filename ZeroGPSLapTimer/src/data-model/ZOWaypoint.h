//
//  ZOWayPoint.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ZOTrackObject.h"

@interface ZOWaypoint : NSObject <ZOTrackObject>

@property (nonatomic, assign)	CLLocationCoordinate2D coordinate;
@property (nonatomic, assign)	MKMapRect boundingMapRect;
@property (nonatomic, readonly) CLLocationDistance radius;
@property (nonatomic, readonly)	CLLocation* location;
@property (nonatomic, assign)	BOOL isSelected;
@property (nonatomic, assign)	id<ZOTrackObjectDelegate> delegate;
@property (nonatomic, readonly)	NSDate* timestamp;
@property (nonatomic, readonly) CLLocationDistance altitude;
@property (nonatomic, readonly)	CLLocationSpeed speed;


// make delegate writeonly: http://stackoverflow.com/questions/4266197/write-only-property-in-objective-c
- (id<ZOTrackObjectDelegate>) delegate UNAVAILABLE_ATTRIBUTE;

- (id) initWithCLLocation:(CLLocation*)location;

+ (NSArray*) ZOLocationArrayFromCLLocationArray:(NSArray*)locations;

- (ZOWaypoint*) timeInterpolateToWayPoint:(ZOWaypoint*)waypoint factor:(double)factor;

@end
