//
//  ZOStartFinishLineAnnotation.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ZOTrackObject.h"
#import "ZOTrackObjectDelegate.h"

@protocol ZOStartFinishLineOverlayDelegate;

@interface ZOStartFinishLine : NSObject <ZOTrackObject>

@property (nonatomic, assign)	CLLocationCoordinate2D coordinate;
@property (nonatomic, assign)	MKMapRect boundingMapRect;
@property (nonatomic, assign)	BOOL isSelected;
@property (nonatomic, readonly) CLCoordinateLineSegment line;
@property (nonatomic, assign)	double rotate;


- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end


