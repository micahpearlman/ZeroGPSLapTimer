//
//  ZOVenusCommand.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/24/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#ifndef ZeroGPSLapTimer_ZOVenusCommand_h
#define ZeroGPSLapTimer_ZOVenusCommand_h

// see: http://dlnmh9ip6v2uc.cloudfront.net/datasheets/Sensors/GPS/Venus/638/doc/Venus638FLPx_DS_v07.pdf

#include <stdio.h>
#include <stdint.h>

typedef enum {
	ZOVenusCommandSaveTo_SRAM    = 0,    // save to SRAM non permenanent
	ZOVenusCommandSaveTo_Flash   = 1     // save to SRAM & FLash (permenanent)
} ZOVenusCommandSaveTo;

typedef enum {
	ZOVenusCommandBaudRate_4800   = 0,
	ZOVenusCommandBaudRate_9600   = 1,
	ZOVenusCommandBaudRate_19200  = 2,
	ZOVenusCommandBaudRate_38400  = 3,
	ZOVenusCommandBaudRate_57600  = 4,
	ZOVenusCommandBaudRate_115200 = 5
} ZOVenusCommandBaudRate;

typedef enum {
	ZOVenusCommandResponse_OK,
	ZOVenusCommandResponse_Error
} ZOVenusCommandResponse;


typedef void* ZOVenusCommandContext;

typedef void (*ZOVenusCommandWriteFunction)(ZOVenusCommandContext, const uint8_t*, const uint16_t);
typedef uint16_t (*ZOVenusCommandReadFunction)(ZOVenusCommandContext, uint8_t*, const uint16_t);
typedef void (*ZOVenusCommandResponseCallBack)(ZOVenusCommandContext, ZOVenusCommandResponse, const uint8_t*, const uint16_t);

extern ZOVenusCommandContext zoVenusCommandCreateContext( ZOVenusCommandWriteFunction writeFunc, ZOVenusCommandReadFunction readFunc, void* userData );
extern void zoVenusCommandDestroyContext( ZOVenusCommandContext ctx );
extern void zoVenusCommandUpdate( ZOVenusCommandContext ctx );

extern void zoVenusCommandSetBaudRate( ZOVenusCommandContext ctx, ZOVenusCommandBaudRate baudRate, ZOVenusCommandSaveTo saveTo, ZOVenusCommandResponseCallBack cb );
extern void zoVenusCommandGetVersion( ZOVenusCommandContext ctx, ZOVenusCommandResponseCallBack cb );

extern void* zoVenusCommandGetUserData( ZOVenusCommandContext ctx );

#endif
