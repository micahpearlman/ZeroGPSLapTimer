//
//  ZOFirstViewController.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/20/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ZOMapViewController : UIViewController 

@property (nonatomic,retain) IBOutlet MKMapView* mapView;
@property (nonatomic,retain) IBOutlet UILabel* currentCoordinateLabel;
@end
