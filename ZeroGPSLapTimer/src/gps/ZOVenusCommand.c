//
//  ZOVenusCommand.c
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/24/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//


// see: https://github.com/tomasznaumowicz/AvianGPS/blob/f59d568588414e5ccb5839b45507b644bfb63001/Avian/Drivers/Venus.c
#include "ZOVenusCommand.h"
#include <string.h>
#include <stdlib.h>
#include <arpa/inet.h>

#ifndef                VENUS_RMC_UPDATE_RATE
/*
 * The RMC sentence contains date and time information received from the GPS system.
 * The frequency with which the RMC sentece is proviced by the GPS receiver depends on the system position rate.
 * The number provided here specifies the requency relative to the system position rate.
 *
 * Example:
 *         Setting the value to 200 means, the RMC sentence will be delivered every 200th time. Depending on the system position rate, e.g. when
 *         the system position rate is set to 10Hz, the RMC sentence will be delivered every 20 seconds
 *  and if the system position rate is set to 1Hz, the RMC sentence will be delivered every 200 seconds (3 minutes 20 seconds).
 */
#define                VENUS_RMC_UPDATE_RATE                200
#endif

typedef struct {
	const uint8_t*	command;
	uint16_t			length;
} venus_command_t;

#define UPDATE_TO_SRAM		0x00	// i.e., save just for this session (reboot will erase)
#define UPDATE_TO_FLASH		0x01	// i.e., save permanent



// command contents:
const uint8_t venus_command_ConfigureMessageTypeNmea[]			=	{ 0x09, 0x01, UPDATE_TO_SRAM };
const uint8_t venus_command_ConfigureMessageTypeBinary[]		=	{ 0x09, 0x02, UPDATE_TO_SRAM }; // not in flash
const uint8_t venus_command_QuerySoftwareVersion[]				=	{ 0x02, UPDATE_TO_FLASH };
const uint8_t venus_command_ConfigureSerialPort38400[]			=	{ 0x05, 0x00, 0x03, UPDATE_TO_FLASH };
const uint8_t venus_command_ConfigureSerialPort115200[]			=	{ 0x05, 0x00, 0x05, UPDATE_TO_SRAM }; // not used - should be removed in final version
const uint8_t venus_command_QueryNavigationMode[]				=	{ 0x3D };
const uint8_t venus_command_QueryPositionUpdateRate[]			=	{ 0x10 };
const uint8_t venus_command_ConfigureSystemPositionRate_10Hz[]	=	{ 0x0E, 10, UPDATE_TO_FLASH };
const uint8_t venus_command_ConfigureSystemPositionRate_8Hz[]	=	{ 0x0E, 8, UPDATE_TO_FLASH };
const uint8_t venus_command_ConfigureSystemPositionRate_5Hz[]	=	{ 0x0E, 5, UPDATE_TO_FLASH };
const uint8_t venus_command_ConfigureSystemPositionRate_4Hz[]	=	{ 0x0E, 4, UPDATE_TO_FLASH };
const uint8_t venus_command_ConfigureSystemPositionRate_2Hz[]	=	{ 0x0E, 2, UPDATE_TO_FLASH };
const uint8_t venus_command_ConfigureSystemPositionRate_1Hz[]	=	{ 0x0E, 1, UPDATE_TO_FLASH };
const uint8_t venus_command_ConfigureNavigatnionMessageInterval[] = { 0x11, 1, UPDATE_TO_SRAM }; // doesn't work, should be removed
const uint8_t venus_command_ConfigureNavigatnionModeCar[]		=	{ 0x3C, 0x00, UPDATE_TO_FLASH };
const uint8_t venus_command_ConfigureNavigatnionModePedestrian[] =	{ 0x3C, 0x01, UPDATE_TO_FLASH };
const uint8_t venus_command_QueryWaasStatus[]					=	{ 0x38 };
//m_id  GGA   GSA   GSV   GLL   RMC   VTG   ZDA   ATTR
const uint8_t venus_command_ConfigureNMEAMessage[]				=	{ 0x08, 0x01, 0x00, 0x00, 0x00, VENUS_RMC_UPDATE_RATE, 0x00, 0x00, UPDATE_TO_FLASH };
//m_id  GGA   GSA   GSV   GLL   RMC   VTG   ZDA   ATTR
const uint8_t venus_command_ConfigureNMEAMessage_FullSet[]		=	{ 0x08, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, UPDATE_TO_FLASH };


