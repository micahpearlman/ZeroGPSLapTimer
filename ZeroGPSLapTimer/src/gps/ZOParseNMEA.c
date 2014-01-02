//
//  ZOParseNMEA.c
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/30/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ZOParseNMEA.h"

#define CR	0x0D
#define LF	0x0A
#define CR_LF "\r\n"
#define FIELD_BUFFER_SIZE	32


typedef enum {
	kUnknown = 0,
	kSearchForSentenceType,	// search for $GPGGA,
	kGetFields,				// continue until CR, LF
	kReport,				// finished parsing sentence
	kCleanup				// finalize
} ZONMEAParseState;

typedef struct {
	ZOCircularBuffer						circularBuffer;
	uint32_t								sentenceTypes;
	ZOParseNMEAOnReceivedSentenceCallback	callback;
	ZONMEAParseState						parseState;
	ZOParseNMEAResult*						result;
	uint8_t									currentSentenceField;
	char									fieldBuffer[FIELD_BUFFER_SIZE];
} ZOParseNMEAContextIMPL;


ZOParseNMEAContext zoParseNMEACreateContext( ZOCircularBuffer circularBuffer, uint32_t sentenceTypes, ZOParseNMEAOnReceivedSentenceCallback callback ) {
	ZOParseNMEAContextIMPL* ctx = (ZOParseNMEAContextIMPL*)malloc( sizeof(ZOParseNMEAContextIMPL) );
	memset( ctx, 0, sizeof(ZOParseNMEAContextIMPL) );
	
	ctx->circularBuffer = circularBuffer;
	ctx->sentenceTypes = sentenceTypes;
	ctx->callback = callback;
	
	return (ZOParseNMEAContext)ctx;
	
}
void zoParseNMEADestroyContext( ZOParseNMEAContext ctx ) {
	free( ctx );
}

static uint32_t zoGetField( ZOParseNMEAContextIMPL* ctx ) {
	uint32_t length = FIELD_BUFFER_SIZE;
	zoCircularBufferReadToCharacter( ctx->circularBuffer, (uint8_t*)ctx->fieldBuffer, &length, ',' );
	if ( length > 0 ) {
		ctx->fieldBuffer[length+1] = '\0';
	}
	return length;
}

// convert NMEA coordinate to decimal degrees
// see: http://forums.adafruit.com/viewtopic.php?f=25&t=30776
static float decimalDegrees( float nmeaCoord ) {
	uint16_t wholeDegrees = 0.01*nmeaCoord;
	return wholeDegrees + (nmeaCoord - 100.0*wholeDegrees)/60.0;
}


