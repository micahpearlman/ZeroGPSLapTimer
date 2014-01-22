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
#import "ZOWaypointRenderer.h"
#import "MKMapView+ZoomLevel.h"
#import <ZOWaypoint.h>

typedef enum  {
	ZOSessionMapViewController_None,
	ZOSessionMapViewController_Recording,
	ZOSessionMapViewController_Playback,
	ZOSessionMapViewController_Paused
} ZOSessionMapViewControllerState;

@interface ZOSessionMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, ZOSessionStateDelegate> {
	CLLocationManager*				_locationManager;
	ZOTrack*						_track;
	ZOSession*						_session;
	NSDictionary*					_sessionInfo;
	NSDictionary*					_trackEditInfo;
	ZOSessionMapViewControllerState	_state;
	NSTimer*						_playbackTimer;
	NSTimeInterval					_currentPlaybackTime;
	ZOWaypoint*						_currentPlaybackWaypoint;
	ZOWaypoint*						_interpolatedWayPoint;
}

@end

@implementation ZOSessionMapViewController

@synthesize mapView;



- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		self.hidesBottomBarWhenPushed = YES;
		_currentPlaybackTime = 0;
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	_state = ZOSessionMapViewController_None;
	
	/// setup location manager
	_track = [ZOTrackCollection instance].currentTrack;
	[self.mapView addOverlay:_track];
	[self.mapView addOverlays:_track.trackObjects];
	
	if ( _track.currentSessionInfo ) {
		// load existing session
		_session = _track.currentSession;
	} else {
		// create new session
		_session = [_track addSessionAtDate:[NSDate date]];
		
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDelegate:self];
		[_locationManager setDistanceFilter:kCLDistanceFilterNone];
		[_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
	}
	
	_session.stateMonitorDelegate = self;
	
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

- (void) gotoState:(ZOSessionMapViewControllerState)state {
	if ( state == _state ) {
		return;
	}
	
	switch ( state ) {
			
		case ZOSessionMapViewController_None:
			if ( _state == ZOSessionMapViewController_Recording ) {
				self.record.image = [UIImage imageNamed:@"record"];
				[_locationManager stopUpdatingLocation];
				[self.mapView setUserTrackingMode:MKUserTrackingModeNone];
				[_session archive];	// make sure to save session
			}
			break;
			
		case ZOSessionMapViewController_Recording:
			self.record.image = [UIImage imageNamed:@"pause"];
			[_locationManager startUpdatingLocation];
			[self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
			break;
			
		case ZOSessionMapViewController_Playback:
			self.mapView.showsUserLocation = NO;
			self.play.image = [UIImage imageNamed:@"pause"];
			if ( _currentPlaybackWaypoint == nil ) {
				_currentPlaybackWaypoint = [[_session.waypoints firstObject] copy];
				_currentPlaybackWaypoint.boundingMapRect = _track.boundingMapRect;	// IMPORTANT: set the bounding maprect to the track bounding map rect
				[self.mapView addOverlay:_currentPlaybackWaypoint];
			}
			_playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/20.0 target:self selector:@selector(playbackTimer:) userInfo:nil repeats:YES];
 			break;
			
		case ZOSessionMapViewController_Paused:
			self.play.image = [UIImage imageNamed:@"play"];
			[_playbackTimer invalidate];
			break;
			
		default:
			break;
	}
	_state = state;
}

#pragma mark Playback
- (void) playbackTimer:(NSTimer*)timer {
	
	_interpolatedWayPoint = [_session waypointAtTimeInterval:_currentPlaybackTime];
	
	NSTimeInterval minutes = _currentPlaybackTime / 60.0;
	NSTimeInterval seconds = fmod(_currentPlaybackTime, 60.0);
	self.lapTime.text = [NSString stringWithFormat:@"%d:%4.2f", (int)minutes, seconds];
	
	
	// check for finish line cross
	CLCoordinateLineSegment line;
	line.start = _currentPlaybackWaypoint.coordinate;
	line.end = _interpolatedWayPoint.coordinate;
	CLLocationCoordinate2D intersection;
	id<ZOTrackObject> intersectObject = [_track checkTrackObjectsIntersectLineSegment:line withIntersectResult:&intersection];
	if ( intersectObject ) {
		NSLog(@"CROSSED FINISHE LINE");
	}


	[_currentPlaybackWaypoint setCoordinate:_interpolatedWayPoint.coordinate];
//	self.debug.text = [NSString stringWithFormat:@"%f, %f", _interpolatedWayPoint.coordinate.latitude, _interpolatedWayPoint.coordinate.longitude];

	self.debug.text = [NSString stringWithFormat:@"%f", _interpolatedWayPoint.location.mph];
	_currentPlaybackTime = _currentPlaybackTime + timer.timeInterval;
	
	// update map to center
	self.mapView.camera.centerCoordinate = _interpolatedWayPoint.coordinate;
}


#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView_ didAddAnnotationViews:(NSArray *)views {
	for ( MKAnnotationView* annotationView in views ) {
		id<MKAnnotation> mp = [annotationView annotation];
		if ( [mp class] == [MKUserLocation class]) {
			MKMapCamera* camera = [MKMapCamera cameraLookingAtCenterCoordinate:[mp coordinate]
															 fromEyeCoordinate:[mp coordinate]
																   eyeAltitude:50];
			[self.mapView setCamera:camera];
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
	} else if ( [overlay class] == [ZOWaypoint class] ) {
		ZOWaypointRenderer* waypointRenderer = [[ZOWaypointRenderer alloc] initWithOverlay:overlay];
		waypointRenderer.fillColor = [UIColor redColor];
		return waypointRenderer;
	} else if ( [overlay class] == [MKCircle class] ) {
		MKCircleRenderer* circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
		circleRenderer.fillColor = [UIColor redColor];
		return circleRenderer;		
	}
	
	return nil;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	
	NSArray* zolocations = [ZOWaypoint ZOLocationArrayFromCLLocationArray:locations];
	// TODO: do other sensor data
	[_session addWaypoints:zolocations];
	
	// update the map
//	CLLocation* lastLocation = [locations lastObject];
//	[self.mapView setCenterCoordinate:lastLocation.coordinate];
//	MKCoordinateRegion adjustedRegion = MKCoordinateRegionMakeWithDistance(lastLocation.coordinate, 0.0001, 0.0001);
//	[self.mapView setRegion:adjustedRegion animated:NO];

	
	
}

#pragma mark IBActions

- (IBAction) toggleSessionRecord:(id)sender {
	
	if ( _state == ZOSessionMapViewController_None ) {
		[self gotoState:ZOSessionMapViewController_Recording];
	} else if ( _state == ZOSessionMapViewController_Recording ) {
		[self gotoState:ZOSessionMapViewController_None];
	}
}

- (IBAction) onPlayPause:(id)sender {
	if ( _state == ZOSessionMapViewController_None || _state == ZOSessionMapViewController_Paused ) {
		[self gotoState:ZOSessionMapViewController_Playback];
	} else if ( _state == ZOSessionMapViewController_Playback ) {
		[self gotoState:ZOSessionMapViewController_Paused];
	}
}


#pragma mark ZOSessionStateDelegate

- (void) zoSession:(ZOSession*)session stateChangedFrom:(ZOSessionState)from to:(ZOSessionState)to atLocation:(ZOWaypoint*)location {
	
	if ( to == ZOSessionState_Lapping ) {
		self.lapTime.text = @"LAPPING";
	} else {
		self.lapTime.text = @"OFF TRACK";
	}
}




@end
