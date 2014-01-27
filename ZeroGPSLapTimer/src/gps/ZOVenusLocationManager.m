//
//  ZOGPSExternalVenus.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/23/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import "ZOVenusLocationManager.h"
#import "ZOBluetooth.h"
#include "ZOVenusCommand.h"
#include "ZOCircularBuffer.h"
#include "ZOParseNMEA.h"
#import <CoreLocation/CoreLocation.h>


@interface ZOVenusLocationManager () <ZOBluetoothDelegate> {
	ZOBluetooth*			_bluetooth;
	ZOVenusCommandContext	_venusCmdCtx;
	ZOCircularBuffer		_circularBuffer;
	ZOParseNMEAContext		_nmeaParser;
}

@property (nonatomic) ZOCircularBuffer circularBuffer;
@property (nonatomic,retain) ZOBluetooth* bluetooth;


@end



void vc_writeFunction( ZOVenusCommandContext ctx, const uint8_t* data, const uint16_t length ) {
	ZOVenusLocationManager* locationManager = (__bridge ZOVenusLocationManager*)zoVenusCommandGetUserData( ctx );
	[locationManager.bluetooth write:[NSData dataWithBytes:data length:length] ];
}
uint16_t vc_readFunction( ZOVenusCommandContext ctx, uint8_t* buffer, const uint16_t length ) {
	ZOVenusLocationManager* locationManager = (__bridge ZOVenusLocationManager*)zoVenusCommandGetUserData( ctx );
	uint32_t cbLength = zoCircularBufferGetSize( locationManager.circularBuffer );
	uint32_t finalReadLength = length > cbLength ? cbLength : length;	// read either requested read length or the total length of whats in the circular buffer
	zoCircularBufferRead( locationManager.circularBuffer, buffer, &finalReadLength );
	return finalReadLength;
	
}
void vc_responseCallBack( ZOVenusCommandContext ctx, ZOVenusCommandResponse response, const uint8_t* data, const uint16_t length ) {
	ZOVenusLocationManager* locationManager = (__bridge ZOVenusLocationManager*)zoVenusCommandGetUserData( ctx );
	NSLog(@"vc_responseCallBack");
}

void parseNMEACallback( ZOParseNMEAContext ctx, ZOParseNMEAResult* result ) {
	ZOVenusLocationManager* locationManager = (__bridge ZOVenusLocationManager*)zoParseNMEAGetUserData( ctx );
	//NSLog(@"parseNMEACallback");
	if ( result->type == ZOParseNMEAResultType_GPGAA ) {
		ZOParseNMEAResultGPGAA* GPGAA = (ZOParseNMEAResultGPGAA*)result;
		//NSLog( @"lattitude = %f longitude = %f altitude = %f", GPGAA->lattitude, GPGAA->longitude, GPGAA->altitude );
		
		if ( [locationManager.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)] ) {
			CLLocationCoordinate2D coordinate;
			coordinate.latitude = GPGAA->lattitude;
			coordinate.longitude = GPGAA->longitude;
			
			// generate date from UTC date string
			// see: http://stackoverflow.com/questions/15603730/time-formats-for-nsdate
			NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"HHmmss.SSS"];
			[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
			NSString* utcString = [NSString stringWithUTF8String:GPGAA->utcString];
			NSError* error = nil;
			NSDate* date = nil;
			[dateFormatter getObjectValue:&date forString:utcString range:nil error:&error];

			
			//NSDate* date = [dateFormatter dateFromString:utcString];
			
			CLLocation* location = [[CLLocation alloc] initWithCoordinate:coordinate
																 altitude:GPGAA->altitude
													   horizontalAccuracy:GPGAA->horizontalPrecision
														 verticalAccuracy:GPGAA->horizontalPrecision
																timestamp:date];
			NSArray* locationArray = [[NSArray alloc] initWithObjects:location, nil];
			
			[locationManager.delegate locationManager:locationManager
								   didUpdateLocations:locationArray];

		}
	}
}




@implementation ZOVenusLocationManager

@synthesize circularBuffer	= _circularBuffer;
@synthesize bluetooth		= _bluetooth;

//+ (ZOGPSExternalVenus*)instance {
//	static ZOGPSExternalVenus* instance = nil;
//	@synchronized(self) {
//		if ( instance == nil ) {
//			instance = [[self alloc] init];
//		}
//	}
//	
//	return instance;
//}

- (id) init {
	if ( self = [super init]) {
		_bluetooth = [[ZOBluetooth alloc] init];
		_bluetooth.delegate = self;
		
		// setup circular buffer
		_circularBuffer = zoCircularBufferInit( 256 );
		
		// setup venus command context
		_venusCmdCtx = zoVenusCommandCreateContext( vc_writeFunction, vc_readFunction, (__bridge void *)(self) );
		
		// setup nmea parser
		_nmeaParser = zoParseNMEACreateContext( _circularBuffer, ZOParseNMEAResultType_GPGAA, parseNMEACallback, (__bridge void *)(self) );
		
	}
	return self;
}

- (void) dealloc {
	zoCircularBufferDestroy( _circularBuffer );
	zoVenusCommandDestroyContext( _venusCmdCtx );
	zoParseNMEADestroyContext( _nmeaParser );
}

- (void) startUpdatingLocation {
	// BUGBUG should just get rid of ZOBluetooth and implement here
	// the last peripheral is not really guaranteed to be the peripheral we want
	if ( [self.bluetooth.peripherals count] ) {
		[self.bluetooth connectPeripheral:[self.bluetooth.peripherals lastObject]];
	}
	
}
- (void) stopUpdatingLocaion {
	// BUGBUG should just get rid of ZOBluetooth and implement here
	// the last peripheral is not really guaranteed to be the peripheral we want

	if ( [self.bluetooth.peripherals count] ) {
		[self.bluetooth disconnectPeripheral:[self.bluetooth.peripherals lastObject]];
	}
	
}



#pragma mark ZOBLuetoothDelegate
-(void) zoBluetoothDidConnect:(ZOBluetooth*)ble {
	// test get version
	//zoVenusCommandGetVersion( _venusCmdCtx, vc_responseCallBack );
}

-(void) zoBluetoothDidDisconnect:(ZOBluetooth*)ble {
	
}

-(void) zoBluetoothDidReceiveData:(uint8_t*)data length:(uint32_t)length {
	uint32_t writeLength = length;
	zoCircularBufferWrite( _circularBuffer, data, &writeLength );
	assert( writeLength == length );	// BUGBUG: we have recieved more data then we can write, so we need to increase the size of the circular buffer
	//zoVenusCommandUpdate( _venusCmdCtx );
	zoParseNMEAUpdate( _nmeaParser );

}






@end
