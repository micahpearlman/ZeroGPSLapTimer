//
//  ZOVenusCommand.c
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/24/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#include "ZOVenusCommand.h"
#include <stdlib.h>
#include <string.h>

typedef enum {
	kUnknown = 0 ,  // unknown
	kCommandSent,	// command message has been sent via venusCommand_writeFunction
	kSoS1,			// start of sequence 1 0xA0
	kSoS2,			// start of sequence 2 0xA1
	kPL1,			// payload length 1
	kPL2,			// payload length 2
	kMessagedID,	//
	kData,			// Message data
	kCS,			// Checksum
	kEoS1,			// End of sequence 1 0x0D
	kEoS2,			// End of sequence 2 0x0A
	kCleanup		// final cleanup
	
} venusCommand_ResponseState;

#define RESPONSE_BUFFER_SIZE	32
#define ACK		0x83
#define NACK	0x84

typedef struct {
	ZOVenusCommandWriteFunction		write;
	ZOVenusCommandReadFunction		read;
	venusCommand_ResponseState		state;
	ZOVenusCommandResponseCallBack	responseCallBack;
	uint8_t							responseBuffer[RESPONSE_BUFFER_SIZE];
	uint16_t						payloadLength;
	uint16_t						payloadBytesRead;
	uint8_t*						payloadData;
	uint8_t							messageID;
	
} venusCommand_ContextIMPL;

ZOVenusCommandContext zoVenusCommandCreateContext(ZOVenusCommandWriteFunction writeFunc, ZOVenusCommandReadFunction readFunc ) {
	venusCommand_ContextIMPL* ctx = (venusCommand_ContextIMPL*)malloc( sizeof(venusCommand_ContextIMPL) );
	memset( ctx, 0, sizeof(venusCommand_ContextIMPL) );
	ctx->write = writeFunc;
	ctx->read = readFunc;
	
	return (ZOVenusCommandContext)ctx;
	
}

void zoVenusCommandDestroyContext( ZOVenusCommandContext ctx ) {
	free( ctx );
}

static inline uint8_t venusCommand_calculateCheckSum( uint8_t* start, uint16_t length ) {
	uint8_t cs = 0;
	
	for( uint16_t i = 0; i < length; i++ )
		cs ^= start[i];
    
	return cs;
}


void zoVenusCommandUpdate( ZOVenusCommandContext _ctx ) {
	venusCommand_ContextIMPL* ctx = (venusCommand_ContextIMPL*)_ctx;
	// if in response state machine the read
	size_t bytesRead = 0;
	if ( ctx->state != kUnknown ) {
		bytesRead = ctx->read( ctx->responseBuffer, RESPONSE_BUFFER_SIZE );
	}
	
	if ( bytesRead ) {
		uint8_t* buffer = ctx->responseBuffer;
		uint8_t* bufferEnd = &ctx->responseBuffer[bytesRead];
		while ( bytesRead ) {
			switch ( ctx->state ) {
				case kCommandSent:
					ctx->state = kSoS1;
					break;
				case kSoS1:
					buffer = memchr( buffer, 0xA0, bytesRead );
					bytesRead = (bufferEnd - buffer) + 1;
					ctx->state = kSoS2;
					break;
				case kSoS2:
					buffer = memchr( buffer, 0xA0, bytesRead );
					bytesRead = (bufferEnd - buffer) + 1;
					ctx->state = kPL1;
					break;
				case kPL1:
					ctx->payloadLength = buffer[0];
					buffer++;
					bytesRead = (bufferEnd - buffer) + 1;
					ctx->state = kPL2;
					break;
				case kPL2:
					ctx->payloadLength |= (((uint16_t)buffer[0]) << 8);	// NOTE: Venus is Big Endian
					buffer++;
					bytesRead = (bufferEnd - buffer) + 1;
					ctx->state = kMessagedID;
					break;
				case kMessagedID:
					ctx->messageID = buffer[0];
					buffer++;
					bytesRead = (bufferEnd - buffer) + 1;
					ctx->payloadLength = ctx->payloadLength - 1;	// minus messageID
					if ( ctx->messageID == ACK ) {
						if ( ctx->responseCallBack ) {
							(*ctx->responseCallBack)( kOK, 0, 0 );
							ctx->state = kCleanup;	// done
						}
					} else if (ctx->messageID == NACK ) {
						if ( ctx->responseCallBack ) {
							(*ctx->responseCallBack)( kError, 0, 0 );
							ctx->state = kCleanup;	// done
						}
						
					} else {
						ctx->payloadData = (uint8_t*)malloc( ctx->payloadLength );
						ctx->payloadBytesRead = 0;
						ctx->state = kData;
					}
					
					break;
				case kData:
					memcpy( ctx->payloadData + ctx->payloadBytesRead, buffer, bytesRead );
					ctx->payloadBytesRead += bytesRead;
					buffer = buffer + bytesRead;
					bytesRead = (bufferEnd - buffer) + 1;	// should be 0
					if ( ctx->payloadBytesRead == ctx->payloadLength ) {	// check to see if more needs to be read in
						// BUGBUG: should be doing Check Sum on the data before passing it to application
						(*ctx->responseCallBack)( kError, ctx->payloadData, ctx->payloadLength );
					}
					break;
				case kCleanup:	// quit
					if ( ctx->payloadData ) {
						free( ctx->payloadData );
						ctx->payloadData = 0;
					}
					bytesRead = 0;
					break;
				default:
					break;
			}
			
		}
	}
	
	
}



