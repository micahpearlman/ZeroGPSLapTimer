#include <SoftwareSerial.h>
#include <stdint.h>

SoftwareSerial gpsSerial(10, 11); // RX, TX (TX not used)
const int sentenceSize = 80;
char sentence[sentenceSize];


enum venusCommand_SaveTo {
  kSRAM    = 0,    // save to SRAM non permenanent 
  kFlash   = 1     // save to SRAM & FLash (permenanent)
};

enum venusCommand_BaudRate {
  k4800   = 0,
  k9600   = 1,
  k19200  = 2,
  k38400  = 3,
  k57600  = 4,
  k115200  = 5  
};

enum venusCommand_ResponseState {
  kSoS1,      // start of sequence 1 0xA0
  kSoS2,      // start of sequence 2 0xA1
  kPL1,       // payload length 1
  kPL2,       // payload length 2
  kMessagedID,// 
  kData,      // Message data
  kCS,        // Checksum
  kEoS1,      // End of sequence 1
  kEoS2,      // End of sequence 2  
  kUnknown    // unknown
};

void venusCommand_setBaudRate( venusCommand_BaudRate baudRate, venusCommand_SaveTo saveTo );
void venusCommand_send( uint8_t* command, uint16_t length );
uint8_t venusCommand_calculateCheckSum( uint8_t* start, int16_t length );

void venusCommand_send( uint8_t* command, uint16_t length ) {
  gpsSerial.write( command, length );
  gpsSerial.flush();
}

bool venusCommand_response() {
  /*
  while( gpsSerial.available() ) {
    uint8_t ch = gpsSerial.read();
    Serial.print(ch, HEX);
  }
  return false;
  */
  while( gpsSerial.available() ) {
    uint8_t ch = gpsSerial.read();
    if( ch == 0x2) {  // ACK
       Serial.println( "Command success..." ); 
        return true;
    } else if( ch == 0x3 ) {  // NACK
      Serial.println( "Command failure..." );
      return false;
    } else {
      Serial.print( "Command unknown response: " );
      Serial.println(ch, HEX);
    }
  }
//  Serial.println( "Command no response..." );
  return false;
  
}



uint8_t venusCommand_calculateCheckSum( uint8_t* start, int16_t length ) {
  uint8_t cs = 0;

  for( uint16_t i = 0; i < length; i++ )
    cs ^= start[i];
    
  return cs;
}




void venusCommand_setBaudRate( venusCommand_BaudRate baudRate, venusCommand_SaveTo saveTo ) {
  uint16_t payloadLength = 4;
  uint8_t* payloadLengthBytes = (uint8_t*)&payloadLength;
  uint8_t command[] = { 0xA0, 0xA1,                            // [0, 1] Start of sequence
                payloadLengthBytes[1], payloadLengthBytes[0],  // [2, 3] Payload length (note in Big Endian network order)
                0x05,                                          // [4] Message ID
                0x0,                                           // [5] COM port
                baudRate,                                      // [6] baudRate
                saveTo,                                        // [7] save to SRAM or Flash
                0,                                             // [8] CS xor message body (calculated below)
                0x0D, 0x0A };                                  // [9, 10] End of sequence
                
  command[ 4 + payloadLength ] = venusCommand_calculateCheckSum( &command[4], payloadLength );
  venusCommand_send( command, sizeof(command) );  
                
}

void venusCommand_getVersion() {
  uint16_t payloadLength = 2;
  uint8_t* payloadLengthBytes = (uint8_t*)&payloadLength;
  uint8_t command[] = { 0xA0, 0xA1,                                    // [0, 1] Start of sequence
                payloadLengthBytes[1], payloadLengthBytes[0],  // [2, 3] Payload length (note in Big Endian network order)
                0x02,                                          // [4] Message ID
                0x0,                                           // [5] reserved
                0,                                             // [6] CS xor message body (calculated below)
                0x0D, 0x0A };                                  // [7, 8] End of sequence
                
  command[ 4 + payloadLength ] = venusCommand_calculateCheckSum( &command[4], payloadLength );
  venusCommand_send( command, sizeof(command) );  
  
//  Serial.print( "check sum: 0x" );
//  Serial.println( command[ 4 + payloadLength ], HEX ); 
  
}

bool commandSend = false;
bool commandResponse = false;
venusCommand_ResponseState state = kUnknown;

void setup()
{
  Serial.begin(9600);
  gpsSerial.begin(57600);
  

  
  //Serial.println("setup complete...");
}


void loop()
{

  
  if( commandSend == false ) {
     //venusCommand_setBaudRate( k57600, kFlash );
     venusCommand_getVersion();
     commandSend = true;
     return;
  } else if( commandResponse == false ) {
    if( gpsSerial.available() ) {
      uint8_t c = gpsSerial.read();
      if( c == 0xA0 ) {
        state = kSoS1;
        Serial.println( "response SoS1" );
      } else if( c == 0xA1 ) {
        state = kSoS2;
        Serial.println( "response SoS2" );
      } else if( state == kSoS2 ) {
        Serial.print( "response PL1: 0x" );
        Serial.println( c, HEX );
        state = kPL1; 
      } else if( state == kPL1 ) {
        Serial.print( "response PL2: 0x" );
        Serial.println( c, HEX );
        state = kPL2; 
      } else if( state == kPL2 ) {
        Serial.print( "response Message ID: 0x" );
        Serial.println( c, HEX );
        state = kData; 
      } else if( c == 0x0D ) {
        Serial.println( "response EoS1" );
        state = kEoS1;  
      } else if( state == kEoS1 ) {
        Serial.println( "response EoS2" );
        state = kEoS2;  
      } else {
        Serial.print( "unknown response: 0x" );
        Serial.println( c, HEX );  
      }
    }
    return;
  }


  
  static int i = 0;
  if (gpsSerial.available())
  {
    //Serial.println( "gpsSerial.available()" );
    char ch = gpsSerial.read();
    if (ch != '\n' && i < sentenceSize)
    {
      sentence[i] = ch;
      i++;
    }
    else
    {
     sentence[i] = '\0';
     i = 0;
     displayGPS();
    }
  }
  

}

void displayGPS()
{
  char field[20];
  getField(field, 0);
  if (strcmp(field, "$GPRMC") == 0)
  {
    Serial.print("Lat: ");
    getField(field, 3);  // number
    Serial.print(field);
    getField(field, 4); // N/S
    Serial.print(field);
    
    Serial.print(" Long: ");
    getField(field, 5);  // number
    Serial.print(field);
    getField(field, 6);  // E/W
    Serial.println(field);
  }
}

void getField(char* buffer, int index)
{
  int sentencePos = 0;
  int fieldPos = 0;
  int commaCount = 0;
  while (sentencePos < sentenceSize)
  {
    if (sentence[sentencePos] == ',')
    {
      commaCount ++;
      sentencePos ++;
    }
    if (commaCount == index)
    {
      buffer[fieldPos] = sentence[sentencePos];
      fieldPos ++;
    }
    sentencePos ++;
  }
  buffer[fieldPos] = '\0';
} 
