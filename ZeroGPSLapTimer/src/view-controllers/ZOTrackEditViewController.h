//
//  ZOTrackEditViewController.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/4/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ZOTrack.h"

@interface ZOTrackEditViewController : UIViewController

@property (nonatomic,retain) ZOTrack* track;

@property (nonatomic,retain) IBOutlet MKMapView* mapView;

- (IBAction)onCreateStartFinish:(id)sender;
- (IBAction)onSave:(id)sender;

@end
