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

@property (nonatomic, retain) NSArray* tracks;

+ (ZOTrackCollection*)instance;

- (NSDictionary*) addTrackNamed:(NSString*)name;
- (void) removeTrackNamed:(NSString*)name;
- (void) removeTrack:(NSDictionary*)track;
- (NSDictionary*) findTrackNamed:(NSString*)name;
- (void ) archiveTrack:(ZOTrack*)track;
- (ZOTrack*) unarchiveTrackFromTrackInfo:(NSDictionary*)trackInfo;

@end
