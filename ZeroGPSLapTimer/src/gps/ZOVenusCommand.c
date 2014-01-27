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
	uint8_t							commandExpectsResponseAfterACK;
	void*							userData;
	
} venusCommand_ContextIMPL;

ZOVenusCommandContext zoVenusCommandCreateContext(ZOVenusCommandWriteFunction writeFunc, ZOVenusCommandReadFunction readFunc, void* userData ) {
	venusCommand_ContextIMPL* ctx = (venusCommand_ContextIMPL*)malloc( sizeof(venusCommand_ContextIMPL) );
	memset( ctx, 0, sizeof(venusCommand_ContextIMPL) );
	ctx->write = writeFunc;
	ctx->read = readFunc;
	ctx->userData = userData;
	
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
	size_t bytesLeftToRead = 0;
	if ( ctx->state != kUnknown ) {
		bytesLeftToRead = ctx->read( ctx, ctx->responseBuffer, RESPONSE_BUFFER_SIZE );
	}
	
	if ( bytesLeftToRead ) {
		uint8_t* found = 0;
		uint8_t* buffer = ctx->responseBuffer;
		uint8_t* bufferEnd = &ctx->responseBuffer[bytesLeftToRead];
		while ( bytesLeftToRead ) {
			switch ( ctx->state ) {
				case kCommandSent:
					ctx->state = kSoS1;
					break;
				case kSoS1:
					found = memchr( buffer, 0xA0, bytesLeftToRead );
					if ( found ) {
						buffer = found + 1;
						bytesLeftToRead = bufferEnd - buffer;
						ctx->state = kSoS2;
					} else {
						bytesLeftToRead = 0;	// end while loop
					}
					break;
				case kSoS2:
					found = memchr( buffer, 0xA1, bytesLeftToRead );
					if ( found ) {
						buffer = found + 1;
						bytesLeftToRead = bufferEnd - buffer;
						ctx->state = kPL1;
					} else {
						bytesLeftToRead = 0; // end while loop
					}
					break;
				case kPL1:
					ctx->payloadLength = (((uint16_t)buffer[0]) << 8);
					buffer++;
					bytesLeftToRead = bufferEnd - buffer;
					ctx->state = kPL2;
					break;
				case kPL2:
					ctx->payloadLength |= buffer[0];	// NOTE: Venus is Big Endian
					buffer++;
					bytesLeftToRead = bufferEnd - buffer;
					ctx->state = kMessagedID;
					break;
				case kMessagedID:
					ctx->messageID = buffer[0];
					buffer++;
					bytesLeftToRead = bufferEnd - buffer;
					ctx->payloadLength = ctx->payloadLength - 1;	// minus messageID
					if ( ctx->messageID == ACK ) {
						
						if ( ctx->responseCallBack && ctx->commandExpectsResponseAfterACK == 0 ) { // just inform application we have an ack
							(*ctx->responseCallBack)( ctx, ZOVenusCommandResponse_OK, 0, 0 );
							ctx->state = kCleanup;	// done
						} else if ( ctx->responseCallBack ) {	// expecting further response so start over looking for it in buffer
							ctx->state = kSoS1;	//
						}
					} else if (ctx->messageID == NACK ) {
						if ( ctx->responseCallBack ) {
							(*ctx->responseCallBack)( ctx, ZOVenusCommandResponse_Error, 0, 0 );
							ctx->state = kCleanup;	// done
						}
						
					} else {
						ctx->payloadData = (uint8_t*)malloc( ctx->payloadLength );
						ctx->payloadBytesRead = 0;
						ctx->state = kData;
					}
					
					break;
				case kData:
					if ( ctx->payloadLength > bytesLeftToRead ) {	// if we need to read more data then in current buffer
						ctx->state = kData;	// keep on reading
					} else {	// more data in buffer then needed for reading all the data
						bytesLeftToRead = ctx->payloadLength;
						ctx->state = kCleanup;	// done.  TODO: do checksum...
					}
					
					memcpy( ctx->payloadData + ctx->payloadBytesRead, buffer, bytesLeftToRead );
					
					ctx->payloadBytesRead += bytesLeftToRead;
					buffer = buffer + bytesLeftToRead;
					bytesLeftToRead = bufferEnd - buffer;
					
					if ( ctx->state == kCleanup ) {	// all done notify the app
						// BUGBUG: should be doing Check Sum on the data before passing it to application
						(*ctx->responseCallBack)( ctx, ZOVenusCommandResponse_OK, ctx->payloadData, ctx->payloadLength );
					}
					break;
				case kCleanup:	// quit
					if ( ctx->payloadData ) {
						free( ctx->payloadData );
						ctx->payloadData = 0;
					}
					bytesLeftToRead = 0;
					break;
				default:
					break;
			}
			
		}
	}
	
	
}

extern void* zoVenusCommandGetUserData( ZOVenusCommandContext _ctx ) {
	venusCommand_ContextIMPL* ctx = (venusCommand_ContextIMPL*)_ctx;
	return ctx->userData;
}


void zoVenusCommandSetBaudRate( ZOVenusCommandContext _ctx, ZOVenusCommandBaudRate baudRate, ZOVenusCommandSaveTo saveTo, ZOVenusCommandResponseCallBack cb ) {
	venusCommand_ContextIMPL* ctx = (venusCommand_ContextIMPL*)_ctx;
	
	const uint16_t payloadLength = 4;
	const uint8_t* payloadLengthBytes = (uint8_t*)&payloadLength;
	uint8_t command[] = { 0xA0, 0xA1,                  // [0, 1] Start of sequence
		payloadLengthBytes[1], payloadLengthBytes[0],  // [2, 3] Payload length (note in Big Endian network order)
		0x05,                                          // [4] Message ID
		0x0,                                           // [5] COM port
		baudRate,                                      // [6] baudRate
		saveTo,                                        // [7] save to SRAM or Flash
		0,                                             // [8] CS xor message body (calculated below)
		0x0D, 0x0A };                                  // [9, 10] End of sequence
	
	command[ 4 + payloadLength ] = venusCommand_calculateCheckSum( &command[4], payloadLength );

	ctx->responseCallBack = cb;
	ctx->write( ctx, command, sizeof(command) );
	ctx->state = kCommandSent;
	ctx->commandExpectsResponseAfterACK = 0;
	
}

void zoVenusCommandGetVersion( ZOVenusCommandContext _ctx, ZOVenusCommandResponseCallBack cb ) {
	venusCommand_ContextIMPL* ctx = (venusCommand_ContextIMPL*)_ctx;
	const uint16_t payloadLength = 2;
	const uint8_t* payloadLengthBytes = (uint8_t*)&payloadLength;
	uint8_t command[] = { 0xA0, 0xA1,                  // [0, 1] Start of sequence
		payloadLengthBytes[1], payloadLengthBytes[0],  // [2, 3] Payload length (note in Big Endian network order)
		0x02,                                          // [4] Message ID
		0x0,                                           // [5] reserved
		0,                                             // [6] CS xor message body (calculated below)
		0x0D, 0x0A };                                  // [7, 8] End of sequence
	
	command[ 4 + payloadLength ] = venusCommand_calculateCheckSum( &command[4], payloadLength );
	
	ctx->responseCallBack = cb;
	ctx->write( command, sizeof(command) );
	ctx->state = kCommandSent;
	ctx->commandExpectsResponseAfterACK = 1;
	
}

