//
//  ZOCircularBuffer.c
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/26/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#include "ZOCircularBuffer.h"
#include <stdio.h>
#include <string.h>

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

void zoCircularBufferWrite( ZOCircularBuffer _cb, const uint8_t* data, uint32_t* length) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	*length = *length > cb->maxSize ? cb->maxSize : *length;	// don't write more then the size of the buffer
	for ( int i = 0; i < *length; i++ ) {
		cb->buffer[cb->end] = data[i];
		cb->end = (cb->end + 1) % cb->maxSize;
		cb->currentSize++;
		if ( cb->end == cb->start ) {
			cb->start = (cb->start + 1) % cb->maxSize;	// buffer is full overwriting
			cb->currentSize = cb->maxSize;
		}
		
	}
	
}

void zoCircularBufferRead( ZOCircularBuffer _cb, uint8_t* buffer, uint32_t* length ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	*length = *length > cb->currentSize ? cb->currentSize : *length;	// don't read more then is in the buffer
	for ( int i = 0; i < *length; i++ ) {
		buffer[i] = cb->buffer[cb->start];
		cb->start = (cb->start + 1) % cb->maxSize;
		cb->currentSize--;
	}
}

uint32_t zoCircularBufferGetSize( ZOCircularBuffer _cb ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	return cb->currentSize;
}

void zoCircularBufferPeek( ZOCircularBuffer _cb, uint8_t* buffer, uint32_t* length ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	uint32_t start = cb->start;
	*length = *length > cb->currentSize ? cb->currentSize : *length;	// don't read more then is in the buffer
	for ( int i = 0; i < *length; i++ ) {
		buffer[i] = cb->buffer[start];
		start = (start + 1) % cb->maxSize;
	}
}

uint8_t zoCircularBufferFindChar( ZOCircularBuffer _cb, char c ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	uint32_t start = cb->start;
	uint32_t currentSize = cb->currentSize;
	
	for ( int i = 0; i < cb->currentSize; i++ ) {
		if ( cb->buffer[start] == c ) {
			// found it so fast forward
			cb->start = (start + 1) % cb->maxSize;
			cb->currentSize = currentSize - 1;
			return 1;
		}
		
		start = (start + 1) % cb->maxSize;
		currentSize--;
	}
	
	return 0;	// not found
}

uint8_t zoCircularBufferFindString( ZOCircularBuffer _cb, const char* str ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	uint32_t start = cb->start;
	uint32_t currentSize = cb->currentSize;
	unsigned long len = strlen( str );
	uint8_t stridx = 0;
	
	for ( int i = 0; i < cb->currentSize; i++ ) {
		if ( cb->buffer[start] == str[stridx] ) {
			stridx++;
			if ( stridx == len ) { // found complete string
				// found it so fast forward
				cb->start = (start + 1) % cb->maxSize;
				cb->currentSize = currentSize - 1;
				return 1;
			}
		} else {
			// start over
			stridx = 0;
		}
		currentSize--;
		start = (start + 1) % cb->maxSize;
	}

	return 0;	// not found
}

uint8_t zoCircularBufferReadToCharacter( ZOCircularBuffer _cb, uint8_t* buffer, uint32_t* length, char c  ) {
	ZOCircularBufferIMPL* cb = (ZOCircularBufferIMPL*)_cb;
	uint32_t start = cb->start;
	uint32_t currentSize = cb->currentSize;
	*length = *length > cb->currentSize ? cb->currentSize : *length;	// don't read more then is in the buffer
	
	for ( int i = 0; i < *length; i++ ) {
		
		if ( cb->buffer[start] == c ) {
			// found it so fast forward
			cb->start = (start + 1) % cb->maxSize;
			cb->currentSize = currentSize - 1;
			*length = i;
			return 1;
		}
 
		buffer[i] = cb->buffer[start];
		start = (start + 1) % cb->maxSize;
		currentSize--;
	}
	
	*length = 0;
	return 0;	// not found
	
}
