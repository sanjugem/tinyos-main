/*
 * "Copyright (c) 2005 Stanford University. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose, without fee, and without written
 * agreement is hereby granted, provided that the above copyright
 * notice, the following two paragraphs and the author appear in all
 * copies of this software.
 * 
 * IN NO EVENT SHALL STANFORD UNIVERSITY BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
 * ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN
 * IF STANFORD UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 * 
 * STANFORD UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE
 * PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND STANFORD UNIVERSITY
 * HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
 * ENHANCEMENTS, OR MODIFICATIONS."
 */

/**
 * Radio wiring for the Jn516.  This layer seperates the common
 * wiring of the lower-layer components of the Jn516 stack and makes
 * them available to clients like the AM stack and the IEEE802.15.4
 * stack.
 *
 * This component provides the highest-level internal interface to
 * other components of the Jn516 stack.
 *
 * @author Philip Levis
 * @author David Moss
 * @author Stephen Dawson-Haggerty
 * @version $Revision: 1.2 $ $Date: 2009/08/20 01:37:44 $
 */

#include "Jn516.h"

configuration Jn516RadioC {
	provides {
		interface SplitControl;

		interface Resource[uint8_t clientId];
		interface Send as BareSend;
		interface Receive as BareReceive;
		interface Packet as BarePacket;

		interface Send    as ActiveSend;
		interface Receive as ActiveReceive;

		interface Jn516Packet;
		interface PacketAcknowledgements;
		interface LinkPacketMetadata;
		interface LowPowerListening;
		interface PacketLink;
	}
}
implementation {

	//  components Jn516CsmaC as CsmaC;
	components Jn516NoMacC as NoMacC;
	components UniqueSendC;
	components UniqueReceiveC;
	components Jn516TinyosNetworkC;
	components Jn516PacketC;
	components Jn516ControlC;

	components DummyLplC as LplC;


	components HplJn516RadioControlP as HplRadioControl;
	components HplJn516RadioTransmitP as HplRadioTransmit;
	components HplJn516RadioReceiveP as HplRadioReceive;

	NoMacC.HplJn516RadioControl -> HplRadioControl;
 	NoMacC.HplJn516RadioTransmit -> HplRadioTransmit;
	NoMacC.HplJn516RadioReceive -> HplRadioReceive;
	HplRadioTransmit.HplJn516RadioComm -> HplRadioControl;
	HplRadioReceive.HplJn516RadioComm -> HplRadioControl;


#if defined(PACKET_LINK)
	components PacketLinkC as LinkC;
#else
	components PacketLinkDummyC as LinkC;
#endif

	PacketLink = LinkC;
	LowPowerListening = LplC;
	Jn516Packet = Jn516PacketC;
	PacketAcknowledgements = Jn516PacketC;
	LinkPacketMetadata = Jn516PacketC;

	Resource = Jn516TinyosNetworkC;
	BareSend = Jn516TinyosNetworkC.Send;
	BareReceive = Jn516TinyosNetworkC.Receive;
	BarePacket = Jn516TinyosNetworkC.BarePacket;

	ActiveSend = Jn516TinyosNetworkC.ActiveSend;
	ActiveReceive = Jn516TinyosNetworkC.ActiveReceive;

	// SplitControl Layers
	SplitControl = LplC;
	LplC.SubControl -> NoMacC;

	// Send Layers
	Jn516TinyosNetworkC.SubSend -> UniqueSendC;
	UniqueSendC.SubSend -> LinkC;
	LinkC.SubSend -> LplC.Send;
	LplC.SubSend -> NoMacC;

	// Receive Layers
	Jn516TinyosNetworkC.SubReceive -> LplC;
	LplC.SubReceive -> UniqueReceiveC.Receive;
	UniqueReceiveC.SubReceive ->  NoMacC;

}
