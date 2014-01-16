//
//  ZOSessionMapViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOSessionMapViewController.h"
#import "ZOTrackCollection.h"
#import "ZOStartFinishLine.h"
#import "ZOStartFinishLineRenderer.h"
#import "ZOTrackRenderer.h"
#import "ZOSessionRenderer.h"
#import <ZOLocation.h>

@interface ZOSessionMapViewController () <CLLocationManagerDelegate> {
	CLLocationManager*				_locationManager;
	ZOTrack*						_track;
	ZOSession*						_session;
	NSDictionary*					_sessionInfo;
	NSDictionary*					_trackEditInfo;

}

@end

@implementation ZOSessionMapViewController

@synthesize mapView;
@synthesize currentCoordinateLabel;


- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	/// setup location manager
	_track = [ZOTrackCollection instance].currentTrack;
	[self.mapView addOverlay:_track];
	[self.mapView addOverlays:_track.trackObjects];
	
	if ( _track.currentSessionInfo ) {
		_session = _track.currentSession;
	} else {
		// create new session
		_session = [_track addSessionAtDate:[NSDate date]];
		
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDelegate:self];
		[_locationManager setDistanceFilter:kCLDistanceFilterNone];
		[_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
		
	}
	
	[self.mapView addOverlay:_session];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[_session archive];	// exiting so make sure to save out session
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView_ didAddAnnotationViews:(NSArray *)views {
	for ( MKAnnotationView* annotationView in views ) {
		id<MKAnnotation> mp = [annotationView annotation];
		if ( [mp class] == [MKUserLocation class]) {
			MKCoordinateRegion adjustedRegion = MKCoordinateRegionMakeWithDistance([mp coordinate], 0.0001, 0.0001);
			[mapView_ setRegion:adjustedRegion animated:NO];
			// if no track created create a default track
			if ( _track == nil ) {
				_track = [[ZOTrack alloc] initWithCoordinate:[mp coordinate] boundingMapRect:mapView_.visibleMapRect];
				[mapView_ addOverlay:_track];
			}
			
		}
	}
}

- (MKOverlayRenderer*)mapView:(MKMapView *)mapView_ rendererForOverlay:(id<MKOverlay>)overlay {
	if ( [overlay class] == [ZOStartFinishLine class] ) {
		ZOStartFinishLineRenderer* startFinishRenderer = [[ZOStartFinishLineRenderer alloc] initWithOverlay:overlay];
		return startFinishRenderer;
	} else if ( [overlay class] == [ZOTrack class] ) {
		ZOTrackRenderer* trackRenderer = [[ZOTrackRenderer alloc] initWithOverlay:overlay];
		return trackRenderer;
	} else if ( [overlay class] == [ZOSession class]) {
		ZOSessionRenderer* sessionRenderer = [[ZOSessionRenderer alloc] initWithOverlay:overlay];
		return sessionRenderer;
	}
	
	return nil;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	

	NSArray* zolocations = [ZOLocation ZOLocationArrayFromCLLocationArray:locations];
	// TODO: do other sensor data
	[_session addLocations:zolocations];
	
}

#pragma mark IBActions

- (IBAction) toggleSessionUpdate:(id)sender {
	UIButton* button = (UIButton*)sender;
	button.selected = !button.selected;
	if ( button.selected ) {
		[_locationManager startUpdatingLocation];
	} else {
		[_locationManager stopUpdatingLocation];
		[_session archive];	// make sure to save session
	}
}


@end
