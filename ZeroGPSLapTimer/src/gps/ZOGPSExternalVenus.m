//
//  ZOGPSExternalVenus.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/23/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import "ZOGPSExternalVenus.h"
#import <CoreBluetooth/CoreBluetooth.h>

// RBL Service: see: http://redbearlab.com/blemini/ or https://github.com/RedBearLab
#define RBL_SERVICE_UUID                         "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID                         "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID                         "713D0003-503E-4C75-BA94-3148F18D941E"

#define RBL_BLE_FRAMEWORK_VER                    0x0200


@interface ZOGPSExternalVenus () <CBCentralManagerDelegate, CBPeripheralDelegate>  {
	CBCentralManager*	_centralManager;
	NSMutableArray*		_peripherals;	// CBPeripheral
	CBPeripheral*		_connectedPeripheral;
	NSTimer*			_updateTimer;
}

@property (nonatomic,strong) NSTimer* updateTimer;

- (void) updateLoop:(NSTimer*)timer;

@end

@implementation ZOGPSExternalVenus

@synthesize updateTimer = _updateTimer;

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
		_peripherals = [[NSMutableArray alloc] init];
		
		// setup bluetooth connection
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
		
	}
	return self;
}

#pragma mark ZOGPS overrides

- (void)connect {
    
}

#pragma mark Various BLE utility methods

-(NSString *) CBUUIDToString:(CBUUID *) cbuuid {
    NSData *data = cbuuid.data;
    
    if ([data length] == 2)
    {
        const unsigned char *tokenBytes = [data bytes];
        return [NSString stringWithFormat:@"%02x%02x", tokenBytes[0], tokenBytes[1]];
    }
    else if ([data length] == 16)
    {
        NSUUID* nsuuid = [[NSUUID alloc] initWithUUIDBytes:[data bytes]];
        return [nsuuid UUIDString];
    }
    
    return [cbuuid description];
}

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    
    if (memcmp(b1, b2, UUID1.data.length) == 0)
        return 1;
    else
        return 0;
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    
    return nil; //Characteristic not found on this service
}


-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++)
    {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID])
            return s;
    }
    
    return nil; //Service not found on this peripheral
}

-(void) read {
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];
    
    [self readValue:uuid_service characteristicUUID:uuid_char p:_connectedPeripheral];
}

-(void) write:(NSData *)d {
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_RX_UUID];
    
    [self writeValue:uuid_service characteristicUUID:uuid_char p:_connectedPeripheral data:d];
}


-(void) readValue: (CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p
{
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    [p readValueForCharacteristic:characteristic];
}


-(void) writeValue:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}




#pragma mark CBPeripheralDelegate



- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	NSLog(@"didDiscoverServices");
	
	// setup notification on serial TX
//	CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
//    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];
	
	for ( CBService* service in peripheral.services ) {
		[peripheral discoverCharacteristics:nil forService:service];
	}
	
	
//	CBService* service = [self findServiceFromUUID:uuid_service p:peripheral];
//	CBCharacteristic* characteristic = [self findCharacteristicFromUUID:uuid_char service:service];
//	if ( characteristic ) {
//		[peripheral setNotifyValue:YES forCharacteristic:characteristic];
//	}
	
	
//	for ( CBService* service in peripheral.services ) {
//		NSLog(@"Service %@", service);
//		for ( CBCharacteristic* characteristic in service.characteristics ) {
//			NSLog(@"Characteristic %@", characteristic);
//		}
//	}
}


- (void) updateLoop:(NSTimer*)timer {
//	[self read];
//	NSString* mystring = @"hey there from iphone";
//	[self write:[mystring dataUsingEncoding:NSUTF8StringEncoding]];
	
	
}


///### not this is the final part of the initialization
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
//		for ( CBCharacteristic* characteristic in service.characteristics ) {
//			NSLog(@"Characteristic %@", characteristic);
//			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
//		}

	
	// enable read notifications
	CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];

    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:uuid_char service:service];
    
    if (!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:uuid_char],
              [self CBUUIDToString:uuid_service],
              peripheral.identifier.UUIDString);
        
        return;
    }
    
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];

	
	self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLoop:) userInfo:nil repeats:YES];
	
	
}


-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	NSLog(@"didUpdateNotificationStateForCharacteristic");
	
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	
	NSData* value = characteristic.value;
	NSString *newString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    NSLog(@"Receive -> %@",newString);
}



#pragma mark CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	
	_connectedPeripheral = peripheral;
	_connectedPeripheral.delegate = self;
	NSArray* services = [NSArray arrayWithObjects: [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID], [CBUUID UUIDWithString:@RBL_CHAR_RX_UUID], nil];

	[_connectedPeripheral discoverServices:nil];
	
	NSLog(@"didConnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	NSLog(@"didDisconnectPeripheral");
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
	
	[_peripherals addObject:peripheral];

	[_centralManager connectPeripheral:peripheral options:nil];
	
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
			
            [_centralManager scanForPeripheralsWithServices:nil
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
