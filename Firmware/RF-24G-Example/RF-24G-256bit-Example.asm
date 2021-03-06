
; CC5X Version 3.1I, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  23. Jun 2004   9:53  *************

	processor  16F88
	radix  DEC

INDF        EQU   0x00
PCL         EQU   0x02
FSR         EQU   0x04
PORTA       EQU   0x05
TRISA       EQU   0x85
PORTB       EQU   0x06
TRISB       EQU   0x86
PCLATH      EQU   0x0A
Carry       EQU   0
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
IRP         EQU   7
GIE         EQU   7
TMR1L       EQU   0x0E
TMR1H       EQU   0x0F
TXREG       EQU   0x19
RCREG       EQU   0x1A
OSCCON      EQU   0x8F
SPBRG       EQU   0x99
ANSEL       EQU   0x9B
CMCON       EQU   0x9C
EEDATA      EQU   0x10C
EEADR       EQU   0x10D
EEDATH      EQU   0x10E
EEADRH      EQU   0x10F
PEIE        EQU   6
TMR1IF      EQU   0
TXIF        EQU   4
RCIF        EQU   5
TMR1ON      EQU   0
CREN        EQU   4
SPEN        EQU   7
TXIE        EQU   4
RCIE        EQU   5
BRGH        EQU   2
SYNC        EQU   4
TXEN        EQU   5
RD          EQU   0
EEPGD       EQU   7
x           EQU   0x7F
x_2         EQU   0x23
y           EQU   0x25
z           EQU   0x26
x_3         EQU   0x7F
y_2         EQU   0x7F
want_ints   EQU   0
want_ints_2 EQU   0
nate        EQU   0x44
x_4         EQU   0x44
nate_2      EQU   0x34
my_byte     EQU   0x35
i           EQU   0x37
k           EQU   0x38
m           EQU   0x39
temp        EQU   0x3A
high_byte   EQU   0x3B
low_byte    EQU   0x3C
C1cnt       EQU   0x44
C2tmp       EQU   0x45
C3cnt       EQU   0x44
C4tmp       EQU   0x45
C5rem       EQU   0x47
data_array  EQU   0x49
counter     EQU   0x66
packet_number EQU   0x67
i_2         EQU   0x20
elapsed_time EQU   0x21
i_3         EQU   0x23
j           EQU   0x24
temp_2      EQU   0x25
i_4         EQU   0x23
j_2         EQU   0x24
temp_3      EQU   0x25
rf_address  EQU   0x26
i_5         EQU   0x23
j_3         EQU   0x24
temp_4      EQU   0x25
config_setup EQU   0x26
i_6         EQU   0x23
j_4         EQU   0x24
temp_5      EQU   0x25
config_setup_2 EQU   0x26
ci          EQU   0x44

	GOTO main

  ; FILE D:\Pics\code\16F88\RF Test\RF-24G-256bit-Example.c
			;/*
			;    5-30-04
			;    Copyright Spark Fun Electronics© 2004
			;    
			;    RF-24G Configuration and testing. The 24G requires 500ns between Data Setup and Clk, so we ran this on a 16F88 at
			;    internal 8MHz which turns into 500ns per instruction. Imagine a breadboard with a 16F88 connected to two transceivers
			;    inserted into the same breadboard about 4 inches apart. This made it easy for testing the setup on the units and 
			;    proof of transmission, but not a good setup for testing the effective communication distance.
			;    
			;    The RF-24G requires 3V!! No 5V! So we ran our 16F88 (not 16LF88) at 3V and at 8MHz. This is out of spec for both minimum 
			;    voltage (4V) and maximum frequency at 3V (4MHz) but it worked great! Of course it shouldn't be used for a deployed design.    
			;
			;    
			;    THIS SETUP is for testing of the full 256 bit payload including address and CRC.
			;    Usable payload = 256 - 16(CRC) - 8(Address) = 232 bits = 29 bytes for data
			;    
			;    THIS SETUP seems to drop ~40% of the packets. Not great.
			;    A 4 byte setup drops ~10% of the packets.
			;    
			;
			;    The time delay between clocking in the next data is given by the equation on page 31.
			;    Time On Air = (databits+1) / datarate  
			;    T(OA) = 266 bits (max) / 1,000,000 bps = 266us
			;    
			;    NOTE: If you enable the receiver (set CE high), the receiver will start monitoring the air. With the CRC
			;    set to 8 bit (default) the receiver will find all sorts of junk in the air with a correct CRC tag. Our recommendation
			;    is to either transmit a resonably constant stream of data, use 16-bit CRC, and/or use additional header/end bytes in
			;    the payload to verify incoming packets.
			;
			;    23: 0 Payloads have an 8 bit address
			;    22: 0
			;    21: 1
			;    20: 0
			;    19: 0
			;    18: 0
			;    17: 1 16-Bit CRC
			;    16: 1 CRC Enabled
			;
			;    15: 0 One channel receive
			;    14: 1 ShockBurst Mode
			;    13: 1 1Mbps Transmission Rate
			;    12: 0
			;    11: 1
			;    10: 1
			;    9: 1 RF Output Power
			;    8: 0 RF Output Power
			;
			;    7: 0 Channel select (channel 2)
			;    6: 0
			;    5: 0
			;    4: 0
			;    3: 0
			;    2: 1
			;    1: 0
			;    0: 0 Transmit mode
			;    
			;*/
			;#define Clock_8MHz
			;#define Baud_9600
			;
			;#include "d:\Pics\c\16F88.h"
			;
			;//There is no config word because this program tested on a 16F88 using Bloader the boot load program
			;
			;#pragma origin 4
	ORG 0x0004

  ; FILE d:\Pics\code\Delay.c
			;/*
			;    7/23/02
			;    Nathan Seidle
			;    nathan.seidle@colorado.edu
			;    
			;    Delays for... Well, everything.
			;    
			;    11-11 Updated the delays - now they actually delay what they say they should.
			;    
			;    10-11-03 Updated delays. New CC5X compiler is muy optimized.
			;
			;*/
			;
			;//Really short delay
			;void delay_us(uns16 x)
			;{
_const1
	MOVWF ci
	MOVLW .0
	BSF   0x03,RP1
	MOVWF EEADRH
	BCF   0x03,RP1
	RRF   ci,W
	ANDLW .127
	ADDLW .35
	BSF   0x03,RP1
	MOVWF EEADR
	BTFSC 0x03,Carry
	INCF  EEADRH,1
	BSF   0x03,RP0
	BSF   0x18C,EEPGD
	BSF   0x18C,RD
	NOP  
	NOP  
	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC ci,0
	GOTO  m001
	BSF   0x03,RP1
	MOVF  EEDATA,W
	ANDLW .127
	BCF   0x03,RP1
	RETURN
m001	BSF   0x03,RP1
	RLF   EEDATA,W
	RLF   EEDATH,W
	BCF   0x03,RP1
	RETURN
	DW    0x68A
	DW    0x2352
	DW    0x192D
	DW    0x23B4
	DW    0x2A20
	DW    0x39E5
	DW    0x34F4
	DW    0x33EE
	DW    0x53A
	DW    0xD
	DW    0x32D2
	DW    0x32E3
	DW    0x3B69
	DW    0x3265
	DW    0x3820
	DW    0x31E1
	DW    0x32EB
	DW    0x1074
	DW    0x3225
	DW    0x68A
	DW    0x2900
	DW    0x1058
	DW    0x37C3
	DW    0x336E
	DW    0x33E9
	DW    0x3975
	DW    0x3A61
	DW    0x37E9
	DW    0x106E
	DW    0x34E6
	DW    0x34EE
	DW    0x3473
	DW    0x3265
	DW    0x172E
	DW    0x52E
	DW    0xD
	DW    0x2C54
	DW    0x21A0
	DW    0x376F
	DW    0x34E6
	DW    0x3AE7
	DW    0x30F2
	DW    0x34F4
	DW    0x376F
	DW    0x3320
	DW    0x3769
	DW    0x39E9
	DW    0x32E8
	DW    0x1764
	DW    0x172E
	DW    0x68A
	DW    0x0
delay_us
			;
			;#ifdef Clock_4MHz
			;    //Calling with 10us returns 69us
			;    for ( ; x > 0 ; x--);
			;#endif
			;
			;#ifdef Clock_8MHz
			;    //Calling with 1us returns 11us
			;    //Calling with 10us returns 56us
			;    //for ( ; x > 0 ; x--);
			;    
			;    //Calling with 1us returns 7.5us
			;    //Calling with 10us returns 48
			;    //Calling with 1000us returns 4.5ms
			;    while(--x); 
m002	DECF  x,1
	INCF  x,W
	BTFSC 0x03,Zero_
	DECF  x+1,1
	MOVF  x,W
	IORWF x+1,W
	BTFSS 0x03,Zero_
	GOTO  m002
			;
			;    //while(x--); 
			;#endif
			;
			;#ifdef Clock_20MHz
			;    //Calling with 10us returns 13 us
			;    //Calling with 1us returns 1.8us
			;    while(--x) nop(); 
			;#endif
			;
			;}
	RETURN
			;
			;//General short delay
			;void delay_ms(uns16 x)
			;{
delay_ms
			;
			;#ifdef Clock_4MHz
			;    //Clocks out at 1002us per 1ms
			;    int y;
			;    for ( ; x > 0 ; x--)
			;        for ( y = 0 ; y < 108 ; y++);
			;#endif
			;
			;#ifdef Clock_8MHz
			;    //Clocks out at 1006us per 1ms
			;    uns8 y, z;
			;    for ( ; x > 0 ; x--)
m003	MOVF  x_2,W
	IORWF x_2+1,W
	BTFSC 0x03,Zero_
	GOTO  m008
			;        for ( y = 0 ; y < 4 ; y++)
	CLRF  y
m004	MOVLW .4
	SUBWF y,W
	BTFSC 0x03,Carry
	GOTO  m007
			;            for ( z = 0 ; z < 69 ; z++);
	CLRF  z
m005	MOVLW .69
	SUBWF z,W
	BTFSC 0x03,Carry
	GOTO  m006
	INCF  z,1
	GOTO  m005
m006	INCF  y,1
	GOTO  m004
m007	DECF  x_2,1
	INCF  x_2,W
	BTFSC 0x03,Zero_
	DECF  x_2+1,1
	GOTO  m003
			;#endif
			;
			;#ifdef Clock_20MHz
			;
			;    uns8 y, z;
			;    //Clocks out to 1.00ms per 1ms
			;    //9.99 ms per 10ms
			;    for ( ; x > 0 ; x--)
			;        for ( y = 0 ; y < 4 ; y++)
			;            for ( z = 0 ; z < 176 ; z++);
			;#endif
			;
			;}
