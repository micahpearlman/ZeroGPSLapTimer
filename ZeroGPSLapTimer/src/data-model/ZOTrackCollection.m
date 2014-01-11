//
//  ZOTrackCollection.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/11/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOTrackCollection.h"

@interface ZOTrackCollection () {
	NSMutableArray* _tracks;
}

@end

@implementation ZOTrackCollection

@synthesize tracks = _tracks;

// singleton. see: http://www.galloway.me.uk/tutorials/singleton-classes/
+ (ZOTrackCollection*)instance {
	static ZOTrackCollection* instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	return instance;
}

- (id) init {
	if ( self = [super init] ) {
		[self load];
	}
	return self;
}

- (NSString*) path {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	NSString* tracksFilePath = [documentDirectoryPath stringByAppendingPathComponent:@"tracks.sav"];
	return tracksFilePath;
}

- (void) load {
	_tracks = [NSMutableArray arrayWithContentsOfFile:[self path]];
	if ( _tracks == nil ) {	// need to create a tracks.sav
		_tracks = [[NSMutableArray alloc] init];
		[_tracks writeToFile:@"tracks.sav" atomically:YES];
	}
}

- (void) save {
	[_tracks writeToFile:[self path] atomically:YES];
}

- (NSDictionary*) addTrack:(NSString*)name {
	NSDictionary* track = [self findTrack:name];
	
	if ( track == nil ) {
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* documentDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
		NSString* trackConfigurationPath = [documentDirectoryPath stringByAppendingPathComponent:[name stringByAppendingString:@".cfg"]];

		track = @{	@"name" : name,
					@"configuration-path" : trackConfigurationPath,
					@"sessions" : [[NSArray alloc] init]
					};
		
		[_tracks addObject:track];

	}
	
	[self save];

	return track;
}

- (void) deleteTrack:(NSString*)name {
	NSDictionary* track = [self findTrack:name];
	[_tracks removeObject:track];
	[self save];
}
- (NSDictionary*) findTrack:(NSString*)name {
	for ( NSDictionary* track in _tracks ) {
		if ( [name isEqualToString:[track objectForKey:@"name"]]) {
			return track;
		}
	}
	return nil;
}

@end
