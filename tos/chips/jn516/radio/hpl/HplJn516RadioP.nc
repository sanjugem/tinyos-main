#include <MMAC.h>

module HplJn516RadioP {
	provides {
		interface HplJn516Radio;
	}
}
implementation {

	uint8_t channel;

	tsMacFrame* tx_frame;
	error_t tx_error;

	tsMacFrame rx_frame;
	error_t rx_error;


	//control

	void RadioCallback(uint32_t bitmap) {
		if(bitmap & E_MMAC_INT_TX_COMPLETE)
			signal HplJn516Radio.transmitDoneMMAC(tx_frame,tx_error);
		if(bitmap & E_MMAC_INT_RX_COMPLETE) {
			signal HplJn516Radio.receive(&rx_frame,rx_frame.u8PayloadLength,SUCCESS);
		}
	}

	task void startRadio() {
		vMMAC_Enable();
		vMMAC_EnableInterrupts(RadioCallback);
		vMMAC_ConfigureRadio();
		vMMAC_SetChannel(channel);
		signal HplJn516Radio.started();
	}

	command error_t HplJn516Radio.start(uint8_t ch) {
		channel = ch;
		post startRadio();
		return SUCCESS;
	}

	command error_t HplJn516Radio.stop() {
		vMMAC_RadioOff();
		signal HplJn516Radio.stopped();
		return SUCCESS;
	}


	//transmit

	void startTransmit() {
		vMMAC_StartMacTransmit(tx_frame,E_MMAC_TX_START_NOW|E_MMAC_TX_NO_AUTO_ACK|E_MMAC_TX_NO_CCA);
	}

	command error_t HplJn516Radio.transmitMMAC(tsMacFrame* frame) {
		tx_frame = frame;
		startTransmit();
		return SUCCESS;
	}


	//receive

	command error_t HplJn516Radio.startReceive() {
		vMMAC_StartMacReceive(&rx_frame,E_MMAC_RX_START_NOW|E_MMAC_RX_NO_AUTO_ACK);
		return SUCCESS;
	}

}

