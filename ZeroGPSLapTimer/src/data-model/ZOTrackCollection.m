//
//  ZOTrackCollection.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/11/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOTrackCollection.h"
#import "NSDictionary+MapKit.h"

@interface ZOTrackCollection () {
	NSMutableArray* _trackInfos;
//	ZOTrack*		_currentTrack;
}

@end

@implementation ZOTrackCollection

@dynamic trackInfos;
//@dynamic currentTrack;

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
	_trackInfos = [NSMutableArray arrayWithContentsOfFile:[self path]];
	if ( _trackInfos == nil ) {	// need to create a tracks.sav
		_trackInfos = [[NSMutableArray alloc] init];
		[_trackInfos writeToFile:@"tracks.sav" atomically:YES];
	}
}

- (void) save {
	[_trackInfos writeToFile:[self path] atomically:YES];
}

- (NSDictionary*) createTrackInfoNamed:(NSString*)name withBoundingMapRect:(MKMapRect)boundingMapRect {
	NSDictionary* track = [self findTrackInfoNamed:name];
	
	if ( track == nil ) {
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* documentDirectoryPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
		NSString* trackArchivePath = [documentDirectoryPath stringByAppendingPathComponent:[name stringByAppendingString:@".track"]];

		track = @{	@"type" : @"track",
					@"name" : name,
					@"archive-path" : trackArchivePath,
					@"bounding-map-rect" : [NSDictionary dictionaryFromMKMapRect:boundingMapRect]
					};
		
		[_trackInfos addObject:track];
		
		[self save];

	}

	return track;
}

- (void) removeTrackInfoNamed:(NSString*)name {
	NSDictionary* track = [self findTrackInfoNamed:name];
	[self removeTrackInfo:track];
}

- (void) removeTrackInfo:(NSDictionary*)trackInfo {
	[_trackInfos removeObject:trackInfo];
	[self save];
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:[trackInfo objectForKey:@"archive-path"] error:&error];
	// TODO: check for error
	

}

- (NSDictionary*) findTrackInfoNamed:(NSString*)name {
	for ( NSDictionary* track in _trackInfos ) {
		if ( [name isEqualToString:[track objectForKey:@"name"]]) {
			return track;
		}
	}
	return nil;
}


- (NSArray*) trackInfos {
	if ( _trackInfos == nil ) {
		[self load];
	}
	return _trackInfos;
}

// TODO: get closest tracks
- (NSDictionary*) trackAtCoordinate:(CLLocationCoordinate2D)coordinate {
	MKMapPoint mapPoint = MKMapPointForCoordinate( coordinate );
	for ( NSDictionary* trackInfo in _trackInfos ) {
		NSDictionary* boundingMapRectDictionary = [trackInfo objectForKey:@"bounding-map-rect"];
		MKMapRect mapRect = [boundingMapRectDictionary MKMapRect];
		if ( MKMapRectContainsPoint( mapRect, mapPoint ) ) {
			return trackInfo;
		}
		
	}
	return nil;
}

@end
