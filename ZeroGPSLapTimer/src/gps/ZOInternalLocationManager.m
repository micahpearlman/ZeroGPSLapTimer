//
//  ZOInternalLocationManager.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/26/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOInternalLocationManager.h"
#import <MapKit/MapKit.h>
@interface ZOInternalLocationManager () <CLLocationManagerDelegate> {
	CLLocationManager*	_locationManager;
}

@end

@implementation ZOInternalLocationManager

- (id) init {
	if ( self = [super init] ) {
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDelegate:self];
		[_locationManager setDistanceFilter:kCLDistanceFilterNone];
		[_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
		
	}
	return self;
}

- (void) startUpdatingLocation {
	[_locationManager startUpdatingLocation];
}
- (void) stopUpdatingLocation {
	[_locationManager stopUpdatingLocation];
}


#pragma mark CLLocationManagerDelegate
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if ( [self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)] ) {
		
		[self.delegate locationManager:self
					didUpdateLocations:locations];
		
	}

}

@end
