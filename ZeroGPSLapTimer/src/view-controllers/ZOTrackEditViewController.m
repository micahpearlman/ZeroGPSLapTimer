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

@interface ZOTrackEditViewController () <MKMapViewDelegate, CLLocationManagerDelegate> {
	MKMapView*				_mapView;
	CLLocationManager*		_locationManager;
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
	
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
			
        case UIGestureRecognizerStateChanged:
            /* equivalent to touchesMoved:withEvent: */
			NSLog( @"mapViewTapped UIGestureRecognizerStateChanged" );
            break;
			
        case UIGestureRecognizerStateEnded: {
			NSLog( @"mapViewTapped UIGestureRecognizerStateEnded" );
			ZOStartFinishLineOverlay* startFinishOverlay = [[ZOStartFinishLineOverlay alloc] initWithCoordinate:geoCoordinatesTapped];
			[_mapView addOverlay:startFinishOverlay];
			
			
			
		} break;
			
        case UIGestureRecognizerStateCancelled:
            /* equivalent to touchesCancelled:withEvent: */
			NSLog( @"mapViewTapped UIGestureRecognizerStateCancelled" );
            break;
			
        default:
            break;
    }
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
}

- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	if ( [overlay class] == [ZOStartFinishLineOverlay class] ) {
		ZOStartFinishLineAnnotationRenderer* startFinishRenderer = [[ZOStartFinishLineAnnotationRenderer alloc] initWithOverlay:overlay];
		return startFinishRenderer;
	}
	
	return nil;
}

@end
