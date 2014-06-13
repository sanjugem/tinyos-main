/*
 *	start in RX state, change to TX state when sending, after sending go back to RX state
 */

#include <Ieee154.h>

module Jn516NoMacP {
	provides {
		interface SplitControl;
		interface Send;
		interface Receive;
	}
	uses {
		interface HalJn516Radio;
		interface State as SplitControlState;
		interface Jn516Packet;
		interface Jn516PacketBody;
		interface Jn516PacketTransform;
	}
}
implementation {

	enum {
		S_STOPPED,
		S_STARTING,
		S_STARTED,
		S_STOPPING,
		S_TRANSMITTING,
	};

	message_t* ONE_NOK m_msg;
	tsMacFrame
	error_t sendErr = SUCCESS;

	/***************** SplitControl ****************/
	event void HplJn516RadioControl.started() {
		call SplitControlState.forceState(S_STARTED);
	}

	command error_t SplitControl.start() {
		if(call SplitControlState.requestState(S_STARTING) == SUCCESS)
		{
			call HplJn516Radio.start(21);
			return SUCCESS;
		} 
		else if(call SplitControlState.isState(S_STARTED)) 
		{
			return EALREADY;
		} 
		else if(call SplitControlState.isState(S_STARTING)) 
		{
			return SUCCESS;
		}
		return EBUSY;
	}

	event void HplJn516Radio.stopped() {
		call SplitControlState.forceState(S_STOPPED);
	}

	command error_t SplitControl.stop() {
		if (call SplitControlState.isState(S_STARTED)) 
		{
			call HplJn516RadioControl.stop();
			call SplitControlState.forceState(S_STOPPING);
			return SUCCESS;
		} 
		else if(call SplitControlState.isState(S_STOPPED)) 
		{
			return EALREADY;
		} 
		else if(call SplitControlState.isState(S_TRANSMITTING)) 
		{
			call SplitControlState.forceState(S_STOPPING);
			return SUCCESS;
		} 
		else if(call SplitControlState.isState(S_STOPPING)) 
		{
			return SUCCESS;
		}
		return EBUSY;
	}

	/***************** Send ****************/

	command error_t Send.cancel( message_t* p_msg ) {
		return FAIL;
	}

	command error_t Send.send( message_t* p_msg, uint8_t len ) {
		jn516_header_t* header = call Jn516PacketBody.getHeader( p_msg );
		jn516_metadata_t* metadata = call Jn516PacketBody.getMetadata( p_msg );
		
		atomic {
			if (!call SplitControlState.isState(S_STARTED)) {
				return FAIL;
			}

			call SplitControlState.forceState(S_TRANSMITTING);
			m_msg = p_msg;
		}

		header->fcf &= ( (1 << IEEE154_FCF_ACK_REQ)| 
						(0x3 << IEEE154_FCF_SRC_ADDR_MODE)|
						(0x3 << IEEE154_FCF_DEST_ADDR_MODE) );
		header->fcf |= ( ( IEEE154_TYPE_DATA << IEEE154_FCF_FRAME_TYPE ) |
						( 1 << IEEE154_FCF_INTRAPAN ) ); 

		metadata->ack = FALSE;
		metadata->rssi = 0;
		metadata->lqi = 0;
		metadata->timestamp = Jn516_INVALID_TIMESTAMP;

		call HplJn516Radio.transmit( m_msg );
		return SUCCESS;
	}

	command void* Send.getPayload(message_t* m, uint8_t len) {
		if (len <= call Send.maxPayloadLength()) {
			return (void* COUNT_NOK(len ))(m->data);
		}
		else {
			return NULL;
		}
	}

	command uint8_t Send.maxPayloadLength() {
		return TOSH_DATA_LENGTH;
	}


	task void sendDone_task() {
		error_t packetErr;
		atomic packetErr = sendErr;
		if(call SplitControlState.isState(S_STOPPING)) {
		} else {
			call HplJn516RadioReceive.startReceive();
			call SplitControlState.forceState(S_STARTED);
		}

		signal Send.sendDone( m_msg, packetErr );
	}

	event void HplJn516RadioTransmit.transmitDone( message_t* p_msg, error_t err ) {
		atomic sendErr = err;
		post sendDone_task();
	}



	/***************** Receive ****************/
	event message_t* HplJn516RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
		signal Receive.receive(msg, payload, len);
		return msg;
	};
	
}
