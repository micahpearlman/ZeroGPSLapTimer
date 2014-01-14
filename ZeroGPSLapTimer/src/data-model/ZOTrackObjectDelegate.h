//
//  ZOTrackObjectDelegate.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/9/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZOTrackObject.h"

@protocol ZOTrackObjectDelegate <NSObject>
@optional
- (void) zoTrackObject:(id<ZOTrackObject>)trackObject isSelected:(BOOL)isSelected;
- (void) zoTrackObject:(id<ZOTrackObject>)trackObject movedCoordinate:(CLLocationCoordinate2D)coord;
- (void) zoTrackObject:(id<ZOTrackObject>)trackObject isDirty:(BOOL)isDirty;

@end
