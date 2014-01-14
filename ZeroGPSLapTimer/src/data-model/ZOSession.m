//
//  ZOSession.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOSession.h"
#import "NSCoder+ZOTrackObject.h"
#import "ZOLocation.h"

@interface ZOSession () {
	NSMutableArray* _locations;	// ZOLocations
}

@end

@implementation ZOSession

@synthesize coordinate;
@synthesize boundingMapRect;
@synthesize isSelected;
@synthesize delegate;
@synthesize locations = _locations;

- (id) init {
	if ( self = [super init] ) {
		self.locations = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if ( self ) {
		self.coordinate = [aDecoder decodeCLLocationCoordinate2DForKey:@"coordinate"];
		self.boundingMapRect = [aDecoder decodeMKMapRectForKey:@"boundingMapRect"];
		self.locations = [aDecoder decodeObjectForKey:@"locations"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	
	[aCoder encodeCLLocationCoordinate2D:self.coordinate forKey:@"coordinate"];
	[aCoder encodeMKMapRect:self.boundingMapRect forKey:@"boundingMapRect"];
	[aCoder encodeObject:self.locations forKey:@"locations"];
}

- (void) addLocations:(NSArray *)locations {
	[_locations addObjectsFromArray:locations];

	if ( [self.delegate respondsToSelector:@selector(zoTrackObject:isDirty:)] ) {
		[self.delegate zoTrackObject:self isDirty:YES];
	}
}

@end
