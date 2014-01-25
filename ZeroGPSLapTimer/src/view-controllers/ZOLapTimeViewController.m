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
#import <MapKit/MapKit.h>

@interface ZOLapTimeViewController () <CLLocationManagerDelegate, ZOSessionStateDelegate> {
	CLLocationManager*		_locationManager;
	ZOTrack*				_track;
	ZOSession*				_session;
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
	if ( _track == nil ) {
		CLLocation* lastLocation = [locations lastObject];
		NSDictionary* trackInfo = [[ZOTrackCollection instance] trackAtCoordinate:lastLocation.coordinate];
		if ( trackInfo ) {
			// load track from disk
			_track = [ZOTrack unarchiveFromTrackInfo:trackInfo];
			
			// create a new session
			_session = [[ZOSession alloc] initWithTrack:_track];
			[_track addSessionInfo:_session.sessionInfo];
			
			// set the track name label
			self.trackName.text = _track.name;
		}
	}
}

#pragma mark ZOSessionStateDelegate

- (void) zoSession:(ZOSession*)session stateChangedFrom:(ZOSessionState)from to:(ZOSessionState)to atWaypoint:(ZOWaypoint*)location {
	
}
- (void) zoSession:(ZOSession*)session playbackCursorAtWaypoint:(ZOWaypoint*)waypoint {
	
}



@end