void zoVenusCommandSetBaudRate( ZOVenusCommandContext _ctx, ZOVenusCommandBaudRate baudRate, ZOVenusCommandSaveTo saveTo, ZOVenusCommandResponseCallBack cb ) {
	venusCommand_ContextIMPL* ctx = (venusCommand_ContextIMPL*)_ctx;
	
	const uint16_t payloadLength = 4;
	const uint8_t* payloadLengthBytes = (uint8_t*)&payloadLength;
	uint8_t command[] = { 0xA0, 0xA1,                            // [0, 1] Start of sequence
		payloadLengthBytes[1], payloadLengthBytes[0],  // [2, 3] Payload length (note in Big Endian network order)
		0x05,                                          // [4] Message ID
		0x0,                                           // [5] COM port
		baudRate,                                      // [6] baudRate
		saveTo,                                        // [7] save to SRAM or Flash
		0,                                             // [8] CS xor message body (calculated below)
		0x0D, 0x0A };                                  // [9, 10] End of sequence
	
	command[ 4 + payloadLength ] = venusCommand_calculateCheckSum( &command[4], payloadLength );

	ctx->responseCallBack = cb;
	ctx->write( command, sizeof(command) );
	ctx->state = kCommandSent;
	
}

void zoVenusCommandGetVersion( ZOVenusCommandContext _ctx, ZOVenusCommandResponseCallBack cb ) {
	venusCommand_ContextIMPL* ctx = (venusCommand_ContextIMPL*)_ctx;
	const uint16_t payloadLength = 2;
	const uint8_t* payloadLengthBytes = (uint8_t*)&payloadLength;
	uint8_t command[] = { 0xA0, 0xA1,                                    // [0, 1] Start of sequence
		payloadLengthBytes[1], payloadLengthBytes[0],  // [2, 3] Payload length (note in Big Endian network order)
		0x02,                                          // [4] Message ID
		0x0,                                           // [5] reserved
		0,                                             // [6] CS xor message body (calculated below)
		0x0D, 0x0A };                                  // [7, 8] End of sequence
	
	command[ 4 + payloadLength ] = venusCommand_calculateCheckSum( &command[4], payloadLength );
	
	ctx->responseCallBack = cb;
	ctx->write( command, sizeof(command) );
	ctx->state = kCommandSent;
	
}