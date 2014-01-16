//
//  MKMapView+ZoomLevel.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/15/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <MapKit/MapKit.h>

// see: http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/
@interface MKMapView (ZoomLevel)


- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
				  zoomLevel:(NSUInteger)zoomLevel
				   animated:(BOOL)animated;


@end
