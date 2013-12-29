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
	uint32_t	size;	// maximum number of elements
	uint32_t	start;	// index of oldest element
	uint32_t	end;	// index at which to write new element
	uint32_t	count;	// amount of data in buffer
	uint8_t*	data;	// buffer data
} ZOCircularBufferIMPL;

ZOCircularBuffer zoCircularBufferInit( uint32_t sz ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)calloc( 1, sizeof(ZOCircularBufferIMPL) );
	cb->size = sz + 1;
	cb->data = (uint8_t*)calloc( cb->size, sizeof(uint8_t) );
	return (ZOCircularBuffer)cb;
}

void zoCircularBufferDestroy( ZOCircularBuffer _cb ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	free( cb->data );
	free( cb );
}

void zoCircularBufferWrite( ZOCircularBuffer _cb, const uint8_t* data, const uint32_t length ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	for ( int i = 0; i < length; i++ ) {
		cb->data[cb->end] = data[i];
		cb->end = (cb->end + 1) % cb->size;
		cb->count++;
		if ( cb->end == cb->start ) {
			cb->start = (cb->start + 1) % cb->size;	// buffer is full overwriting
			cb->count = cb->size;
		}
		
	}
	
}

void zoCircularBufferRead( ZOCircularBuffer _cb, uint8_t* buffer, const uint32_t length ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	for ( int i = 0; i < length; i++ ) {
		buffer[i] = cb->data[cb->start];
		cb->start = (cb->start + 1) % cb->size;
		cb->count--;
	}
}

uint32_t zoCircularBufferGetCount( ZOCircularBuffer _cb ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	return cb->count;
}

