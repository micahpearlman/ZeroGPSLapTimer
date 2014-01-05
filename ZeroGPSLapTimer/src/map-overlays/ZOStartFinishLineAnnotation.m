//
//  ZOStartFinishLineAnnotation.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOStartFinishLineAnnotation.h"

@interface ZOStartFinishLineAnnotation () {
	CLLocationCoordinate2D	_coordinate;
}

@end

@implementation ZOStartFinishLineAnnotation

@synthesize coordinate = _coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        _coordinate = coord;
    }
    return self;
}


@end
