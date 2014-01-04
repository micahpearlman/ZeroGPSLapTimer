//
//  ZOFirstViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/20/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import "ZOMapViewController.h"
#import "ZOGPSExternalVenus.h"
#import <CoreLocation/CoreLocation.h>


@interface ZOMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, ZOGPSDelegate> {
	MKMapView*				_mapView;
	UILabel*				_currentCoordinateLabel;
	CLLocationManager*		_locationManager;
	MKPolyline*				_crumbPath;
	MKPolylineRenderer*		_crumbView;
	NSMutableArray*			_locations;	// CLLocation
	
	
	ZOGPS*					_gps;
	
	NSDictionary*			_geoJSON;
	MKPolyline*				_geoJSONPolyLine;
	MKPolylineRenderer*		_geoJSONPolyLineView;
}

@property (nonatomic,retain) MKPolyline* crumbPath;
@property (nonatomic,retain) MKPolylineRenderer* crumbView;

@property (nonatomic,retain) MKPolyline* geoJSONPolyLine;
@property (nonatomic,retain) MKPolylineRenderer* geoJSONPolyLineView;
@end

@implementation ZOMapViewController

@synthesize mapView					= _mapView;
@synthesize currentCoordinateLabel	= _currentCoordinateLabel;
@synthesize crumbPath				= _crumbPath;
@synthesize crumbView				= _crumbView;
@synthesize geoJSONPolyLine			= _geoJSONPolyLine;
@synthesize geoJSONPolyLineView		= _geoJSONPolyLineView;


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// setup location manager
//	_locationManager = [[CLLocationManager alloc] init];
//	[_locationManager setDelegate:self];
//	[_locationManager setDistanceFilter:kCLDistanceFilterNone];
//	[_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
//	[_locationManager startUpdatingLocation];
	
	
	// init gps
	_gps = [ZOGPSExternalVenus instance];
	_gps.delegate = self;
	[_gps connect];
	
	// init geoJSON
	NSString* geoJSONFilePath = [[NSBundle mainBundle] pathForResource:@"example-linestring" ofType:@"json" inDirectory:@"assets"];
	NSData* geoJSONFileData = [NSData dataWithContentsOfFile:geoJSONFilePath];
	NSError* error = nil;
	_geoJSON = [NSJSONSerialization JSONObjectWithData:geoJSONFileData options:NSJSONReadingMutableContainers error:&error];
	if ( error == nil ) {
		for (NSDictionary* feature in [_geoJSON objectForKey:@"features"] ) {
			NSDictionary* geometry = [feature objectForKey:@"geometry"];
			NSString* type = [geometry objectForKey:@"type"];
			if ( [type isEqualToString:@"LineString"] ) {
				NSArray* coordinates = [geometry objectForKey:@"coordinates"];
				CLLocationCoordinate2D* coordCArray = (CLLocationCoordinate2D*)malloc( [coordinates count] * sizeof(CLLocationCoordinate2D) );
				for ( int i = 0; i < [coordinates count]; i++ ) {
					NSArray* coord = [coordinates objectAtIndex:i];
					NSNumber* longitude = [coord objectAtIndex:0];
					NSNumber* lattitude = [coord objectAtIndex:1];
					coordCArray[i].longitude = [longitude doubleValue];
					coordCArray[i].latitude = [lattitude doubleValue];
				}
				
				self.geoJSONPolyLine = [MKPolyline polylineWithCoordinates:coordCArray count:[coordinates count]];
				[_mapView addOverlay:self.geoJSONPolyLine];
				free( coordCArray );

				
			}
		}
	}
	
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

	if ( _locations == nil ) {
		_locations = [[NSMutableArray alloc] init];
		[_locations addObjectsFromArray:locations];
	}
	
	CLLocation* lastLocation = [_locations lastObject];
	CLLocation* currentLocation = [locations lastObject];
	NSString* coordinateString = [NSString stringWithFormat:@"%f,%f [%f]", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [lastLocation distanceFromLocation:currentLocation]];
	[self.currentCoordinateLabel setText:coordinateString];
	if ( [lastLocation distanceFromLocation:currentLocation] > 0 ) {
		// fill in location array
		NSInteger locationCount = [locations count];
		// store the coordinate in
		[_locations addObjectsFromArray:locations];
		locationCount = [_locations count];
		if ( locationCount > 1 ) {
			
			// create a new MKPolyLine from our total locations
			
			CLLocationCoordinate2D* coordinates = (CLLocationCoordinate2D*)malloc( locationCount * sizeof(CLLocationCoordinate2D) );
			for ( int i = 0; i < locationCount; i++ ) {
				CLLocation* location = [_locations objectAtIndex:i];
				coordinates[i] = location.coordinate;
			}
			
			
			if ( _crumbPath ) {
				[_mapView removeOverlay:_crumbPath];
			}
			
			self.crumbPath = [MKPolyline polylineWithCoordinates:coordinates count:locationCount];
			[_mapView addOverlay:self.crumbPath];
			free( coordinates );
			
		}
		
	}
	
}

#pragma mark GPS delegate

-(void) zoGPS:(ZOGPS*)gps didUpdateLocations:(NSArray*)locations {
	if ( _locations == nil ) {
		_locations = [[NSMutableArray alloc] init];
		[_locations addObjectsFromArray:locations];
	}
	
	CLLocation* lastLocation = [_locations lastObject];
	CLLocation* currentLocation = [locations lastObject];
	NSString* coordinateString = [NSString stringWithFormat:@"%f,%f [%f]", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [lastLocation distanceFromLocation:currentLocation]];
	[self.currentCoordinateLabel setText:coordinateString];
	if ( [lastLocation distanceFromLocation:currentLocation] > 0 ) {
		// fill in location array
		NSInteger locationCount = [locations count];
		// store the coordinate in
		[_locations addObjectsFromArray:locations];
		locationCount = [_locations count];
		if ( locationCount > 1 ) {
			
			// create a new MKPolyLine from our total locations
			
			CLLocationCoordinate2D* coordinates = (CLLocationCoordinate2D*)malloc( locationCount * sizeof(CLLocationCoordinate2D) );
			for ( int i = 0; i < locationCount; i++ ) {
				CLLocation* location = [_locations objectAtIndex:i];
				coordinates[i] = location.coordinate;
			}
			
			
			if ( _crumbPath ) {
				[_mapView removeOverlay:_crumbPath];
			}
			
			self.crumbPath = [MKPolyline polylineWithCoordinates:coordinates count:locationCount];
			[_mapView addOverlay:self.crumbPath];
			free( coordinates );
			
		}

	}
	
	// update map location
	[_mapView setRegion:MKCoordinateRegionMake( ((CLLocation*)[locations lastObject]).coordinate, MKCoordinateSpanMake(0.0, 0.0) ) animated:YES];

	
}


- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
//	if ( self.crumbView == nil ) {
		self.crumbView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
		
		self.crumbView.fillColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.4];
        self.crumbView.strokeColor = [UIColor greenColor];
        self.crumbView.lineWidth = 2;
		
//	}
	
	return _crumbView;
}


@end
