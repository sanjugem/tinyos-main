#include <AppHardwareApi.h>
#include "HalTimer.h"

configuration PlatformSerialC {

	provides interface StdControl;
  	provides interface UartStream;
 	provides interface UartByte;

}
implementation {
	/*components PlatformSerialP;
	StdControl = PlatformSerialP;  
	UartByte = PlatformSerialP;*/
	components Jn516Uart0C as UartC;
	StdControl = UartC;
	UartStream = UartC;
	UartByte = UartC;

	//components new Counter32khz8C() as Jn516Counter;
	//UartC.Counter -> Jn516Counter;
	
}
