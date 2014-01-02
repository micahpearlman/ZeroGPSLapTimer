//
//  ZOCircularBuffer.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/26/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#ifndef ZeroGPSLapTimer_ZOCircularBuffer_h
#define ZeroGPSLapTimer_ZOCircularBuffer_h
#include <stdlib.h>
#include <stdint.h>

typedef void* ZOCircularBuffer;

extern ZOCircularBuffer zoCircularBufferInit( uint32_t sz );
extern void zoCircularBufferDestroy( ZOCircularBuffer cb );
extern void zoCircularBufferWrite( ZOCircularBuffer cb, const uint8_t* data, uint32_t* length );
extern void zoCircularBufferRead( ZOCircularBuffer cb, uint8_t* buffer, uint32_t* length );
extern void zoCircularBufferPeek( ZOCircularBuffer cb, uint8_t* buffer, uint32_t* length );
extern uint32_t zoCircularBufferGetSize( ZOCircularBuffer cb );
extern uint8_t zoCircularBufferFindChar( ZOCircularBuffer cb, char c );
extern uint8_t zoCircularBufferFindString( ZOCircularBuffer cb, const char* str );
extern uint8_t zoCircularBufferReadToCharacter( ZOCircularBuffer cb, uint8_t* buffer, uint32_t* length, char c  );
#endif
