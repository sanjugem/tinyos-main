interface Jn516RadioTransmit {
	command error_t transmit(message_t* msg);
	event void transmitDone(message_t* msg, error_t error);
}
