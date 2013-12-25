//
//  ZOVenusCommand.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 12/24/13.
//  Copyright (c) 2013 Micah Pearlman. All rights reserved.
//

#ifndef ZeroGPSLapTimer_ZOVenusCommand_h
#define ZeroGPSLapTimer_ZOVenusCommand_h

#include <stdio.h>
#include <stdint.h>

// enum definition for easier command usage in the code
enum venus_command_type {
	ConfigureMessageTypeBinary			= 0,
	ConfigureMessageTypeNmea			= 1,
	QuerySoftwareVersion				= 2,
	ConfigureSerialPort38400			= 3,
	ConfigureSerialPort115200			= 4,
	QueryNavigationMode					= 5,
	QueryPositionUpdateRate				= 6,
	ConfigureSystemPositionRate_10Hz	= 7,
	ConfigureSystemPositionRate_8Hz		= 8,
	ConfigureSystemPositionRate_5Hz		= 9,
	ConfigureSystemPositionRate_4Hz		= 10,
	ConfigureSystemPositionRate_2Hz		= 11,
	ConfigureSystemPositionRate_1Hz		= 12,
	ConfigureNavigatnionMessageInterval	= 13,
	ConfigureNavigationModeCar			= 14,
	ConfigureNavigationModePedestrian	= 15,
	QueryWaasStatus						= 16,
	ConfigureNMEAMessage				= 17,
	ConfigureNMEAMessage_FullSet		= 18
};


extern void build_command( enum venus_command_type command, uint8_t** buffer, uint16_t* length );

#endif
