//
//  ZOFirstViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/20/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import "ZOMapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ZOMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate> {
	IBOutlet MKMapView*		_mapView;
	CLLocationManager*		_locationManager;
}

@end

@implementation ZOMapViewController

@synthesize mapView = _mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// setup location manager
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDelegate:self];
	[_locationManager setDistanceFilter:kCLDistanceFilterNone];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
	[_locationManager startUpdatingLocation];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MapView Delegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	
    id<MKAnnotation> mp = [annotationView annotation];
	
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,25,25);
    [mapView setRegion:region animated:YES];

}

#pragma mark Location Manager update
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	
}

@end
