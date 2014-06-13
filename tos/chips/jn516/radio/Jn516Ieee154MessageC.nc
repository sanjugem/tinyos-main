/*
 * Copyright (c) 2008 The Regents of the University  of California.
 * All rights reserved."
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
 * - Neither the name of the copyright holders nor the names of
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
 *
 */
/*									tab:4
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
 * IEEE 802.15.4 layer for the jn516.  Provides a simplistic 
 *       link layer with dispatching on the 6lowpan "network" field
 *
 * @author Philip Levis
 * @author David Moss
 * @author Stephen Dawson-Haggerty
 * @version $Revision: 1.2 $ $Date: 2010-06-29 22:07:44 $
 */

#include "Jn516.h"
#ifdef TFRAMES_ENABLED
#error "The Jn516 Ieee 802.15.4 layer does not work with TFRAMES"
#endif

configuration Jn516Ieee154MessageC {
  provides {
    interface SplitControl;

    interface Resource as SendResource[uint8_t clientId];
    interface Ieee154Send;
    interface Receive as Ieee154Receive;

    interface Ieee154Packet;
    interface Packet;

    interface Jn516Packet;
    interface PacketAcknowledgements;
    interface LinkPacketMetadata;
    interface LowPowerListening;
    interface Jn516Config;
    interface PacketLink;
  }
}
implementation {

  components Jn516RadioC as Radio;
  components Jn516Ieee154MessageP as Msg;
  components Jn516PacketC;
  components Jn516ControlC;

  SendResource = Radio.Resource;
  Ieee154Receive = Msg;
  Ieee154Send = Msg;
  Ieee154Packet = Msg;
  Packet = Msg;
  Jn516Packet = Jn516PacketC;

  SplitControl = Radio;
  Jn516Packet = Radio;
  PacketAcknowledgements = Radio;
  LinkPacketMetadata = Radio;
  LowPowerListening = Radio;
  Jn516Config = Jn516ControlC;
  PacketLink = Radio;

  Msg.SubSend -> Radio.BareSend;
  Msg.SubReceive -> Radio.BareReceive;
#ifdef Jn516_IEEE154_RESOURCE_SEND
  Msg.Resource -> Radio.Resource[unique(RADIO_SEND_RESOURCE)];
#endif

  Msg.Jn516Packet -> Jn516PacketC;
  Msg.Jn516PacketBody -> Jn516PacketC;
  Msg.Jn516Config -> Jn516ControlC;

}
