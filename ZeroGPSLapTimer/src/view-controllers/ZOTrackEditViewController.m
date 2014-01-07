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
	ZOTrackEditViewControllerState_PlaceStartFinish
} ZOTrackEditViewControllerState;

@interface ZOTrackEditViewController () <MKMapViewDelegate, CLLocationManagerDelegate> {
	MKMapView*						_mapView;
	CLLocationManager*				_locationManager;
	ZOTrackEditViewControllerState	_state;
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
	UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																					action:@selector(mapViewTapped:)];
	[_mapView addGestureRecognizer:tapRecognizer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MapView gesture recognizer


- (void)mapViewTapped:(UITapGestureRecognizer *)recognizer
{
    CGPoint pointTappedInMapView = [recognizer locationInView:_mapView];
    CLLocationCoordinate2D geoCoordinatesTapped = [_mapView convertPoint:pointTappedInMapView toCoordinateFromView:_mapView];
	
	if ( recognizer.state != UIGestureRecognizerStateEnded ) {
		return;
	}
	
	if ( _state == ZOTrackEditViewControllerState_None ) {
		// see if we are selecting one of our overlays
		MKMapPoint mapPoint = MKMapPointForCoordinate( geoCoordinatesTapped );
		for ( id<MKOverlay> overlay in _mapView.overlays ) {
			//
			MKMapRect mapRect = overlay.boundingMapRect;
			
			// check if map point is inside the map rect
//			BOOL isInside = YES;
//			if ( mapPoint.x < MKMapRectGetMinX( mapRect ) || mapPoint.x > MKMapRectGetMaxX( mapRect )
//				|| mapPoint.y < MKMapRectGetMinY( mapRect ) || mapPoint.y > MKMapRectGetMaxY( mapRect )) {
//				isInside = NO;
//			}
			if ( MKMapRectContainsPoint( mapRect, mapPoint ) ) {
				NSLog(@"touched overlay" );
			}
		}
		
	} else if ( _state == ZOTrackEditViewControllerState_PlaceStartFinish ) {
		ZOStartFinishLineOverlay* startFinishOverlay = [[ZOStartFinishLineOverlay alloc] initWithCoordinate:geoCoordinatesTapped];
		[_mapView addOverlay:startFinishOverlay];
	}

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
