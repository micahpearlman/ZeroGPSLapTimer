//
//  ZOGPSExternalVenus.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/23/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import "ZOVenusLocationManager.h"
#include "ZOVenusCommand.h"
#include "ZOCircularBuffer.h"
#include "ZOParseNMEA.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// RBL Service: see: http://redbearlab.com/blemini/ or https://github.com/RedBearLab
#define RBL_SERVICE_UUID                         "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID                         "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID                         "713D0003-503E-4C75-BA94-3148F18D941E"
#define RBL_BLE_FRAMEWORK_VER                    0x0200


@interface ZOVenusLocationManager () <CBCentralManagerDelegate, CBPeripheralDelegate> {
	CBCentralManager*		_centralManager;
	CBPeripheral*			_peripheral;
	CBService*				_service;
	CBCharacteristic*		_tx;
	CBCharacteristic*		_rx;
	BOOL					_isUpdating;
	
	ZOVenusCommandContext	_venusCmdCtx;
	ZOCircularBuffer		_circularBuffer;
	ZOParseNMEAContext		_nmeaParser;
}

@property (nonatomic) ZOCircularBuffer circularBuffer;


@end



void vc_writeFunction( ZOVenusCommandContext ctx, const uint8_t* data, const uint16_t length ) {
	ZOVenusLocationManager* locationManager = (__bridge ZOVenusLocationManager*)zoVenusCommandGetUserData( ctx );
	assert( false );	// TODO: bluetooth write below
//	[locationManager.bluetooth write:[NSData dataWithBytes:data length:length] ];
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
//@synthesize bluetooth		= _bluetooth;


- (id) init {
	if ( self = [super init]) {
		
		_isUpdating = NO;
		// setup bluetooth connection
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self
															   queue:dispatch_get_main_queue()];

		
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
	if ( _peripheral ) {
		[_centralManager connectPeripheral:_peripheral options:nil];
	}
	_isUpdating = YES;

	
}
- (void) stopUpdatingLocaion {
	if ( _peripheral ) {
		[_centralManager cancelPeripheralConnection:_peripheral];
	}
	_isUpdating = NO;
}



#pragma mark CBPeripheralDelegate



- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	NSLog(@"didDiscoverServices");
	
	// now search for characteristics
	for ( CBService* service in peripheral.services ) {
		NSArray* characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@RBL_CHAR_TX_UUID],
									[CBUUID UUIDWithString:@RBL_CHAR_RX_UUID],
									nil];
		[peripheral discoverCharacteristics:characteristics forService:service];
	}
}



///### NOTE: this is the final part of the BlueToth initialization.  Can now start reading and writing...
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	
	
	// enable read notifications
	CBUUID* tx_characteristic = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];
	CBUUID* rx_characteristic = [CBUUID UUIDWithString:@RBL_CHAR_RX_UUID];

	for ( CBCharacteristic* characteristic in service.characteristics) {
		if ( [tx_characteristic isEqual:characteristic.UUID] ) {
			_tx = characteristic;
		}
		
		if ( [rx_characteristic isEqual:characteristic.UUID] ) {
			_rx = characteristic;
		}

	}
	
    
	// this starts up didUpdateValueForCharacteristic below
    [peripheral setNotifyValue:YES forCharacteristic:_rx];
	[peripheral setNotifyValue:YES forCharacteristic:_tx];
		
}


-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	NSLog(@"didUpdateNotificationStateForCharacteristic");
	
}

///### NOTE: this is where incoming data
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	

	uint32_t writeLength = (uint32_t)[characteristic.value length];
	const uint8_t* data = [characteristic.value bytes];
	zoCircularBufferWrite( _circularBuffer, data, &writeLength );
	assert( writeLength == [characteristic.value length] );	// BUGBUG: we have recieved more data then we can write, so we need to increase the size of the circular buffer
	zoParseNMEAUpdate( _nmeaParser );

//	NSData* value = characteristic.value;
//	NSString *newString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
//    NSLog(@"Receive -> %@",newString);
}


#pragma mark CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	
	NSArray* services = [NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]];
	[_peripheral discoverServices:services];
	
	NSLog(@"didConnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	NSLog(@"didDisconnectPeripheral");
	_peripheral = nil;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	NSLog(@"didFailToConnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	
	NSLog(@"------------------------------------");
	NSLog(@"Peripheral Info :");
	
	if (peripheral.identifier != NULL)
		NSLog(@"UUID : %@", peripheral.identifier.UUIDString);
	else
		NSLog(@"UUID : NULL");
	
	NSLog(@"Name : %@", peripheral.name);
	NSLog(@"-------------------------------------");
	
	_peripheral = peripheral;
	_peripheral.delegate = self;
	
//	//BUGBUG: have the application do this or just get rid of zobluetooth?
	if ( _isUpdating == YES ) {
		[_centralManager connectPeripheral:peripheral options:nil];
	}

	
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    static CBCentralManagerState previousState = -1;
    
    switch ([_centralManager state]) {
        case CBCentralManagerStatePoweredOff:
        {
            break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            break;
        }
            
        case CBCentralManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
			// only get peripherals with the service we are interested in
			NSArray* services = [NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]];
            [_centralManager scanForPeripheralsWithServices:services
													options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
			
			
            break;
        }
            
        case CBCentralManagerStateResetting:
        {
            break;
        }
			
		case CBCentralManagerStateUnsupported:
		{
			break;
		}
    }
    
    previousState = [_centralManager state];
}







@end
