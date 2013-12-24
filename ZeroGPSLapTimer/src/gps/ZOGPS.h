//
//  ZOGPS.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/23/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZOGPS;
@protocol ZOGPSDelegate
@optional
-(void) gpsDidConnect:(ZOGPS*)gps;
-(void) gpsDidDisconnect:(ZOGPS*)gps;
-(void) gpsDidUpdate:(ZOGPS*)gps coordinates:(NSArray*)coordinates;
@end

@interface ZOGPS : NSObject 

@property (nonatomic, assign) id<ZOGPSDelegate>	delegate;

- (void) connect;

@end

