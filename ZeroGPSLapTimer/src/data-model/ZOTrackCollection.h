//
//  ZOTrackCollection.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/11/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZOTrack.h"

@interface ZOTrackCollection : NSObject

@property (nonatomic, readonly) NSArray* trackInfos;	// NSDictionary of trackInfo
@property (nonatomic, retain) NSDictionary* currentTrackInfo;
@property (nonatomic, retain) ZOTrack* currentTrack;

+ (ZOTrackCollection*)instance;

/// track info management
- (NSDictionary*) createTrackInfoNamed:(NSString*)name withBoundingMapRect:(MKMapRect)boundingMapRect;
- (void) removeTrackInfoNamed:(NSString*)name;
- (void) removeTrackInfo:(NSDictionary*)trackInfo;
- (NSDictionary*) findTrackInfoNamed:(NSString*)name;

/// query
- (NSDictionary*) trackAtCoordinate:(CLLocationCoordinate2D)coordinate;

@end
