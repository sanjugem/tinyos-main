#include <jendefs.h>
#include <AppHardwareApi.h>

module PlatformSerialP {
	provides interface StdControl;
	provides interface UartByte;
}
implementation {

	/*#define UART 		E_AHI_UART_0
	#define BAUD		E_AHI_UART_RATE_38400
	#define BUFFER_LEN 	256

	uint8_t tx_buffer[BUFFER_LEN];
	uint8_t rx_buffer[BUFFER_LEN];

	command error_t StdControl.start() {
		bool init_success = bAHI_UartEnable(UART, tx_buffer, BUFFER_LEN, tx_buffer,BUFFER_LEN);
		vAHI_UartSetBaudRate(UART, BAUD);
		if(init_success)
			return SUCCESS;
		else
			return FAIL;
	}

	command error_t StdControl.stop() {
		vAHI_UartDisable(UART);
		return SUCCESS;
	}

	async command error_t UartByte.send( uint8_t byte ) {
		vAHI_UartWriteData(UART, byte);
		return FAIL;
	}

	async command error_t UartByte.receive( uint8_t* byte, uint8_t timeout ) {
		return FAIL;
	}
	*/
}
