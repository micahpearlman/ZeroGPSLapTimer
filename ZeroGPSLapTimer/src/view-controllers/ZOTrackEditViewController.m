//
//  ZOTrackEditViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/4/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOTrackEditViewController.h"
#import "ZOTrack.h"
#import "ZOTrackRenderer.h"
#import "ZOStartFinishLine.h"
#import "ZOStartFinishLineRenderer.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

typedef enum {
	ZOTrackEditViewControllerState_None,
	ZOTrackEditViewControllerState_EditTrackObject
} ZOTrackEditViewControllerState;

@interface ZOTrackEditViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate> {
	MKMapView*						_mapView;
	CLLocationManager*				_locationManager;
	ZOTrackEditViewControllerState	_state;
	id<ZOTrackObject>				_selectedTrackObject;
	ZOTrack*						_track;
	
}

@end

@implementation ZOTrackEditViewController

@synthesize mapView					= _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		self.hidesBottomBarWhenPushed = YES;
		_state = ZOTrackEditViewControllerState_None;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	/// setup location manager
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDelegate:self];
	[_locationManager setDistanceFilter:kCLDistanceFilterNone];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
	[_locationManager startUpdatingLocation];
	
	/// setup gesture recognizers
	UITapGestureRecognizer* singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																					action:@selector(mapViewTapped:)];
	singleTapRecognizer.delegate = self;
	singleTapRecognizer.numberOfTapsRequired = 1;
	

	UITapGestureRecognizer* doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																						  action:@selector(mapViewDoubleTapped:)];
	doubleTapRecognizer.delegate = self;	// this allows
	doubleTapRecognizer.numberOfTapsRequired = 2;
	[singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];


	
	UIPanGestureRecognizer* panGestureRecoginizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
																	 action:@selector(mapViewPan:)];
	panGestureRecoginizer.delegate = self;
	panGestureRecoginizer.maximumNumberOfTouches = 1;
	panGestureRecoginizer.minimumNumberOfTouches = 1;
	
	UIRotationGestureRecognizer* rotateGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self
																										action:@selector(mapViewRotate:)];
	rotateGestureRecognizer.delegate = self;

	
//	[doubleTapRecognizer setDelaysTouchesBegan : YES];
//	[singleTapRecognizer setDelaysTouchesBegan : YES];
	[_mapView addGestureRecognizer:rotateGestureRecognizer];
	[_mapView addGestureRecognizer:doubleTapRecognizer];
	[_mapView addGestureRecognizer:singleTapRecognizer];
	[_mapView addGestureRecognizer:panGestureRecoginizer];
	

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark MapView gesture recognizer
- (void) gotoState:(ZOTrackEditViewControllerState)state {
	switch ( state ) {
		case ZOTrackEditViewControllerState_None:
			_mapView.scrollEnabled = YES;	// resume scrolling and panning
			_mapView.rotateEnabled = YES;
			break;
			
		case ZOTrackEditViewControllerState_EditTrackObject:
			_mapView.scrollEnabled = NO;	// stop map scrolling and panning
			_mapView.rotateEnabled = NO;
			break;
			
		default:
			break;
	}
	_state = state;
}

- (void) selectTrackObject:(id<ZOTrackObject>)trackObject {
	if ( trackObject == _selectedTrackObject ) {	// unselect
		trackObject.isSelected = NO;
		_selectedTrackObject = nil;
		[self gotoState:ZOTrackEditViewControllerState_None];
		return;
	} else {
		_selectedTrackObject = trackObject;
		_selectedTrackObject.isSelected = YES;
		[self gotoState:ZOTrackEditViewControllerState_EditTrackObject];
	}
}

- (IBAction)mapViewTapped:(UITapGestureRecognizer *)recognizer
{
    CGPoint pointTappedInMapView = [recognizer locationInView:_mapView];
    CLLocationCoordinate2D geoCoordinatesTapped = [_mapView convertPoint:pointTappedInMapView toCoordinateFromView:_mapView];
	
	if ( recognizer.state != UIGestureRecognizerStateEnded ) {
		return;
	}
	
	if ( _state == ZOTrackEditViewControllerState_None || _state == ZOTrackEditViewControllerState_EditTrackObject ) {
		NSArray* selectedTrackObjects = [_track trackObjectsAtCoordinate:geoCoordinatesTapped];
		[self selectTrackObject:[selectedTrackObjects lastObject]];
		
	}

}

