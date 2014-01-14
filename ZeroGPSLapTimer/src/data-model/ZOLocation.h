//
//  ZOLocation.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface ZOLocation : CLLocation
- (id) initWithCLLocation:(CLLocation*)location;

+ (NSArray*) ZOLocationArrayFromCLLocationArray:(NSArray*)locations;

@end
