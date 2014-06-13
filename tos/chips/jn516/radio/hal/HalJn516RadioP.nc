#include <MMAC.h>

module HalJn516RadioP {
	provides {
		interface HalJn516Radio;
	}
}
implementation {


	//control

	command error_t HalJn516Radio.start(uint8_t ch) {
		return SUCCESS;
	}

	command error_t HalJn516Radio.stop() {
		vMMAC_RadioOff();
		signal HalJn516Radio.stopped();
		return SUCCESS;
	}


	//transmit

	command error_t HalJn516Radio.transmit(message_t* msg) {
		tx_frame = frame;
		startTransmit();
		return SUCCESS;
	}


	//receive

}

