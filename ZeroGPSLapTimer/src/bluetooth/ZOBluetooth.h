//
//  ZOBluetooth.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/29/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZOBluetoothDelegate;
@interface ZOBluetooth : NSObject

@property (nonatomic,assign) id<ZOBluetoothDelegate> delegate;

-(void) write:(NSData *)d;

@end


@protocol ZOBluetoothDelegate <NSObject>
@optional
-(void) zoBluetoothDidConnect:(ZOBluetooth*)ble;
-(void) zoBluetoothDidDisconnect:(ZOBluetooth*)ble;
-(void) zoBluetoothDidReceiveData:(uint8_t*)data length:(uint32_t)length;
@required
@end
