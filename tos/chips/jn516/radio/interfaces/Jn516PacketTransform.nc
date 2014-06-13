#include "message.h"
#include <MMAC.h>

interface Jn516PacketTransform {
	command error_t TosToMMAC(message_t* from, tsMacFrame* to);
	command error_t MMACToTos(tsMacFrame* from, message_t* to);
}
