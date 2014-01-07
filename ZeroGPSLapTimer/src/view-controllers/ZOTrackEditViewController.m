//
//  ZOTrackEditViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/4/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOTrackEditViewController.h"
#import "ZOStartFinishLineOverlay.h"
#import "ZOStartFinishLineRenderer.h"


typedef enum {
	ZOTrackEditViewControllerState_None,
	ZOTrackEditViewControllerState_PlaceStartFinish,
	ZOTrackEditViewController_Edit
} ZOTrackEditViewControllerState;

@interface ZOTrackEditViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate> {
	MKMapView*						_mapView;
	CLLocationManager*				_locationManager;
	ZOTrackEditViewControllerState	_state;
	ZOStartFinishLineOverlay*		_editOverlay;
	UIPanGestureRecognizer*			_panGestureRecoginizer;
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
	
	// setup location manager
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDelegate:self];
	[_locationManager setDistanceFilter:kCLDistanceFilterNone];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
	[_locationManager startUpdatingLocation];
	
	// setup gesture recognizers
	UITapGestureRecognizer* singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																					action:@selector(mapViewTapped:)];
	singleTapRecognizer.delegate = self;
	singleTapRecognizer.numberOfTapsRequired = 1;
	

	UITapGestureRecognizer* doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																						  action:@selector(mapViewDoubleTapped:)];
	doubleTapRecognizer.delegate = self;	// this allows
	doubleTapRecognizer.numberOfTapsRequired = 2;
	[singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];


	
	_panGestureRecoginizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
																	 action:@selector(mapViewPan:)];
	_panGestureRecoginizer.delegate = self;
	
	
	
	[doubleTapRecognizer setDelaysTouchesBegan : YES];
	[singleTapRecognizer setDelaysTouchesBegan : YES];
	
	[_mapView addGestureRecognizer:doubleTapRecognizer];
	[_mapView addGestureRecognizer:singleTapRecognizer];
	[_mapView addGestureRecognizer:_panGestureRecoginizer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark MapView gesture recognizer


- (IBAction)mapViewTapped:(UITapGestureRecognizer *)recognizer
{
    CGPoint pointTappedInMapView = [recognizer locationInView:_mapView];
    CLLocationCoordinate2D geoCoordinatesTapped = [_mapView convertPoint:pointTappedInMapView toCoordinateFromView:_mapView];
	
	if ( recognizer.state != UIGestureRecognizerStateEnded ) {
		return;
	}
	
	if ( _state == ZOTrackEditViewControllerState_None || _state == ZOTrackEditViewController_Edit ) {
		// see if we are selecting one of our overlays
		MKMapPoint mapPoint = MKMapPointForCoordinate( geoCoordinatesTapped );
		for ( id<MKOverlay> overlay in _mapView.overlays ) {
			
			if ( MKMapRectContainsPoint( overlay.boundingMapRect, mapPoint ) ) {
				NSLog(@"touched overlay" );
				if ( [overlay class] == [ZOStartFinishLineOverlay class] ) {
					ZOStartFinishLineOverlay* startFinishOverlay = (ZOStartFinishLineOverlay*)overlay;
					startFinishOverlay.isSelected = !startFinishOverlay.isSelected;
					
					if ( _editOverlay == startFinishOverlay ) {
						_editOverlay = nil;
						startFinishOverlay.isSelected = NO;
						_mapView.scrollEnabled = YES;	// resume scrolling and panning
						_state = ZOTrackEditViewControllerState_None;
					} else {
						if ( _editOverlay ) {
							_editOverlay.isSelected = NO;
						}
						_editOverlay = startFinishOverlay;
						_editOverlay.isSelected = YES;
						_mapView.scrollEnabled = NO;	// stop view from panning and scrolling
						_state = ZOTrackEditViewController_Edit;
					}
				}

			}
		}
		
	} else if ( _state == ZOTrackEditViewControllerState_PlaceStartFinish ) {
		ZOStartFinishLineOverlay* startFinishOverlay = [[ZOStartFinishLineOverlay alloc] initWithCoordinate:geoCoordinatesTapped];
		[_mapView addOverlay:startFinishOverlay];
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
//    CLLocationCoordinate2D geoCoordinatesTapped = [_mapView convertPoint:pointTappedInMapView toCoordinateFromView:_mapView];
	
	if ( recognizer.state == UIGestureRecognizerStateBegan && _editOverlay ) {
		originalPoint = pointTappedInMapView;
	} else if ( recognizer.state == UIGestureRecognizerStateChanged && _editOverlay ) {
		CGPoint translation = [recognizer translationInView:_mapView];
		CGPoint newPoint = CGPointMake( originalPoint.x + translation.x, originalPoint.y + translation.y );
		CLLocationCoordinate2D translationGeo = [_mapView convertPoint:newPoint toCoordinateFromView:_mapView];
		[_editOverlay setCoordinate:translationGeo];
//		NSLog(@"pan at: %f, %f", translationGeo.latitude, translationGeo.longitude );
	}


}


#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;	// YES
}


#pragma mark MapView Delegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	for ( MKAnnotationView* annotationView in views ) {
		id<MKAnnotation> mp = [annotationView annotation];
		if ( [mp class] == [MKUserLocation class]) {
			MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 10, 10);
			[mapView setRegion:region animated:YES];
		}
	}
}


- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	NSLog(@"didDeselectAnnotationView");
}

#pragma mark Location Manager update
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
}

- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	if ( [overlay class] == [ZOStartFinishLineOverlay class] ) {
		ZOStartFinishLineRenderer* startFinishRenderer = [[ZOStartFinishLineRenderer alloc] initWithOverlay:overlay];
		return startFinishRenderer;
	}
	
	return nil;
}


#pragma mark Actions

- (IBAction) onStartFinishSelected:(id)sender {
	UIButton* button = (UIButton*)sender;
	button.selected = !button.selected;
	
	if ( button.selected == YES ) {
		_state = ZOTrackEditViewControllerState_PlaceStartFinish;
	} else {
		_state = ZOTrackEditViewControllerState_None;
	}
}
@end
