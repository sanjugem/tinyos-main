interface HplJn516Radio {
//control
	command error_t start(uint8_t ch);
	event void started();
	command error_t stop();
	event void stopped();
//transmit
	command error_t transmitMMAC(tsMacFrame* frame);
	event void transmitDoneMMAC(tsMacFrame* frame, error_t error);
//receive
	command error_t startReceive();
	event tsMacFrame* receive(tsMacFrame* frame, uint8_t payload_len, error_t error);
}
