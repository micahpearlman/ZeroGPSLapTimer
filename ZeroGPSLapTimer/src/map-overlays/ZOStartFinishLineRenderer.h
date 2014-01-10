//
//  ZOStartFinishLineAnnotationView.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ZOTrackObjectRenderer.h"

@interface ZOStartFinishLineRenderer : MKOverlayRenderer <ZOTrackObjectRenderer>

@property (nonatomic, assign) MKOverlayRenderer* parent;
@property (nonatomic, assign) BOOL isDirty;

@end
