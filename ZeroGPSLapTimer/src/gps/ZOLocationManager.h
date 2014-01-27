//
//  ZOGPS.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/23/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZOLocationManager;

@protocol ZOLocationManagerDelegate <NSObject>
@optional
- (void)locationManager:(ZOLocationManager *)manager didUpdateLocations:(NSArray *)locations;
// TODO: connection management
@end

@interface ZOLocationManager : NSObject 

@property (nonatomic, assign) id<ZOLocationManagerDelegate>	delegate;

- (void) startUpdatingLocation;
- (void) stopUpdatingLocaion;


@end

