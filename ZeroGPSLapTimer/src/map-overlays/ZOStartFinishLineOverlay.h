//
//  ZOStartFinishLineAnnotation.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ZOStartFinishLineOverlay : NSObject <MKOverlay>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) MKMapRect boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D* lineEnds;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord;




@end
