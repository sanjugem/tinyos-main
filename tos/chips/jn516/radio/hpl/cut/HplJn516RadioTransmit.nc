#include <MMAC.h>

interface HplJn516RadioTransmit {
	command error_t transmitMMAC(tsMacFrame* frame);
	event void transmitDoneMMAC(tsMacFrame* frame, error_t error);
}
