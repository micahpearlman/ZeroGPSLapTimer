//
//  ZOStartFinishLineAnnotation.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/5/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol ZOStartFinishLineOverlayDelegate;

@interface ZOStartFinishLineOverlay : NSObject <MKOverlay>

@property (nonatomic, assign)	CLLocationCoordinate2D coordinate;
@property (nonatomic, assign)	MKMapRect boundingMapRect;
@property (nonatomic, assign)	BOOL isSelected;
@property (nonatomic, readonly) CLLocationCoordinate2D* lineEnds;
@property (nonatomic, assign)	double angle;	// radians
@property (nonatomic, assign) id<ZOStartFinishLineOverlayDelegate> delegate;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord;

@end

@protocol ZOStartFinishLineOverlayDelegate <NSObject>

- (void)zoStartFinishLineOverlay:(ZOStartFinishLineOverlay*)startFinishOverlay isSelected:(BOOL)isSelected;
- (void)zoStartFinishLineOverlay:(ZOStartFinishLineOverlay*)startFinishOverlay movedTo:(CLLocationCoordinate2D)coordinate;
- (void)zoStartFinishLineOverlay:(ZOStartFinishLineOverlay*)startFinishOverlay rotateTo:(double)angle;

@end

