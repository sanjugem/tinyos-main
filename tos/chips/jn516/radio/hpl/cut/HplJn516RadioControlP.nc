#include <MMAC.h>

module HplJn516RadioControlP {
	provides {
		interface HplJn516RadioControl;
		interface HplJn516RadioComm;
	}
}
implementation {

	uint8_t channel;

	void RadioCallback(uint32_t bitmap) {
		if(bitmap & E_MMAC_INT_TX_COMPLETE)
			signal HplJn516RadioComm.txFrame();
		if(bitmap & E_MMAC_INT_RX_COMPLETE)
			signal HplJn516RadioComm.rxFrame();
	}

	task void startRadio() {
		vMMAC_Enable();
		vMMAC_EnableInterrupts(RadioCallback);
		vMMAC_ConfigureRadio();
		vMMAC_SetChannel(channel);
		signal HplJn516RadioControl.started();
	}

	command error_t HplJn516RadioControl.start(uint8_t ch) {
		channel = ch;
		post startRadio();
		return SUCCESS;
	}

	command error_t HplJn516RadioControl.stop() {
		vMMAC_RadioOff();
		signal HplJn516RadioControl.stopped();
		return SUCCESS;
	}

//	command void HplJn516RadioControl.setChannel(uint8_t ch) {
//		channel = ch;
//	}
}
