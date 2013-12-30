//
//  ZOCircularBuffer.c
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/26/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#include "ZOCircularBuffer.h"
#include <stdio.h>

typedef struct {
	uint32_t	maxSize;		// maximum size of buffer in bytes
	uint32_t	start;			// index of oldest element
	uint32_t	end;			// index at which to write new element
	uint32_t	currentSize;	// amount of data in buffer in bytes
	uint8_t*	buffer;			// buffer data
} ZOCircularBufferIMPL;

ZOCircularBuffer zoCircularBufferInit( uint32_t sz ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)calloc( 1, sizeof(ZOCircularBufferIMPL) );
	cb->maxSize = sz + 1;
	cb->buffer = (uint8_t*)calloc( cb->maxSize, sizeof(uint8_t) );
	return (ZOCircularBuffer)cb;
}

void zoCircularBufferDestroy( ZOCircularBuffer _cb ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	free( cb->buffer );
	free( cb );
}

void zoCircularBufferWrite( ZOCircularBuffer _cb, const uint8_t* data, const uint32_t length ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	for ( int i = 0; i < length; i++ ) {
		cb->buffer[cb->end] = data[i];
		cb->end = (cb->end + 1) % cb->maxSize;
		cb->currentSize++;
		if ( cb->end == cb->start ) {
			cb->start = (cb->start + 1) % cb->maxSize;	// buffer is full overwriting
			cb->currentSize = cb->maxSize;
		}
		
	}
	
}

void zoCircularBufferRead( ZOCircularBuffer _cb, uint8_t* buffer, const uint32_t length ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	for ( int i = 0; i < length; i++ ) {
		buffer[i] = cb->buffer[cb->start];
		cb->start = (cb->start + 1) % cb->maxSize;
		cb->currentSize--;
	}
}

uint32_t zoCircularBufferGetSize( ZOCircularBuffer _cb ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	return cb->currentSize;
}

