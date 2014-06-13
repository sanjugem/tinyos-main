/*
 * Copyright (c) 2005 Stanford University. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holder nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * The Active Message layer for the Jn516 radio. This configuration
 * just layers the AM dispatch (Jn516ActiveMessageM) on top of the
 * underlying Jn516 radio packet (Jn516CsmaCsmaCC), which is
 * inherently an AM packet (acknowledgements based on AM destination
 * addr and group). Note that snooping may not work, due to Jn516
 * early packet rejection if acknowledgements are enabled.
 *
 * @author Philip Levis
 * @author David Moss
 * @version $Revision: 1.16 $ $Date: 2010-06-29 22:07:44 $
 */

#include "Jn516.h"
#include "AM.h"
#include "Ieee154.h"

#ifdef IEEE154FRAMES_ENABLED
#error "Jn516 AM layer cannot work when IEEE 802.15.4 frames only are used"
#endif

configuration Jn516ActiveMessageC {
  provides {
    interface SplitControl;
    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
    interface Receive as Snoop[am_id_t id];
    interface AMPacket;
    interface Packet;
    interface Jn516Packet;
    interface PacketAcknowledgements;
    interface LinkPacketMetadata;
    interface RadioBackoff[am_id_t amId];
    interface LowPowerListening;
    interface PacketLink;
    interface SendNotifier[am_id_t amId];
  }
}
implementation {
  enum {
    Jn516_AM_SEND_ID     = unique(RADIO_SEND_RESOURCE),
  };

  components Jn516RadioC as Radio;
  components Jn516ActiveMessageP as AM;
  components ActiveMessageAddressC;
  components Jn516CsmaC as CsmaC;
  components Jn516ControlC;
  components Jn516PacketC;
  
  SplitControl = Radio;
  RadioBackoff = AM;
  Packet = AM;
  AMSend = AM;
  SendNotifier = AM;
  Receive = AM.Receive;
  Snoop = AM.Snoop;
  AMPacket = AM;
  PacketLink = Radio;
  LowPowerListening = Radio;
  Jn516Packet = Radio;
  PacketAcknowledgements = Radio;
  LinkPacketMetadata = Radio;
  
  // Radio resource for the AM layer
  AM.RadioResource -> Radio.Resource[Jn516_AM_SEND_ID];
  AM.SubSend -> Radio.ActiveSend;
  AM.SubReceive -> Radio.ActiveReceive;

  AM.ActiveMessageAddress -> ActiveMessageAddressC;
  AM.Jn516Packet -> Jn516PacketC;
  AM.Jn516PacketBody -> Jn516PacketC;
  AM.Jn516Config -> Jn516ControlC;
  
  AM.SubBackoff -> CsmaC;

  components LedsC;
  AM.Leds -> LedsC;
}
