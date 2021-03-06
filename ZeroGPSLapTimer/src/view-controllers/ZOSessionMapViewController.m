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

@interface ZOSessionMapViewController () <MKMapViewDelegate, ZOSessionStateDelegate> {
	ZOSessionMapViewControllerState	_state;
	ZOWaypoint*						_playbackCursor;
	NSDate*							_startLapTimeStamp;
}

@end

@implementation ZOSessionMapViewController

@synthesize mapView;



- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	_state = ZOSessionMapViewController_None;
	
	/// setup location manager
	[self.mapView addOverlay:self.session.track];
	[self.mapView addOverlays:self.session.track.trackObjects];
	
	MKMapCamera* camera = [MKMapCamera cameraLookingAtCenterCoordinate:self.session.coordinate
													 fromEyeCoordinate:self.session.coordinate
														   eyeAltitude:50];
	[self.mapView setCamera:camera];
	
	_session.stateMonitorDelegate = self;
	
	[self.mapView addOverlay:_session];
}

- (void) viewWillDisappear:(BOOL)animated {
	[self gotoState:ZOSessionMapViewController_None];
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
				[self.mapView setUserTrackingMode:MKUserTrackingModeNone];
				[_session archive];	// make sure to save session
				[_session endSession];
			} else if( _state == ZOSessionMapViewController_Playback ) {
				[_session setIsPlaybackPaused:YES];
			}
			break;
			
		case ZOSessionMapViewController_Recording:
			self.record.image = [UIImage imageNamed:@"pause"];
			[self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
			break;
			
		case ZOSessionMapViewController_Playback:
			self.mapView.showsUserLocation = NO;
			self.play.image = [UIImage imageNamed:@"pause"];
			
			// create a cursor that will track the playback
			if ( _playbackCursor == nil ) {
				_playbackCursor = [[_session.waypoints firstObject] copy];
				_playbackCursor.boundingMapRect = self.session.track.boundingMapRect;	// IMPORTANT: set the bounding maprect to the track bounding map rect
				[self.mapView addOverlay:_playbackCursor];
			}
			[_session startPlaybackAtStartTime:0
							  withTimeInterval:1.0/20.0
									  andScale:1.0];
 			break;
			
		case ZOSessionMapViewController_Paused:
			[_session setIsPlaybackPaused:YES];
			self.play.image = [UIImage imageNamed:@"play"];
			break;
			
		default:
			break;
	}
	_state = state;
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


#pragma mark IBActions

- (IBAction) toggleSessionRecord:(id)sender {
	
//	if ( _state == ZOSessionMapViewController_None ) {
//		[self gotoState:ZOSessionMapViewController_Recording];
//	} else if ( _state == ZOSessionMapViewController_Recording ) {
//		[self gotoState:ZOSessionMapViewController_None];
//	}
}

- (IBAction) onPlayPause:(id)sender {
	if ( _state == ZOSessionMapViewController_None || _state == ZOSessionMapViewController_Paused ) {
		[self gotoState:ZOSessionMapViewController_Playback];
	} else if ( _state == ZOSessionMapViewController_Playback ) {
		[self gotoState:ZOSessionMapViewController_Paused];
	}
}


#pragma mark ZOSessionStateDelegate

- (void) zoSession:(ZOSession*)session stateChangedFrom:(ZOSessionState)from to:(ZOSessionState)to atWaypoint:(ZOWaypoint*)waypoint {

	if ( to == ZOSessionState_StartLap ) {
		_startLapTimeStamp = waypoint.timestamp;
	}
}

- (void) zoSession:(ZOSession*)session playbackCursorAtWaypoint:(ZOWaypoint*)waypoint {
	
	// update laptime label
	if ( _session.state == ZOSessionState_StartLap ) {
		NSTimeInterval lapTime = [waypoint.timestamp timeIntervalSinceDate:_startLapTimeStamp];
		NSTimeInterval minutes = lapTime / 60.0;
		NSTimeInterval seconds = fmod( lapTime, 60.0);
		self.lapTime.text = [NSString stringWithFormat:@"%02d:%04.2f", (int)minutes, seconds];
		
	}
	
	// update speed label
	self.debug.text = [NSString stringWithFormat:@"%f", waypoint.location.mph];
	
	// center map on the waypoint
	self.mapView.camera.centerCoordinate = waypoint.coordinate;
	
	// update the cursor
	[_playbackCursor setCoordinate:waypoint.coordinate];


	
}




@end