static uint8_t zoGetGPGGAFields( ZOParseNMEAContextIMPL* ctx ) {
	//		Global Positioning System Fix Data. Time, position and fix related data for a GPS receiver.
	//		
	//		eg2. $--GGA,hhmmss.ss,llll.ll,a,yyyyy.yy,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx
	//		
	//		hhmmss.ss = UTC of position
	//		llll.ll = latitude of position
	//		a = N or S
	//		yyyyy.yy = Longitude of position
	//		a = E or W
	//		x = GPS Quality indicator (0=no fix, 1=GPS fix, 2=Dif. GPS fix)
	//		xx = number of satellites in use
	//		x.x = horizontal dilution of precision
	//		x.x = Antenna altitude above mean-sea-level
	//		M = units of antenna altitude, meters
	//		x.x = Geoidal separation
	//		M = units of geoidal separation, meters
	//		x.x = Age of Differential GPS data (seconds)
	//		xxxx = Differential reference station ID
	//		eg3. $GPGGA,hhmmss.ss,llll.ll,a,yyyyy.yy,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx*hh
	//		1    = UTC of Position
	//		2    = Latitude
	//		3    = N or S
	//		4    = Longitude
	//		5    = E or W
	//		6    = GPS quality indicator (0=invalid; 1=GPS fix; 2=Diff. GPS fix)
	//		7    = Number of satellites in use [not those in view]
	//		8    = Horizontal dilution of position
	//		9    = Antenna altitude above/below mean sea level (geoid)
	//		10   = Meters  (Antenna height unit)
	//		11   = Geoidal separation (Diff. between WGS-84 earth ellipsoid and
	//								   mean sea level.  -=geoid is below WGS-84 ellipsoid)
	//		12   = Meters  (Units of geoidal separation)
	//		13   = Age in seconds since last update from diff. reference station
	//		14   = Diff. reference station ID#
	//		15   = Checksum
	
	ZOParseNMEAResultGPGAA* result = (ZOParseNMEAResultGPGAA*)ctx->result;
	switch ( ctx->currentSentenceField ) {
		case 1:		// UTC of Position
			if ( zoGetField( ctx ) ) {
				unsigned long utcTime = 0;
				sscanf( ctx->fieldBuffer, "%ld", &utcTime );
				unsigned long hour = utcTime/10000;
				unsigned long minute = (utcTime - (hour*10000))/100;
				unsigned long seconds = utcTime - (hour*10000) - (minute*100);
				// TODO: get the .seconds e.g., ss.ss
				result->hour = (uint32_t)hour;
				result->minute = (uint32_t)minute;
				result->seconds = (uint32_t)seconds;
				ctx->currentSentenceField++;
			} else {
				return 1;	// try later
			}
			break;
		case 2:		// Latitude
			if ( zoGetField( ctx ) ) {
				//sscanf( ctx->fieldBuffer, "%f", &result->lattitude );
				result->lattitude = decimalDegrees( atof( ctx->fieldBuffer ) );
				ctx->currentSentenceField++;
			} else {
				return 1;	// try later
			}
			break;
		case 3:		// N or S
			if ( zoGetField( ctx ) ) {
				result->lattitudeCardinal = ctx->fieldBuffer[0];
				ctx->currentSentenceField++;
			}
		case 4:		// Longitude
			if ( zoGetField( ctx ) ) {
				//sscanf( ctx->fieldBuffer, "%f", &result->longitude );
				result->longitude = decimalDegrees( atof( ctx->fieldBuffer ) );
				ctx->currentSentenceField++;
			} else {
				return 1;	// try later
			}
			break;
		case 5:		// E or W
			if ( zoGetField( ctx ) ) {
				result->longitudeCardinal = ctx->fieldBuffer[0];
				ctx->currentSentenceField++;
			} else {
				return 1;	// try later
			}

			break;
		case 6:		// GPS quality indicator (0=invalid; 1=GPS fix; 2=Diff. GPS fix)
			if ( zoGetField( ctx ) ) {
				result->quality = atoi( ctx->fieldBuffer );
				ctx->currentSentenceField++;
			} else {
				return 1;	// try later
			}
			
			break;
		case 7:		// number of satellites
			if ( zoGetField( ctx ) ) {
				result->satellites = atoi( ctx->fieldBuffer );
				ctx->currentSentenceField++;
			} else {
				return 1;	// try later
			}
			
			break;
		case 8:		// Horizontal dilution of position
			if ( zoGetField( ctx ) ) {
				ctx->currentSentenceField++;
			} else {
				return 1;	// try later
			}
			
			break;
		case 9:		// Antenna altitude above/below mean sea level (geoid)
			if ( zoGetField( ctx ) ) {
				result->altitude = atof( ctx->fieldBuffer );
				ctx->currentSentenceField++;
			} else {
				return 1;	// try later
			}
			
			break;
		
		default:
			ctx->parseState = kReport;
			break;
	}
	
	return 0;
}

void zoParseNMEAUpdate( ZOParseNMEAContext _ctx ) {
	ZOParseNMEAContextIMPL* ctx = (ZOParseNMEAContextIMPL*)_ctx;
	
	if ( ctx->parseState == kUnknown ) {
		ctx->parseState = kSearchForSentenceType;
	}
	
	uint32_t tryLater = 0;
	
	while ( zoCircularBufferGetSize(ctx->circularBuffer)
		   && ctx->parseState != kUnknown
		   && tryLater == 0 ) {	// while data and we are still parsing
		switch ( ctx->parseState ) {
			case kSearchForSentenceType:	// get the NMEA sentence preamble
				if ( zoCircularBufferFindString( ctx->circularBuffer, "$GPGGA," ) ) {
					ctx->result = (ZOParseNMEAResult*)malloc( sizeof(ZOParseNMEAResultGPGAA) );
					memset( ctx->result, 0,  sizeof(ZOParseNMEAResultGPGAA) );
					ctx->result->type = ZOParseNMEAResultType_GPGAA;
					ctx->parseState = kGetFields;
					ctx->currentSentenceField = 1;
				} else if ( zoCircularBufferFindString( ctx->circularBuffer, "\r\n" ) ) {
					ctx->parseState = kCleanup;
				} else {
					tryLater = 1;
				}
				break;
			
			case kGetFields:	// get each field in the NMEA sentence based off preamble.  fields are seperated by ","
				switch ( ctx->result->type ) {
					case ZOParseNMEAResultType_GPGAA:
						tryLater = zoGetGPGGAFields( ctx );
						break;
						
					default:
						break;
				}
				break;
				
			case kReport:
				if ( ctx->callback ) {
					(*ctx->callback)( _ctx, ctx->result );
					ctx->parseState = kCleanup;
				}
				break;
			case kCleanup:
				if ( ctx->result ) {
					free( ctx->result );
					ctx->result = 0;
				}
				ctx->parseState = kUnknown;
				break;
			default:
				break;
		}
	}
	
	
}
