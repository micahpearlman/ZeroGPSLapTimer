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






@interface ZOGPSExternalVenus () <ZOBluetoothDelegate> {
	ZOBluetooth*			_bluetooth;
	ZOVenusCommandContext	_venusCmdCtx;
	ZOCircularBuffer		_circularBuffer;
}

@property (nonatomic) ZOCircularBuffer circularBuffer;
@property (nonatomic,retain) ZOBluetooth* bluetooth;


@end


void vc_writeFunction( const uint8_t* data, const uint16_t length ) {
	[[ZOGPSExternalVenus instance].bluetooth write:[NSData dataWithBytes:data length:length] ];
}
uint16_t vc_readFunction( uint8_t* buffer, const uint16_t length ) {

	uint32_t cbLength = zoCircularBufferGetCount( [ZOGPSExternalVenus instance].circularBuffer );
	uint16_t finalReadLength = length > cbLength ? cbLength : length;	// read either requested read length or the total length of whats in the circular buffer
	zoCircularBufferRead( [ZOGPSExternalVenus instance].circularBuffer, buffer, finalReadLength );
	return finalReadLength;
	
}
void vc_responseCallBack(ZOVenusCommandResponse response, const uint8_t* data, const uint16_t length ) {
	NSLog(@"vc_responseCallBack");
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
		
	}
	return self;
}

#pragma mark ZOGPS overrides
- (void)connect {
    
}

#pragma mark ZOBLuetoothDelegate
-(void) zoBluetoothDidConnect:(ZOBluetooth*)ble {
	// test get version
	zoVenusCommandGetVersion( _venusCmdCtx, vc_responseCallBack );
}

-(void) zoBluetoothDidDisconnect:(ZOBluetooth*)ble {
	
}

-(void) zoBluetoothDidReceiveData:(uint8_t*)data length:(uint32_t)length {
	zoCircularBufferWrite( _circularBuffer, data, length );
	zoVenusCommandUpdate( _venusCmdCtx );

}




@end