// storing commands in an array for furhter reuse
// it's important that the order in the array and the enum fields don't change
const venus_command_t venus_commands[] =
{
	{ venus_command_ConfigureMessageTypeBinary,					sizeof(venus_command_ConfigureMessageTypeBinary) },
	{ venus_command_ConfigureMessageTypeNmea,					sizeof(venus_command_ConfigureMessageTypeNmea) },
	{ venus_command_QuerySoftwareVersion,						sizeof(venus_command_QuerySoftwareVersion) },
	{ venus_command_ConfigureSerialPort38400,					sizeof(venus_command_ConfigureSerialPort38400) },
	{ venus_command_ConfigureSerialPort115200,					sizeof(venus_command_ConfigureSerialPort115200) },
	{ venus_command_QueryNavigationMode,						sizeof(venus_command_QueryNavigationMode) },
	{ venus_command_QueryPositionUpdateRate,					sizeof(venus_command_QueryPositionUpdateRate) },
	{ venus_command_ConfigureSystemPositionRate_10Hz,			sizeof(venus_command_ConfigureSystemPositionRate_10Hz) },
	{ venus_command_ConfigureSystemPositionRate_8Hz,			sizeof(venus_command_ConfigureSystemPositionRate_8Hz) },
	{ venus_command_ConfigureSystemPositionRate_5Hz,			sizeof(venus_command_ConfigureSystemPositionRate_5Hz) },
	{ venus_command_ConfigureSystemPositionRate_4Hz,			sizeof(venus_command_ConfigureSystemPositionRate_4Hz) },
	{ venus_command_ConfigureSystemPositionRate_2Hz,			sizeof(venus_command_ConfigureSystemPositionRate_2Hz) },
	{ venus_command_ConfigureSystemPositionRate_1Hz,			sizeof(venus_command_ConfigureSystemPositionRate_1Hz) },
	{ venus_command_ConfigureNavigatnionMessageInterval,		sizeof(venus_command_ConfigureNavigatnionMessageInterval) },
	{ venus_command_ConfigureNavigatnionModeCar,				sizeof(venus_command_ConfigureNavigatnionModeCar) },
	{ venus_command_ConfigureNavigatnionModePedestrian,			sizeof(venus_command_ConfigureNavigatnionModePedestrian) },
	{ venus_command_QueryWaasStatus,							sizeof(venus_command_QueryWaasStatus) },
	{ venus_command_ConfigureNMEAMessage,						sizeof(venus_command_ConfigureNMEAMessage) },
	{ venus_command_ConfigureNMEAMessage_FullSet,				sizeof(venus_command_ConfigureNMEAMessage_FullSet) }
};

void build_command( enum venus_command_type command, uint8_t** buffer, uint16_t* length ) {
	/**
	 * Command Format:
	 *
	 * [fixed]                                        [computed]                                        [ cmd                                        ]        [computed]                        [fixed]
	 * Start Of Sequence (SOS)        Payload Length (2 bytes)        Message ID        Message Body        Checksum (1 byte)        End Of Sequence (EOS)
	 * 0xA0 0xA1                                0x?? 0x??                                        0x??                0x??...                        0x??                                0x0D 0x0A
	 */
	
	uint8_t startOfSequence[]		= { 0xA0, 0xA1 };
	uint8_t endOfSequence[]			= { 0x0D, 0x0A };
	
				// SOS					// PL	// command length					// CS	// EOS
	*length =	sizeof(startOfSequence) + 2		+ venus_commands[command].length	+ 1		+ sizeof(endOfSequence);
	*buffer = (uint8_t*)malloc( *length );
	
	uint16_t idx = 0;
	memcpy( *buffer + idx, startOfSequence, sizeof(startOfSequence) );
	idx += sizeof(startOfSequence);
	
	// NOTE: is big endian
	uint16_t network_length = htons( venus_commands[command].length );
	memcpy( *buffer + idx, &network_length, sizeof(uint16_t) );
	idx += sizeof(uint16_t);
	
	memcpy( *buffer + idx, venus_commands[command].command, venus_commands[command].length );
	idx += venus_commands[command].length;
	
	
	// calculate crc
	uint8_t cs = 0;
	for( uint16_t len = venus_commands[command].length; len > 0; len-- ) {
		cs ^= venus_commands[command].command[len];
	}
	(*buffer)[idx] = cs;
	idx+=1;
	
	
	memcpy( *buffer + idx, startOfSequence, sizeof(endOfSequence) );

	

}