m008	RETURN
			;
			;//Delays in 31.25kHz Low Power mode using the internal 31.25kHz oscillator
			;void delay_s_lp(uns16 x)
			;{
delay_s_lp
			;
			;    uns16 y;
			;    //Clocks out to 1.001s per 1s
			;    for ( ; x > 0 ; x--)
m009	MOVF  x_3,W
	IORWF x_3+1,W
	BTFSC 0x03,Zero_
	GOTO  m013
			;        for ( y = 0 ; y < 775 ; y++);
	CLRF  y_2
	CLRF  y_2+1
m010	MOVLW .3
	SUBWF y_2+1,W
	BTFSS 0x03,Carry
	GOTO  m011
	BTFSS 0x03,Zero_
	GOTO  m012
	MOVLW .7
	SUBWF y_2,W
	BTFSC 0x03,Carry
	GOTO  m012
m011	INCF  y_2,1
	BTFSC 0x03,Zero_
	INCF  y_2+1,1
	GOTO  m010
m012	DECF  x_3,1
	INCF  x_3,W
	BTFSC 0x03,Zero_
	DECF  x_3+1,1
	GOTO  m009

  ; FILE D:\Pics\code\16F88\RF Test\RF-24G-256bit-Example.c
			;
			;#include "d:\Pics\code\Delay.c"     // Delays
m013	RETURN

  ; FILE d:\Pics\code\Stdio.c
			;/*
			;    5/21/02
			;    Nathan Seidle
			;    nathan.seidle@colorado.edu
			;    
			;    Serial Out Started on 5-21
			;    rs_out Perfected on 5-24
			;    
			;    1Wire Serial Comm works with 4MHz Xtal
			;    Connect Serial_Out to Pin2 on DB9 Serial Connector
			;    Connect Pin5 on DB9 Connector to Signal Ground
			;    9600 Baud 8-N-1
			;    
			;    5-21 My first real C and Pic program.
			;    5-24 Attempting 20MHz implementation
			;    5-25 20MHz works
			;    5-25 Serial In works at 4MHz
			;    5-25 Passing Strings 9:20
			;    5-25 Option Selection 9:45
			;
			;    6-9  'Stdio.c' created. Printf working with %d and %h
			;    7-20 Added a longer delay after rs_out
			;         Trying to get 20MHz on the 16F873 - I think the XTal is bad.
			;         20MHz also needs 5V Vdd. Something I dont have.
			;    2-9-03 Overhauled the 4MHz timing. Serial out works very well now.
			;    
			;    6-16-03 Discovered how to pass string in cc5x
			;        void test(const char *str);
			;        test("zbcdefghij"); TXREG = str[1];
			;        
			;        Moved to hardware UART. Old STDIO will be in goodworks.
			;        
			;        Works great! Even got the special print characters (\n, \r, \0) to work.
			;    
			;    4-25-04 Added new %d routine to print 16 bit signed decimal numbers without leading 0s.
			;        
			;
			;*/
			;
			;//Setup the hardware UART TX module
			;void enable_uart_TX(bit want_ints)
			;{
enable_uart_TX
			;
			;#ifdef Clock_4MHz
			;    #ifdef Baud_9600
			;    SPBRG = 6; //4MHz for 9600 Baud
			;    #endif
			;#endif
			;
			;#ifdef Clock_8MHz
			;    #ifdef Baud_4800
			;    SPBRG = 25; //8MHz for 4800 Baud
			;    #endif
			;    #ifdef Baud_9600
			;    SPBRG = 12; //8MHz for 9600 Baud
	MOVLW .12
	MOVWF SPBRG
			;    #endif
			;#endif
			;
			;#ifdef Crazy_Osc
			;    #ifdef Baud_9600
			;    SPBRG = 32; //20MHz for 9600 Baud
			;    #endif
			;#endif
			;
			;#ifdef Clock_20MHz
			;    #ifdef Baud_9600
			;    SPBRG = 31; //20MHz for 9600 Baud
			;    #endif
			;
			;    #ifdef Baud_4800
			;    SPBRG = 64; //20MHz for 4800 Baud
			;    #endif
			;#endif
			;
			;    BRGH = 0; //Normal speed UART
	BCF   0x98,BRGH
			;
			;    SYNC = 0;
	BCF   0x98,SYNC
			;    SPEN = 1;
	BCF   0x03,RP0
	BSF   0x18,SPEN
			;
			;    if(want_ints) //Check if we want to turn on interrupts
	BTFSS 0x23,want_ints
	GOTO  m014
			;    {
			;        TXIE = 1;
	BSF   0x03,RP0
	BSF   0x8C,TXIE
			;        PEIE = 1;
	BSF   0x0B,PEIE
			;        GIE = 1;
	BSF   0x0B,GIE
			;    }
			;
			;    TXEN = 1; //Enable transmission
m014	BSF   0x03,RP0
	BSF   0x98,TXEN
			;}    
	RETURN
			;
			;//Setup the hardware UART RX module
			;void enable_uart_RX(bit want_ints)
			;{
enable_uart_RX
			;
			;#ifdef Clock_4MHz
			;    #ifdef Baud_9600
			;    SPBRG = 6; //4MHz for 9600 Baud
			;    #endif
			;#endif
			;
			;#ifdef Clock_20MHz
			;    #ifdef Baud_9600
			;    SPBRG = 31; //20MHz for 9600 Baud
			;    #endif
			;
			;    #ifdef Baud_4800
			;    SPBRG = 64; //20MHz for 4800 Baud
			;    #endif
			;#endif
			;
			;    BRGH = 0; //Normal speed UART
	BCF   0x98,BRGH
			;
			;    SYNC = 0;
	BCF   0x98,SYNC
			;    SPEN = 1;
	BCF   0x03,RP0
	BSF   0x18,SPEN
			;
			;    CREN = 1;
	BSF   0x18,CREN
			;
			;    //WREN = 1;
			;
			;    if(want_ints) //Check if we want to turn on interrupts
	BTFSS 0x23,want_ints_2
	GOTO  m015
			;    {
			;        RCIE = 1;
	BSF   0x03,RP0
	BSF   0x8C,RCIE
			;        PEIE = 1;
	BSF   0x0B,PEIE
			;        GIE = 1;
	BSF   0x0B,GIE
			;    }
			;
			;}    
m015	BCF   0x03,RP0
	RETURN
			;
			;//Sends nate to the Transmit Register
			;void putc(uns8 nate)
			;{
putc
	MOVWF nate
			;    while(TXIF == 0);
m016	BTFSS 0x0C,TXIF
	GOTO  m016
			;    TXREG = nate;
	MOVF  nate,W
	MOVWF TXREG
			;}
	RETURN
			;
			;uns8 getc(void)
			;{
getc
			;    while(RCIF == 0);
	BCF   0x03,RP0
	BCF   0x03,RP1
m017	BTFSS 0x0C,RCIF
	GOTO  m017
			;    return (RCREG);
	MOVF  RCREG,W
	RETURN
			;}    
			;
			;//Returns ASCII Decimal and Hex values
			;uns8 bin2Hex(char x)
			;{
bin2Hex
	MOVWF x_4
			;   skip(x);
	CLRF  PCLATH
	MOVF  x_4,W
	ADDWF PCL,1
			;   #pragma return[16] = "0123456789ABCDEF"
	RETLW .48
	RETLW .49
	RETLW .50
	RETLW .51
	RETLW .52
	RETLW .53
	RETLW .54
	RETLW .55
	RETLW .56
	RETLW .57
	RETLW .65
	RETLW .66
	RETLW .67
	RETLW .68
	RETLW .69
	RETLW .70
			;}
			;
			;//Prints a string including variables
			;void printf(const char *nate, int16 my_byte)
			;{
printf
			;  
			;    uns8 i, k, m, temp;
			;    uns8 high_byte = 0, low_byte = 0;
	CLRF  high_byte
	CLRF  low_byte
			;    uns8 y, z;
			;    
			;    uns8 decimal_output[5];
			;    
			;    for(i = 0 ; ; i++)
	CLRF  i
			;    {
			;        k = nate[i];
m018	MOVF  i,W
	ADDWF nate_2,W
	CALL  _const1
	MOVWF k
			;
			;        if (k == '\0') 
	MOVF  k,1
	BTFSC 0x03,Zero_
			;            break;
	GOTO  m040
			;
			;        else if (k == '%') //Print var
	XORLW .37
	BTFSS 0x03,Zero_
	GOTO  m038
			;        {
			;            i++;
	INCF  i,1
			;            k = nate[i];
	MOVF  i,W
	ADDWF nate_2,W
	CALL  _const1
	MOVWF k
			;
			;            if (k == '\0') 
	MOVF  k,1
	BTFSC 0x03,Zero_
			;                break;
	GOTO  m040
			;            else if (k == '\\') //Print special characters
	XORLW .92
	BTFSS 0x03,Zero_
	GOTO  m019
			;            {
			;                i++;
	INCF  i,1
			;                k = nate[i];
	MOVF  i,W
	ADDWF nate_2,W
	CALL  _const1
	MOVWF k
			;                
			;                putc(k);
	CALL  putc
			;                
			;
			;            } //End Special Characters
			;            else if (k == 'b') //Print Binary
	GOTO  m039
m019	MOVF  k,W
	XORLW .98
	BTFSS 0x03,Zero_
	GOTO  m024
			;            {
			;                for( m = 0 ; m < 8 ; m++ )
	CLRF  m
m020	MOVLW .8
	SUBWF m,W
	BTFSC 0x03,Carry
	GOTO  m039
			;                {
			;                    if (my_byte.7 == 1) putc('1');
	BTFSS my_byte,7
	GOTO  m021
	MOVLW .49
	CALL  putc
			;                    if (my_byte.7 == 0) putc('0');
m021	BTFSC my_byte,7
	GOTO  m022
	MOVLW .48
	CALL  putc
			;                    if (m == 3) putc(' ');
m022	MOVF  m,W
	XORLW .3
	BTFSS 0x03,Zero_
	GOTO  m023
	MOVLW .32
	CALL  putc
			;                    
			;                    my_byte = my_byte << 1;
m023	BCF   0x03,Carry
	RLF   my_byte,1
	RLF   my_byte+1,1
			;                }
	INCF  m,1
	GOTO  m020
			;            } //End Binary               
			;            else if (k == 'd') //Print Decimal
m024	MOVF  k,W
	XORLW .100
	BTFSS 0x03,Zero_
	GOTO  m034
			;            {
			;                //Print negative sign and take 2's compliment
			;                /*
			;                if(my_byte < 0)
			;                {
			;                    putc('-');
			;                    my_byte ^= 0xFFFF;
			;                    my_byte++;
			;                }
			;                */
			;                
			;                //Divide number by a series of 10s
			;                for(m = 4 ; my_byte > 0 ; m--)
	MOVLW .4
	MOVWF m
m025	BTFSC my_byte+1,7
	GOTO  m032
	MOVF  my_byte,W
	IORWF my_byte+1,W
	BTFSC 0x03,Zero_
	GOTO  m032
			;                {
			;                    temp = my_byte % (uns16)10;
	MOVF  my_byte,W
	MOVWF C2tmp
	MOVF  my_byte+1,W
	MOVWF C2tmp+1
	CLRF  temp
	MOVLW .16
	MOVWF C1cnt
m026	RLF   C2tmp,1
	RLF   C2tmp+1,1
	RLF   temp,1
	BTFSC 0x03,Carry
	GOTO  m027
	MOVLW .10
	SUBWF temp,W
	BTFSS 0x03,Carry
	GOTO  m028
m027	MOVLW .10
	SUBWF temp,1
m028	DECFSZ C1cnt,1
	GOTO  m026
			;                    decimal_output[m] = temp;
	MOVLW .63
	ADDWF m,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  temp,W
	MOVWF INDF
			;                    my_byte = my_byte / (uns16)10;               
	MOVF  my_byte,W
	MOVWF C4tmp
	MOVF  my_byte+1,W
	MOVWF C4tmp+1
	CLRF  C5rem
	MOVLW .16
	MOVWF C3cnt
m029	RLF   C4tmp,1
	RLF   C4tmp+1,1
	RLF   C5rem,1
	BTFSC 0x03,Carry
	GOTO  m030
	MOVLW .10
	SUBWF C5rem,W
	BTFSS 0x03,Carry
	GOTO  m031
m030	MOVLW .10
	SUBWF C5rem,1
	BSF   0x03,Carry
m031	RLF   my_byte,1
	RLF   my_byte+1,1
	DECFSZ C3cnt,1
	GOTO  m029
			;                }
	DECF  m,1
	GOTO  m025
			;                
			;                for(m++ ; m < 5 ; m++)
m032	INCF  m,1
m033	MOVLW .5
	SUBWF m,W
	BTFSC 0x03,Carry
	GOTO  m039
			;                    putc(bin2Hex(decimal_output[m]));
	MOVLW .63
	ADDWF m,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  INDF,W
	CALL  bin2Hex
	CALL  putc
	INCF  m,1
	GOTO  m033
			;    
			;            } //End Decimal
			;            else if (k == 'h') //Print Hex
m034	MOVF  k,W
	XORLW .104
	BTFSS 0x03,Zero_
	GOTO  m036
			;            {
			;                //New trick 3-15-04
			;                putc('0');
	MOVLW .48
	CALL  putc
			;                putc('x');
	MOVLW .120
	CALL  putc
			;                
			;                if(my_byte > 0x00FF)
	BTFSC my_byte+1,7
	GOTO  m035
	MOVF  my_byte+1,1
	BTFSC 0x03,Zero_
	GOTO  m035
			;                {
			;                    putc(bin2Hex(my_byte.high8 >> 4));
	SWAPF my_byte+1,W
	ANDLW .15
	CALL  bin2Hex
	CALL  putc
			;                    putc(bin2Hex(my_byte.high8 & 0b.0000.1111));
	MOVLW .15
	ANDWF my_byte+1,W
	CALL  bin2Hex
	CALL  putc
			;                }
			;
			;                putc(bin2Hex(my_byte.low8 >> 4));
m035	SWAPF my_byte,W
	ANDLW .15
	CALL  bin2Hex
	CALL  putc
			;                putc(bin2Hex(my_byte.low8 & 0b.0000.1111));
	MOVLW .15
	ANDWF my_byte,W
	CALL  bin2Hex
	CALL  putc
			;
			;                /*high_byte.3 = my_byte.7;
			;                high_byte.2 = my_byte.6;
			;                high_byte.1 = my_byte.5;
			;                high_byte.0 = my_byte.4;
			;            
			;                low_byte.3 = my_byte.3;
			;                low_byte.2 = my_byte.2;
			;                low_byte.1 = my_byte.1;
			;                low_byte.0 = my_byte.0;
			;        
			;                putc('0');
			;                putc('x');
			;            
			;                putc(bin2Hex(high_byte));
			;                putc(bin2Hex(low_byte));*/
			;            } //End Hex
			;            else if (k == 'f') //Print Float
	GOTO  m039
m036	MOVF  k,W
	XORLW .102
	BTFSS 0x03,Zero_
	GOTO  m037
			;            {
			;                putc('!');
	MOVLW .33
	CALL  putc
			;            } //End Float
			;            else if (k == 'u') //Print Direct Character
	GOTO  m039
m037	MOVF  k,W
	XORLW .117
	BTFSS 0x03,Zero_
	GOTO  m039
			;            {
			;                //All ascii characters below 20 are special and screwy characters
			;                //if(my_byte > 20) 
			;                    putc(my_byte);
	MOVF  my_byte,W
	CALL  putc
			;            } //End Direct
			;                        
			;        } //End Special Chars           
			;
			;        else
	GOTO  m039
			;            putc(k);
m038	MOVF  k,W
	CALL  putc
			;    }    
m039	INCF  i,1
	GOTO  m018

  ; FILE D:\Pics\code\16F88\RF Test\RF-24G-256bit-Example.c
			;#include "d:\Pics\code\Stdio.c"     // Basic Serial IO
m040	RETURN
			;
			;#define TX_CE      PORTB.0
			;#define TX_CS      PORTB.1
			;#define TX_CLK1    PORTB.3
			;#define TX_DATA    PORTB.4
			;
			;#define RX_CE       PORTA.2
			;#define RX_CS       PORTA.3
			;#define RX_CLK1     PORTA.4
			;#define RX_DATA     PORTA.1
			;#define RX_DR       PORTA.0
			;
			;uns8 data_array[29];
			;uns8 counter;
			;uns8 packet_number;
			;
			;void boot_up(void);
			;void configure_receiver(void);
			;void configure_transmitter(void);
			;void transmit_data(void);
			;void receive_data(void);
			;
			;void main()
			;{
main
			;    uns8 i;
			;    uns16 elapsed_time;
			;
			;    packet_number = 0;
	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  packet_number
			;    counter = 0;
	CLRF  counter
			;    
			;    boot_up();
	BSF   0x03,RP0
	CALL  boot_up
			;
			;    while(1)
			;    {
			;        packet_number++;
m041	INCF  packet_number,1
			;        
			;        //Put some data in the ougoing array
			;        data_array[0] = packet_number;
	MOVF  packet_number,W
	MOVWF data_array
			;        for(i = 1 ; i < 29 ; i++)
	MOVLW .1
	MOVWF i_2
m042	MOVLW .29
	SUBWF i_2,W
	BTFSC 0x03,Carry
	GOTO  m043
			;            data_array[i] = ++counter;
	INCF  counter,1
	MOVLW .73
	ADDWF i_2,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  counter,W
	MOVWF INDF
	INCF  i_2,1
	GOTO  m042
			;
			;        transmit_data();
m043	CALL  transmit_data
			;    
			;        //Here we monitor how many clock cycles it takes for the receiver to register good data
			;        //elasped_time is in cycles - each cycles is 500ns at 8MHz so 541 cycles = 270.5us
			;        //==============================================
			;        TMR1IF = 0;
	BCF   0x0C,TMR1IF
			;        TMR1L = 0 ; TMR1H = 0 ; TMR1ON = 1;
	CLRF  TMR1L
	CLRF  TMR1H
	BSF   0x10,TMR1ON
			;        while(RX_DR == 0)
m044	BTFSC PORTA,0
	GOTO  m045
			;            if (TMR1IF == 1) break; //If timer1 rolls over waiting for data, then break
	BTFSS 0x0C,TMR1IF
	GOTO  m044
			;        TMR1ON = 0;
m045	BCF   0x10,TMR1ON
			;        elapsed_time.high8 = TMR1H;
	MOVF  TMR1H,W
	MOVWF elapsed_time+1
			;        elapsed_time.low8 = TMR1L;
	MOVF  TMR1L,W
	MOVWF elapsed_time
			;        //==============================================
			;        
			;        if(RX_DR == 1) //We have data!
	BTFSC PORTA,0
			;            receive_data();
	CALL  receive_data
			;        
			;        delay_ms(10); //Have a second between transmissions just for evaluation
	MOVLW .10
	MOVWF x_2
	CLRF  x_2+1
	CALL  delay_ms
			;    
			;    }
	GOTO  m041
			;        
			;}
			;
			;void boot_up(void)
			;{
boot_up
			;    OSCCON = 0b.0111.0000; //Setup internal oscillator for 8MHz
	MOVLW .112
	MOVWF OSCCON
			;    while(OSCCON.2 == 0); //Wait for frequency to stabilize
m046	BTFSS OSCCON,2
	GOTO  m046
			;
			;    ANSEL = 0b.0000.0000; //Turn pins to Digital instead of Analog
	CLRF  ANSEL
			;    CMCON = 0b.0000.0111; //Turn off comparator on RA port
	MOVLW .7
	MOVWF CMCON
			;
			;    PORTA = 0b.0000.0000;  
	BCF   0x03,RP0
	CLRF  PORTA
			;    TRISA = 0b.0000.0001;  //0 = Output, 1 = Input (RX_DR is on RA0)
	MOVLW .1
	BSF   0x03,RP0
	MOVWF TRISA
			;
			;    PORTB = 0b.0000.0000;  
	BCF   0x03,RP0
	CLRF  PORTB
			;    TRISB = 0b.0000.0100;  //0 = Output, 1 = Input (RX is an input)
	MOVLW .4
	BSF   0x03,RP0
	MOVWF TRISB
			;
			;    enable_uart_TX(0); //Setup the hardware UART for 20MHz at 9600bps
	BCF   0x03,RP0
	BCF   0x23,want_ints
	BSF   0x03,RP0
	CALL  enable_uart_TX
			;    enable_uart_RX(0); //Take a look at header files - it's not that hard to setup the UART
	BCF   0x03,RP0
	BCF   0x23,want_ints_2
	BSF   0x03,RP0
	CALL  enable_uart_RX
			;    
			;    printf("\n\rRF-24G Testing:\n\r", 0);
	CLRF  nate_2
	CLRF  my_byte
	CLRF  my_byte+1
	CALL  printf
			;    
			;    delay_ms(100);
	MOVLW .100
	MOVWF x_2
	CLRF  x_2+1
	CALL  delay_ms
			;
			;    configure_transmitter();
	CALL  configure_transmitter
			;    configure_receiver();
	GOTO  configure_receiver
			;}
			;
			;//This will clock out the current payload into the data_array
			;void receive_data(void)
			;{
receive_data
			;    uns8 i, j, temp;
			;
			;    RX_CE = 0;//Power down RF Front end
	BCF   PORTA,2
			;
			;    //Erase the current data array so that we know we are looking at actual received data
			;    for(i = 0 ; i < 29 ; i++)
	CLRF  i_3
m047	MOVLW .29
	SUBWF i_3,W
	BTFSC 0x03,Carry
	GOTO  m048
			;        data_array[i] = 0x00;
	MOVLW .73
	ADDWF i_3,W
	MOVWF FSR
	BCF   0x03,IRP
	CLRF  INDF
	INCF  i_3,1
	GOTO  m047
			;
			;    //Clock out the data
			;    for(i = 0 ; i < 29 ; i++) //29 bytes
m048	CLRF  i_3
m049	MOVLW .29
	SUBWF i_3,W
	BTFSC 0x03,Carry
	GOTO  m052
			;    {
			;        for(j = 0 ; j < 8 ; j++) //8 bits each
	CLRF  j
m050	MOVLW .8
	SUBWF j,W
	BTFSC 0x03,Carry
	GOTO  m051
			;        {
			;            temp <<= 1;
	BCF   0x03,Carry
	RLF   temp_2,1
			;            temp.0 = RX_DATA;
	BCF   temp_2,0
	BTFSC PORTA,1
	BSF   temp_2,0
			;
			;            RX_CLK1 = 1;
	BSF   PORTA,4
			;            RX_CLK1 = 0;
	BCF   PORTA,4
			;            
			;        }
	INCF  j,1
	GOTO  m050
			;
			;        data_array[i] = temp; //Store this byte
m051	MOVLW .73
	ADDWF i_3,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  temp_2,W
	MOVWF INDF
			;    }
	INCF  i_3,1
	GOTO  m049
			;    
			;    //if(RX_DR == 0) //Once the data is clocked completely, the receiver should make DR go low
			;    //    printf("DR went low\n\r", 0);
			;    
			;    printf("Received packet %d\n\r", data_array[0]);
m052	MOVLW .20
	MOVWF nate_2
	MOVF  data_array,W
	MOVWF my_byte
	CLRF  my_byte+1
	CALL  printf
			;    //This prints out the entire array - very large!
			;    /*
			;    printf("\n\rData Received:\n\r", 0);
			;    for(i = 0 ; i < 29 ; i++)
			;    {
			;        printf("[%d]", i);
			;        printf(" : %h - ", data_array[i]);
			;    }
			;    */
			;    
			;
			;    RX_CE = 1; //Power up RF Front end
	BSF   PORTA,2
			;}
	RETURN
			;
			;//This sends out the data stored in the data_array
			;//data_array must be setup before calling this function
			;void transmit_data(void)
			;{
transmit_data
			;    uns8 i, j, temp, rf_address;
			;
			;    TX_CE = 1;
	BSF   PORTB,0
			;
			;    //Clock in address
			;    rf_address = 17;
	MOVLW .17
	MOVWF rf_address
			;    for(i = 0 ; i < 8 ; i++)
	CLRF  i_4
m053	MOVLW .8
	SUBWF i_4,W
	BTFSC 0x03,Carry
	GOTO  m054
			;    {
			;        TX_DATA = rf_address.7;
	BTFSS rf_address,7
	BCF   PORTB,4
	BTFSC rf_address,7
	BSF   PORTB,4
			;        TX_CLK1 = 1;
	BSF   PORTB,3
			;        TX_CLK1 = 0;
	BCF   PORTB,3
			;        
			;        rf_address <<= 1;
	BCF   0x03,Carry
	RLF   rf_address,1
			;    }
	INCF  i_4,1
	GOTO  m053
			;    
			;    //Clock in the data_array
			;    for(i = 0 ; i < 29 ; i++) //29 bytes
m054	CLRF  i_4
m055	MOVLW .29
	SUBWF i_4,W
	BTFSC 0x03,Carry
	GOTO  m058
			;    {
			;        temp = data_array[i];
	MOVLW .73
	ADDWF i_4,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  INDF,W
	MOVWF temp_3
			;        
			;        for(j = 0 ; j < 8 ; j++) //One bit at a time
	CLRF  j_2
m056	MOVLW .8
	SUBWF j_2,W
	BTFSC 0x03,Carry
	GOTO  m057
			;        {
			;            TX_DATA = temp.7;
	BTFSS temp_3,7
	BCF   PORTB,4
	BTFSC temp_3,7
	BSF   PORTB,4
			;            TX_CLK1 = 1;
	BSF   PORTB,3
			;            TX_CLK1 = 0;
	BCF   PORTB,3
			;            
			;            temp <<= 1;
	BCF   0x03,Carry
	RLF   temp_3,1
			;        }
	INCF  j_2,1
	GOTO  m056
			;    }
m057	INCF  i_4,1
	GOTO  m055
			;    
			;    TX_CE = 0; //Start transmission   
m058	BCF   PORTB,0
			;}
	RETURN
			;
			;//2.4G Configuration - Receiver
			;//This setups up a RF-24G for receiving at 1mbps
			;void configure_receiver(void)
			;{
configure_receiver
			;    uns8 i, j, temp;
			;    uns8 config_setup[14];
			;
			;    //During configuration of the receiver, we need RX_DATA as an output
			;    PORTA = 0b.0000.0000;  
	CLRF  PORTA
			;    TRISA = 0b.0000.0001;  //0 = Output, 1 = Input (RX_DR is on RA0) (RX_DATA is on RA1)
	MOVLW .1
	BSF   0x03,RP0
	MOVWF TRISA
			;
			;    //Config Mode
			;    RX_CE = 0; RX_CS = 1;
	BCF   0x03,RP0
	BCF   PORTA,2
	BSF   PORTA,3
			;    
			;    //Setup configuration array
			;    //===================================================================
			;    //Data bits 111-104 Max data width on channel 1 (excluding CRC and adrs) is 232
			;    config_setup[0] = 232;
	MOVLW .232
	MOVWF config_setup
			;
			;    //Data bits 103-64 Channel 2 address - we don't care, set it to 200 
			;    config_setup[1] = 0;
	CLRF  config_setup+1
			;    config_setup[2] = 0;
	CLRF  config_setup+2
			;    config_setup[3] = 0;
	CLRF  config_setup+3
			;    config_setup[4] = 0;
	CLRF  config_setup+4
			;    config_setup[5] = 200;
	MOVLW .200
	MOVWF config_setup+5
			;
			;    //Data bits 63-24 Channel 1 address - set it to 17
			;    config_setup[6] = 0;
	CLRF  config_setup+6
			;    config_setup[7] = 0;
	CLRF  config_setup+7
			;    config_setup[8] = 0;
	CLRF  config_setup+8
			;    config_setup[9] = 0;
	CLRF  config_setup+9
			;    config_setup[10] = 17;
	MOVLW .17
	MOVWF config_setup+10
			;    
			;    //Data bits 23-16 Address width and CRC
			;    config_setup[11] = 0b.0010.0011;
	MOVLW .35
	MOVWF config_setup+11
			;    
			;    //Data bits 15-8 
			;    config_setup[12] = 0b.0100.1101;
	MOVLW .77
	MOVWF config_setup+12
			;    
			;    //Data bits 7-0
			;    config_setup[13] = 0b.0000.1101;
	MOVLW .13
	MOVWF config_setup+13
			;    //===================================================================
			;
			;    //Clock in configuration data
			;    for(i = 0 ; i < 14 ; i++)
	CLRF  i_5
m059	MOVLW .14
	SUBWF i_5,W
	BTFSC 0x03,Carry
	GOTO  m062
			;    {
			;        temp = config_setup[i];
	MOVLW .38
	ADDWF i_5,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  INDF,W
	MOVWF temp_4
			;        
			;        for(j = 0 ; j < 8 ; j++)
	CLRF  j_3
m060	MOVLW .8
	SUBWF j_3,W
	BTFSC 0x03,Carry
	GOTO  m061
			;        {   
			;            RX_DATA = temp.7;
	BTFSS temp_4,7
	BCF   PORTA,1
	BTFSC temp_4,7
	BSF   PORTA,1
			;            RX_CLK1 = 1;
	BSF   PORTA,4
			;            RX_CLK1 = 0;
	BCF   PORTA,4
			;        
			;            temp <<= 1;
	BCF   0x03,Carry
	RLF   temp_4,1
			;        }
	INCF  j_3,1
	GOTO  m060
			;    }
m061	INCF  i_5,1
	GOTO  m059
			;    
			;    //Configuration is actived on falling edge of CS (page 10)
			;    RX_CE = 0; RX_CS = 0;
m062	BCF   PORTA,2
	BCF   PORTA,3
			;
			;    //After configuration of the receiver, we need RX_DATA as an input
			;    PORTA = 0b.0000.0000;  
	CLRF  PORTA
			;    TRISA = 0b.0000.0011;  //0 = Output, 1 = Input (RX_DR is on RA0) (RX_DATA is on RA1)
	MOVLW .3
	BSF   0x03,RP0
	MOVWF TRISA
			;
			;    //Start monitoring the air
			;    RX_CE = 1; RX_CS = 0;
	BCF   0x03,RP0
	BSF   PORTA,2
	BCF   PORTA,3
			;
			;    printf("RX Configuration finished...\n\r", 0);
	MOVLW .41
	MOVWF nate_2
	CLRF  my_byte
	CLRF  my_byte+1
	GOTO  printf
			;
			;}    
			;
			;//2.4G Configuration - Transmitter
			;//This sets up one RF-24G for shockburst transmission
			;void configure_transmitter(void)
			;{
configure_transmitter
			;    uns8 i, j, temp;
			;    uns8 config_setup[14];
			;
			;    //Config Mode
			;    TX_CE = 0; TX_CS = 1;
	BCF   PORTB,0
	BSF   PORTB,1
			;    
			;    //Setup configuration array
			;    //===================================================================
			;    //Data bits 111-104 Max data width on channel 1 (excluding CRC and adrs) is 232
			;    config_setup[0] = 232;
	MOVLW .232
	MOVWF config_setup_2
			;
			;    //Data bits 103-64 Channel 2 address - we don't care, set it to 200 
			;    config_setup[1] = 0;
	CLRF  config_setup_2+1
			;    config_setup[2] = 0;
	CLRF  config_setup_2+2
			;    config_setup[3] = 0;
	CLRF  config_setup_2+3
			;    config_setup[4] = 0;
	CLRF  config_setup_2+4
			;    config_setup[5] = 200;
	MOVLW .200
	MOVWF config_setup_2+5
			;
			;    //Data bits 63-24 Channel 1 address - set it to 17
			;    config_setup[6] = 0;
	CLRF  config_setup_2+6
			;    config_setup[7] = 0;
	CLRF  config_setup_2+7
			;    config_setup[8] = 0;
	CLRF  config_setup_2+8
			;    config_setup[9] = 0;
	CLRF  config_setup_2+9
			;    config_setup[10] = 17;
	MOVLW .17
	MOVWF config_setup_2+10
			;    
			;    //Data bits 23-16 Address width and CRC
			;    config_setup[11] = 0b.0010.0011;
	MOVLW .35
	MOVWF config_setup_2+11
			;    
			;    //Data bits 15-8 
			;    config_setup[12] = 0b.0100.1101;
	MOVLW .77
	MOVWF config_setup_2+12
			;    
			;    //Data bits 7-0
			;    config_setup[13] = 0b.0000.1100;
	MOVLW .12
	MOVWF config_setup_2+13
			;    //===================================================================
			;
			;    //Clock in configuration data
			;    for(i = 0 ; i < 14 ; i++)
	CLRF  i_6
m063	MOVLW .14
	SUBWF i_6,W
	BTFSC 0x03,Carry
	GOTO  m066
			;    {
			;        temp = config_setup[i];
	MOVLW .38
	ADDWF i_6,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  INDF,W
	MOVWF temp_5
			;        
			;        for(j = 0 ; j < 8 ; j++)
	CLRF  j_4
m064	MOVLW .8
	SUBWF j_4,W
	BTFSC 0x03,Carry
	GOTO  m065
			;        {   
			;            TX_DATA = temp.7;
	BTFSS temp_5,7
	BCF   PORTB,4
	BTFSC temp_5,7
	BSF   PORTB,4
			;            TX_CLK1 = 1;
	BSF   PORTB,3
			;            TX_CLK1 = 0;
	BCF   PORTB,3
			;        
			;            temp <<= 1;
	BCF   0x03,Carry
	RLF   temp_5,1
			;        }
	INCF  j_4,1
	GOTO  m064
			;    }
m065	INCF  i_6,1
	GOTO  m063
			;    
			;    //Configuration is actived on falling edge of CS (page 10)
			;    TX_CE = 0; TX_CS = 0;
m066	BCF   PORTB,0
	BCF   PORTB,1
			;
			;    printf("TX Configuration finished...\n\r", 0);
	MOVLW .72
	MOVWF nate_2
	CLRF  my_byte
	CLRF  my_byte+1
	GOTO  printf
			;}

	END


; *** KEY INFO ***

; 0x008B P0    9 word(s)  0 % : delay_us
; 0x0094 P0   24 word(s)  1 % : delay_ms
; 0x00AC P0   26 word(s)  1 % : delay_s_lp
; 0x00C6 P0   15 word(s)  0 % : enable_uart_TX
; 0x00D5 P0   13 word(s)  0 % : enable_uart_RX
; 0x00E2 P0    6 word(s)  0 % : putc
; 0x00E8 P0    6 word(s)  0 % : getc
; 0x00EE P0   20 word(s)  0 % : bin2Hex
; 0x0102 P0  185 word(s)  9 % : printf
; 0x0004 P0   83 word(s)  4 % : _const1
; 0x01E8 P0   35 word(s)  1 % : boot_up
; 0x026B P0   69 word(s)  3 % : configure_receiver
; 0x02B0 P0   57 word(s)  2 % : configure_transmitter
; 0x023B P0   48 word(s)  2 % : transmit_data
; 0x020B P0   48 word(s)  2 % : receive_data
; 0x01BB P0   45 word(s)  2 % : main

; RAM usage: 72 bytes (41 local), 296 bytes free
; Maximum call level: 3
;  Codepage 0 has  742 word(s) :  36 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 690 code words (16 %)
