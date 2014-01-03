//
//  ZOParseNMEA.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/30/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#ifndef ZeroGPSLapTimer_ZOParseNMEA_h
#define ZeroGPSLapTimer_ZOParseNMEA_h

#include "ZOCircularBuffer.h"
#include <stdlib.h>

// see: http://aprs.gids.nl/nmea/
typedef enum {
	ZOParseNMEAResultType_Error = 0,
	ZOParseNMEAResultType_GPGAA = 1 << 0 // Global Positioning System Fix Data
} ZOParseNMEAResultType;

typedef struct {
	ZOParseNMEAResultType	type;
} ZOParseNMEAResult;


//	GPGAA		: GPS fixed data identifier
//	hhmmss.ss	: Coordinated Universal Time (UTC), also known as GMT
//	ddmm.mmmm,n	: Latitude in degrees, minutes and cardinal sign
//	dddmm.mmmm,e	: Longitude in degrees, minutes and cardinal sign
//	q		: Quality of fix.  1 = there is a fix
//	ss		: Number of satellites being used
//	y.y		: Horizontal dilution of precision
//	a.a,M		: GPS antenna altitude in meters
//	g.g,M		: geoidal separation in meters
//	t.t		: Age of the defferential correction data
//	iiii		: Deferential station's ID
//	*CC		: checksum for the sentence
typedef struct {
	ZOParseNMEAResult	header;
	char				utcString[11];
	uint32_t			hour;
	uint32_t			minute;
	uint32_t			seconds;
	float				lattitude;
	char				lattitudeCardinal;	// N or S
	float				longitude;
	char				longitudeCardinal;	// E or W
	uint8_t				quality;			// GPS quality indicator (0=invalid; 1=GPS fix; 2=Diff. GPS fix)
	uint8_t				satellites;			// Number of satellites being used
	float				horizontalPrecision;// Horizontal dilution of precision
	float				altitude;
} ZOParseNMEAResultGPGAA;

typedef void* ZOParseNMEAContext;

typedef void (*ZOParseNMEAOnReceivedSentenceCallback)( ZOParseNMEAContext, ZOParseNMEAResult* );

ZOParseNMEAContext zoParseNMEACreateContext( ZOCircularBuffer circularBuffer, uint32_t sentenceTypes, ZOParseNMEAOnReceivedSentenceCallback callback );
void zoParseNMEADestroyContext( ZOParseNMEAContext ctx );
void zoParseNMEAUpdate( ZOParseNMEAContext ctx );


#endif
