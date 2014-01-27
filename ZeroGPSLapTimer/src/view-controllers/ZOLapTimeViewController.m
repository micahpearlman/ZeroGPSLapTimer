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
#import "UIAlertView+Blocks.h"
#import "ZOVenusLocationManager.h"
#import "ZOInternalLocationManager.h"
#import <MapKit/MapKit.h>

@interface ZOLapTimeViewController () <ZOLocationManagerDelegate, ZOSessionStateDelegate, ZOTrackObjectDelegate> {
	ZOLocationManager*		_locationManager;
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
	//_locationManager = [[ZOInternalLocationManager alloc] init];
	_locationManager = [[ZOVenusLocationManager alloc] init];
	[_locationManager setDelegate:self];
	
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[_locationManager startUpdatingLocation];
	if ( _track && _session == nil ) {
		// start up a new session at current track
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[_locationManager stopUpdatingLocation];
	[_session endSession];
	
	// if session doesn't have any laps remove the session from the track
	if ( [_session.laps count] == 0 ) {
		[_track removeSessionInfo:_session.sessionInfo];
		_session = nil;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ZOLocationManagerDelegate
- (void)locationManager:(ZOLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if ( _track == nil ) {
		// if no track find the track that we are at
		CLLocation* lastLocation = [locations lastObject];
		// BUGBUG: there can be multiple tracks at coordinate
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
		} else {
			static BOOL isAlertView = NO;
			if ( isAlertView == NO ) {
				[manager stopUpdatingLocation];
				UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Track Not Found"
																	message:@"Create a new track at current location?"
																   delegate:nil cancelButtonTitle:@"Cancel"
														  otherButtonTitles:@"Ok", nil];
				
				[alertView showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
					[self.tabBarController setSelectedIndex:0];	// goto track table view
					isAlertView = NO;
				}];
				
				isAlertView = YES;
				
			}

		}
	} else {	// we have a track so update the session
		NSArray* waypoints = [ZOWaypoint ZOLocationArrayFromCLLocationArray:locations];
		[_session addWaypoints:waypoints];
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
		
		// TODO: make the lap table dirty
	} else if ( to == ZOSessionState_EndSession ) {
		self.startStopSession.enabled = NO;
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
