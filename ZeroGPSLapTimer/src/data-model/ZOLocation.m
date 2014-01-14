//
//  ZOLocation.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOLocation.h"

@implementation ZOLocation

- (id) initWithCLLocation:(CLLocation*)location {
	self = [location copy];
	if ( self  ) {
		
	}
	
	return self;
}

+ (NSArray*) ZOLocationArrayFromCLLocationArray:(NSArray*)locations {
	NSMutableArray* zolocations = [[NSMutableArray alloc] init];
	for ( CLLocation* location in locations ) {
		ZOLocation* zolocation = [[ZOLocation alloc] initWithCLLocation:location];
		[zolocations addObject:zolocation];
	}
	return zolocations;
}

@end
