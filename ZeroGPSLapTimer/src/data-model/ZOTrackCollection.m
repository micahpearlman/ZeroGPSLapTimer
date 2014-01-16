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
	ZOTrack*		_currentTrack;
}

@end

@implementation ZOTrackCollection

@synthesize tracks = _tracks;
@dynamic currentTrack;

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

- (NSDictionary*) addTrackNamed:(NSString*)name {
	NSDictionary* track = [self findTrackNamed:name];
	
	if ( track == nil ) {
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* documentDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
		NSString* trackArchivePath = [documentDirectoryPath stringByAppendingPathComponent:[name stringByAppendingString:@".track"]];

		track = @{	@"type" : @"track",
					@"name" : name,
					@"archive-path" : trackArchivePath
					};
		
		[_tracks addObject:track];
		
		[self save];

	}

	return track;
}

- (void) removeTrackNamed:(NSString*)name {
	NSDictionary* track = [self findTrackNamed:name];
	[self removeTrack:track];
}

- (void) removeTrack:(NSDictionary*)trackInfo {
	[_tracks removeObject:trackInfo];
	[self save];
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:[trackInfo objectForKey:@"archive-path"] error:&error];
	// TODO: check for error
	
	if ( self.currentTrackInfo == trackInfo ) {
		self.currentTrackInfo = nil;
		self.currentTrack = nil;
	}

}

- (NSDictionary*) findTrackNamed:(NSString*)name {
	for ( NSDictionary* track in _tracks ) {
		if ( [name isEqualToString:[track objectForKey:@"name"]]) {
			return track;
		}
	}
	return nil;
}


- (ZOTrack*) currentTrack {
	if ( _currentTrack == nil && self.currentTrackInfo != nil ) {
		// automatically unarchive the current track from the current track info
		_currentTrack = [ZOTrack unarchiveFromTrackInfo:self.currentTrackInfo];
	}
	return _currentTrack;
}

-(void) setCurrentTrack:(ZOTrack *)currentTrack {
	_currentTrack = currentTrack;
}

@end
