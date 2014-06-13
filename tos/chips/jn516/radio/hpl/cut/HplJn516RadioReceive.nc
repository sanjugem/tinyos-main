interface HplJn516RadioReceive {
	command error_t startReceive();
	event message_t* receive(message_t* msg, uint8_t payload_len);
}
