interface HplJn516RadioControl {
//	command void setChannel(uint8_t ch);
	command error_t start(uint8_t ch);
	event void started();
	command error_t stop();
	event void stopped();
}
