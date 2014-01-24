//
//  ZOLapTimeViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/24/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOLapTimeViewController.h"
#import "ZOTrackCollection.h"
#import <MapKit/MapKit.h>

@interface ZOLapTimeViewController () <CLLocationManagerDelegate> {
	CLLocationManager*		_locationManager;
	NSDictionary*			_trackInfo;
}

@end

@implementation ZOLapTimeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// setup location manager
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDelegate:self];
	[_locationManager setDistanceFilter:kCLDistanceFilterNone];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
	[_locationManager startUpdatingLocation];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if ( _trackInfo == nil ) {
		CLLocation* lastLocation = [locations lastObject];
		_trackInfo = [[ZOTrackCollection instance] trackAtCoordinate:lastLocation.coordinate];
		if ( _trackInfo ) {
			self.trackName.text = [_trackInfo objectForKey:@"name"];
		}
	}
	
}


@end
