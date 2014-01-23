//
//  ZOLap.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/18/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZOTrackObject.h"
#import "ZOWaypoint.h"

@interface ZOLap : NSObject <ZOTrackObject>

@property (nonatomic, readonly)	NSArray* waypoints;
@property (nonatomic, assign)	CLLocationCoordinate2D coordinate;
@property (nonatomic, assign)	MKMapRect boundingMapRect;
@property (nonatomic, assign)	BOOL isSelected;
@property (nonatomic, assign)	id<ZOTrackObjectDelegate> delegate;
@property (nonatomic, readonly)	NSTimeInterval time;
@property (nonatomic, readonly) NSString* timeString;

// make delegate writeonly: http://stackoverflow.com/questions/4266197/write-only-property-in-objective-c
- (id<ZOTrackObjectDelegate>) delegate UNAVAILABLE_ATTRIBUTE;

- (id) initWithWaypoints:(NSArray*)waypoints coordinate:(CLLocationCoordinate2D)coordinate_ boundingMapRect:(MKMapRect)boundingMapRect_;
@end
