//
//  ZOSessionMapViewController.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ZOSessionMapViewController : UIViewController

@property (nonatomic,retain) IBOutlet MKMapView* mapView;
@property (nonatomic,retain) IBOutlet UIBarButtonItem* rewind;
@property (nonatomic,retain) IBOutlet UIBarButtonItem* play;
@property (nonatomic,retain) IBOutlet UIBarButtonItem* record;
@property (nonatomic,retain) IBOutlet UIBarButtonItem* fastForward;

- (IBAction) toggleSessionRecord:(id)sender;
@end
