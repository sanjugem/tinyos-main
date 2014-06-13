#include <MMAC.h>

module HplJn516RadioReceiveP {
	provides {
		interface HplJn516RadioReceive;
	}
	uses {
		interface HplJn516RadioComm;
	}
}
implementation {

	message_t* rx_msg;
	tsMacFrame rx_frame;
	error_t rx_error;
	void* rx_payload;
	void ReceiveCallback(uint32_t bitmap);

	event void HplJn516RadioComm.txFrame() {}

	event void HplJn516RadioComm.rxFrame() {
		
		signal HplJn516RadioReceive.receive(rx_msg,rx_payload,0);		
	}

	command error_t HplJn516RadioReceive.startReceive() {
		vMMAC_StartMacReceive(&rx_frame,E_MMAC_RX_START_NOW|E_MMAC_RX_NO_AUTO_ACK);
		return SUCCESS;
	}
}
