//
//  ZOLapTimeViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/24/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOLapTimeViewController.h"
#import "ZOTrackCollection.h"
#import "ZOSession.h"
#import "ZOLap.h"
#import <MapKit/MapKit.h>

@interface ZOLapTimeViewController () <CLLocationManagerDelegate, ZOSessionStateDelegate, ZOTrackObjectDelegate> {
	CLLocationManager*		_locationManager;
	ZOTrack*				_track;
	ZOSession*				_session;
	ZOLap*					_currentLap;
	ZOLap*					_lastLap;
	
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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[_session endSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if ( _track == nil ) {
		CLLocation* lastLocation = [locations lastObject];
		NSDictionary* trackInfo = [[ZOTrackCollection instance] trackAtCoordinate:lastLocation.coordinate];
		if ( trackInfo ) {
			// load track from disk
			_track = [ZOTrack unarchiveFromTrackInfo:trackInfo];
			
			// create a new session
			_session = [[ZOSession alloc] initWithTrack:_track];
			_session.stateMonitorDelegate = self;
			[_track addSessionInfo:_session.sessionInfo];
			
			// set the track name label
			self.trackName.text = _track.name;
		}
	}
}

#pragma mark ZOSessionStateDelegate

- (void) zoSession:(ZOSession*)session stateChangedFrom:(ZOSessionState)from to:(ZOSessionState)to atWaypoint:(ZOWaypoint*)location {
	if ( to == ZOSessionState_StartLap ) {
		// monitor lap events
		ZOLap* currentLap = [session.laps lastObject];
		currentLap.delegate = self;
		
		// set the previous lap
		if ( [session.laps count] > 1 ) {
			ZOLap* previousLap = [session.laps objectAtIndex:[session.laps count] - 2];
			self.previousLapTime.text = previousLap.timeString;
		}
		
		// set the stop button
		self.startStopSession.enabled = YES;
//		self.startStopSession.titleLabel.text = @"STOP";
		
		// TODO: make the lap table dirty
	} else if ( to == ZOSessionState_EndSession ) {
		self.startStopSession.enabled = NO;
//		self.startStopSession.titleLabel.text = @"WAIT";
	}

}

#pragma mark ZOTrackObjectDelegate

- (void) zoTrackObject:(id<ZOTrackObject>)trackObject isDirty:(BOOL)isDirty {
	if ( [trackObject class] == [ZOLap class] ) {
		// lap has been updated so update our time labels
		ZOLap* currentLap = (ZOLap*)trackObject;
		self.currentLapTime.text = currentLap.timeString;
	}
}

#pragma mark Actions

- (IBAction) onStartStopSession:(id)sender {

	if ( _session.state == ZOSessionState_StartLap ) {
		[_session endSession];
	}
}



@end
