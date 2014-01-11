//
//  ZOTrackCollection.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/11/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZOTrackCollection : NSObject

@property (nonatomic, retain) NSArray* tracks;

+ (ZOTrackCollection*)instance;

- (NSDictionary*) addTrack:(NSString*)name;
- (void) deleteTrack:(NSString*)name;
- (NSDictionary*) findTrack:(NSString*)name;

@end
