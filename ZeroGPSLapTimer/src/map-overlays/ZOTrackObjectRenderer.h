//
//  ZOTrackObjectRenderer.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/9/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol ZOTrackObjectRenderer <NSObject>
@required
@property (nonatomic, assign) MKOverlayRenderer* parent;
@property (nonatomic, assign) BOOL isDirty;

@end
