//
//  ZOTrackObjectProtocol.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/9/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CLLocation+measuring.h"

@protocol ZOTrackObjectDelegate;
@protocol ZOTrackObject <MKOverlay, NSCoding, NSObject>

@required
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) id<ZOTrackObjectDelegate> delegate;

@optional
@property (nonatomic, assign) double rotate;	// radians
- (BOOL) checkLineSegmentIntersects:(CLCoordinateLineSegment)line withResult:(CLLocationCoordinate2D*)intersection;


@end
