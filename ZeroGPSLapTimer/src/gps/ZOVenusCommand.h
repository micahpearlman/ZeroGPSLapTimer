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
} venusCommand_SaveTo;

typedef enum {
	k4800_baud   = 0,
	k9600_baud   = 1,
	k19200_baud  = 2,
	k38400_baud  = 3,
	k57600_baud  = 4,
	k115200_baud = 5
} venusCommand_BaudRate;

typedef enum {
	kOK,
	kError
} venusCommand_Response;


typedef void* venusCommand_Context;

typedef void (*venusCommand_writeFunction)(const uint8_t*, const uint16_t);
typedef uint16_t (*venusCommand_readFunction)(uint8_t*, const uint16_t);
typedef void (*venusCommand_responseCallBack)(venusCommand_Response, const uint8_t*, const uint16_t);

extern venusCommand_Context venusCommand_createContext( venusCommand_writeFunction writeFunc, venusCommand_readFunction readFunc );
extern void venusCommand_DestroyContext( venusCommand_Context ctx );
extern void venusCommand_Update( venusCommand_Context ctx );

extern void venusCommand_setBaudRate( venusCommand_Context ctx, venusCommand_BaudRate baudRate, venusCommand_SaveTo saveTo, venusCommand_responseCallBack cb );
extern void venusCommand_getVersion( venusCommand_Context ctx, venusCommand_responseCallBack cb );


#endif
