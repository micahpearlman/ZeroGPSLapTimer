//
//  MKMapView+ZoomLevel.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/15/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "MKMapView+ZoomLevel.h"


@implementation MKMapView (ZoomLevel)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
				  zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated {
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, zoomLevel)*self.frame.size.width/256);
    [self setRegion:MKCoordinateRegionMake(centerCoordinate, span) animated:animated];
}


@end