- (IBAction)mapViewDoubleTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint pointTappedInMapView = [recognizer locationInView:_mapView];
    CLLocationCoordinate2D geoCoordinatesTapped = [_mapView convertPoint:pointTappedInMapView toCoordinateFromView:_mapView];
	
	if ( recognizer.state != UIGestureRecognizerStateEnded ) {
		return;
	}
	
	// see if we are selecting one of our overlays
	MKMapPoint mapPoint = MKMapPointForCoordinate( geoCoordinatesTapped );
	for ( id<MKOverlay> overlay in _mapView.overlays ) {
		
		if ( MKMapRectContainsPoint( overlay.boundingMapRect, mapPoint ) ) {
			NSLog(@"double touched overlay" );
			[_mapView removeOverlay:overlay];
			return;
		}
	}
}


- (IBAction)mapViewPan:(UIPanGestureRecognizer *)recognizer {
	static CGPoint originalPoint;
	
	CGPoint pointTappedInMapView = [recognizer locationInView:_mapView];
	
	if ( recognizer.state == UIGestureRecognizerStateBegan && _selectedTrackObject ) {
		originalPoint = pointTappedInMapView;
	} else if ( recognizer.state == UIGestureRecognizerStateChanged && _selectedTrackObject ) {
		CGPoint translation = [recognizer translationInView:_mapView];
		CGPoint newPoint = CGPointMake( originalPoint.x + translation.x, originalPoint.y + translation.y );
		CLLocationCoordinate2D translationGeo = [_mapView convertPoint:newPoint toCoordinateFromView:_mapView];
		MKMapPoint mapPoint = MKMapPointForCoordinate( translationGeo );
		if ( MKMapRectContainsPoint( _selectedTrackObject.boundingMapRect, mapPoint ) ) {
			_mapView.scrollEnabled = NO;	// resume scrolling and panning
			[_selectedTrackObject setCoordinate:translationGeo];
		} else {
			_mapView.scrollEnabled = YES;
		}
	}
}

- (IBAction)mapViewRotate:(UIRotationGestureRecognizer*)recognizer {
	if ( _state == ZOTrackEditViewControllerState_EditTrackObject && _selectedTrackObject ) {
//		NSLog(@"rotate: %f", RADIANS_TO_DEGREES( recognizer.rotation ) );
		_selectedTrackObject.rotate = recognizer.rotation;
	}
}


#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;	// YES
}


#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	for ( MKAnnotationView* annotationView in views ) {
		id<MKAnnotation> mp = [annotationView annotation];
		if ( [mp class] == [MKUserLocation class]) {
			MKCoordinateRegion adjustedRegion = MKCoordinateRegionMakeWithDistance([mp coordinate], 0.0001, 0.0001);
			[mapView setRegion:adjustedRegion animated:NO];
			// if no track created create a default track
			if ( _track == nil ) {
				_track = [[ZOTrack alloc] initWithCoordinate:[mp coordinate] boundingMapRect:_mapView.visibleMapRect];
				[_mapView addOverlay:_track];
			}
			
		}
	}
}

- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	if ( [overlay class] == [ZOStartFinishLine class] ) {
		ZOStartFinishLineRenderer* startFinishRenderer = [[ZOStartFinishLineRenderer alloc] initWithOverlay:overlay];
		return startFinishRenderer;
	} else if ( [overlay class] == [ZOTrack class] ) {
		ZOTrackRenderer* trackRenderer = [[ZOTrackRenderer alloc] initWithOverlay:overlay];
		return trackRenderer;
	}
	
	return nil;
}



- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	NSLog(@"didDeselectAnnotationView");
}

#pragma mark Location Manager update
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
}



#pragma mark Actions

- (IBAction) onStartFinishSelected:(id)sender {

	id<ZOTrackObject> startFinishLine = [_track addStartFinishLineAtCoordinate:[_mapView centerCoordinate]];
	[_mapView addOverlay:startFinishLine];
	
}
@end
