/* 
 * @author Tim Bormann
 * @author Sanjeet Raj Pandey
 *
 * @author Jennic SDK basic test app
 */

#include <jendefs.h>
#include <AppHardwareApi.h>

module PlatformP
{ 
	provides interface Init;
	uses interface Init as LedsInit;
	uses interface Init as Jn516TimerInit;
}
implementation {

	command error_t Init.init() {
		/* Turn off debugger */
		int n;
		*(uint32_t *)0x020000a0 = 0;

		#ifdef WATCHDOG_ENABLED
		/* Disable watchdog if enabled by default */
		vAHI_WatchdogStop();
		#endif

		u32AHI_Init();                              /* initialise hardware API */

		for(n=0;n<100000;n++);		// wait for JN516X to move onto 32MHz Crystal

		vAHI_DioSetPullup(0xffffffff, 0x00000000);  /* turn all pullups on      */

		call LedsInit.init();

		call Jn516TimerInit.init();

		return SUCCESS;
	}

	default command error_t LedsInit.init() { return SUCCESS; }
}
