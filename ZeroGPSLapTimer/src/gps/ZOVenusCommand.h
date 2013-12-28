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
	kSRAM    = 0,    // save to SRAM non permenanent
	kFlash   = 1     // save to SRAM & FLash (permenanent)
} ZOVenusCommandSaveTo;

typedef enum {
	k4800_baud   = 0,
	k9600_baud   = 1,
	k19200_baud  = 2,
	k38400_baud  = 3,
	k57600_baud  = 4,
	k115200_baud = 5
} ZOVenusCommandBaudRate;

typedef enum {
	kOK,
	kError
} ZOVenusCommandResponse;


typedef void* ZOVenusCommandContext;

typedef void (*ZOVenusCommandWriteFunction)(const uint8_t*, const uint16_t);
typedef uint16_t (*ZOVenusCommandReadFunction)(uint8_t*, const uint16_t);
typedef void (*ZOVenusCommandResponseCallBack)(ZOVenusCommandResponse, const uint8_t*, const uint16_t);

extern ZOVenusCommandContext zoVenusCommandCreateContext( ZOVenusCommandWriteFunction writeFunc, ZOVenusCommandReadFunction readFunc );
extern void zoVenusCommandDestroyContext( ZOVenusCommandContext ctx );
extern void zoVenusCommandUpdate( ZOVenusCommandContext ctx );

extern void zoVenusCommandSetBaudRate( ZOVenusCommandContext ctx, ZOVenusCommandBaudRate baudRate, ZOVenusCommandSaveTo saveTo, ZOVenusCommandResponseCallBack cb );
extern void zoVenusCommandGetVersion( ZOVenusCommandContext ctx, ZOVenusCommandResponseCallBack cb );


#endif
