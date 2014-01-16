//
//  ZOSession.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/13/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZOTrackObject.h"
#import "ZOTrackObjectDelegate.h"


@interface ZOSession : NSObject <ZOTrackObject>

@property (nonatomic, assign)	CLLocationCoordinate2D coordinate;
@property (nonatomic, assign)	MKMapRect boundingMapRect;
@property (nonatomic, assign)	BOOL isSelected;
@property (nonatomic, assign)	id<ZOTrackObjectDelegate> delegate;
@property (nonatomic, retain)	NSArray* locations;
@property (nonatomic, retain)	NSDictionary* sessionInfo;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord boundingMapRect:(MKMapRect)boundingMapRect sessionInfo:(NSDictionary*)sessionInfo;

/// locations
- (void) addLocations:(NSArray*)locations;	// ZOLocations!

/// archiving
- (void) archive;
+ (ZOSession*) unarchiveFromSessionInfo:(NSDictionary*)sessionInfo;
- (void) deleteFromDisk;

+ (NSDictionary*) newSessionInfoAtDate:(NSDate*)date;

@end