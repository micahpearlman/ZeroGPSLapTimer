//
//  ZOGPSExternalVenus.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/23/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import "ZOGPSExternalVenus.h"
#import "ZOBluetooth.h"
#include "ZOVenusCommand.h"
#include "ZOCircularBuffer.h"
#include "ZOParseNMEA.h"
#import <CoreLocation/CoreLocation.h>




@interface ZOGPSExternalVenus () <ZOBluetoothDelegate> {
	ZOBluetooth*			_bluetooth;
	ZOVenusCommandContext	_venusCmdCtx;
	ZOCircularBuffer		_circularBuffer;
	ZOParseNMEAContext		_nmeaParser;
}

@property (nonatomic) ZOCircularBuffer circularBuffer;
@property (nonatomic,retain) ZOBluetooth* bluetooth;


@end


void vc_writeFunction( const uint8_t* data, const uint16_t length ) {
	[[ZOGPSExternalVenus instance].bluetooth write:[NSData dataWithBytes:data length:length] ];
}
uint16_t vc_readFunction( uint8_t* buffer, const uint16_t length ) {

	uint32_t cbLength = zoCircularBufferGetSize( [ZOGPSExternalVenus instance].circularBuffer );
	uint32_t finalReadLength = length > cbLength ? cbLength : length;	// read either requested read length or the total length of whats in the circular buffer
	zoCircularBufferRead( [ZOGPSExternalVenus instance].circularBuffer, buffer, &finalReadLength );
	return finalReadLength;
	
}
void vc_responseCallBack( ZOVenusCommandResponse response, const uint8_t* data, const uint16_t length ) {
	NSLog(@"vc_responseCallBack");
}

void parseNMEACallback( ZOParseNMEAContext ctx, ZOParseNMEAResult* result ) {
	//NSLog(@"parseNMEACallback");
	if ( result->type == ZOParseNMEAResultType_GPGAA ) {
		ZOParseNMEAResultGPGAA* GPGAA = (ZOParseNMEAResultGPGAA*)result;
		//NSLog( @"lattitude = %f longitude = %f altitude = %f", GPGAA->lattitude, GPGAA->longitude, GPGAA->altitude );
		
		if ( [[ZOGPSExternalVenus instance].delegate respondsToSelector:@selector(zoGPS:didUpdateLocations:)] ) {
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
			[[ZOGPSExternalVenus instance].delegate zoGPS:[ZOGPSExternalVenus instance]
									   didUpdateLocations:locationArray];

		}
	}
}



@implementation ZOGPSExternalVenus

@synthesize circularBuffer	= _circularBuffer;
@synthesize bluetooth		= _bluetooth;

+ (ZOGPSExternalVenus*)instance {
	static ZOGPSExternalVenus* instance = nil;
	@synchronized(self) {
		if ( instance == nil ) {
			instance = [[self alloc] init];
		}
	}
	
	return instance;
}

- (id) init {
	if ( self = [super init]) {
		_bluetooth = [[ZOBluetooth alloc] init];
		_bluetooth.delegate = self;
		
		// setup circular buffer
		_circularBuffer = zoCircularBufferInit( 256 );
		
		// setup venus command context
		_venusCmdCtx = zoVenusCommandCreateContext( vc_writeFunction, vc_readFunction );
		
		// setup nmea parser
		_nmeaParser = zoParseNMEACreateContext( _circularBuffer, ZOParseNMEAResultType_GPGAA, parseNMEACallback );
		
	}
	return self;
}

#pragma mark ZOGPS overrides
- (void)connect {
    
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
