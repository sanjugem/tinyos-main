interface HalJn516Radio {
//control
	command error_t start(uint8_t ch);
	event void started();
	command error_t stop();
	event void stopped();
//transmit
	command error_t transmit(message_t* msg);
	event void transmitDone(message_t* msg, error_t error);
//receive
	command error_t startReceive();
	event message_t* receive(message_t* msg, uint8_t payload_len, error_t error);
}
