#include <MMAC.h>

module HplJn516RadioTransmitP {
	provides {
		interface HplJn516RadioTransmit;
	}
	uses {
		interface HplJn516RadioComm;
	}
}
implementation {

	message_t* tx_msg;
	tsMacFrame* tx_frame;
	error_t tx_error;

	void startTransmit();

	command error_t HplJn516RadioTransmit.transmit(message_t* msg) {
		tx_msg = msg;
		startTransmit();
		return SUCCESS;
	}

	command error_t HplJn516RadioTransmit.transmitMMAC(tsMacFrame* frame) {
		tx_frame = frame;
		startTransmit();
		return SUCCESS;
	}

	event void HplJn516RadioComm.txFrame() {
		signal HplJn516RadioTransmit.transmitDone(tx_msg,tx_error);
	}

	event void HplJn516RadioComm.rxFrame() {}

	void startTransmit() {
		vMMAC_StartMacTransmit(tx_frame,E_MMAC_TX_START_NOW|E_MMAC_TX_NO_AUTO_ACK|E_MMAC_TX_NO_CCA);
	}

}
