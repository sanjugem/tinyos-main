/*
 * Copyright (c) 2005-2006 Arch Rock Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Arch Rock Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * ARCHED ROCK OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 */

/**
 * Implementation of the transmit path for the ChipCon Jn516 radio.
 *
 * @author Jonathan Hui <jhui@archrock.com>
 * @version $Revision: 1.3 $ $Date: 2009-08-14 20:33:43 $
 */

#include "IEEE802154.h"

configuration Jn516TransmitC {

  provides {
    interface StdControl;
    interface Jn516Transmit;
    interface RadioBackoff;
    interface ReceiveIndicator as EnergyIndicator;
    interface ReceiveIndicator as ByteIndicator;
  }
}

implementation {

  components Jn516TransmitP;
  StdControl = Jn516TransmitP;
  Jn516Transmit = Jn516TransmitP;
  RadioBackoff = Jn516TransmitP;
  EnergyIndicator = Jn516TransmitP.EnergyIndicator;
  ByteIndicator = Jn516TransmitP.ByteIndicator;

  components MainC;
  MainC.SoftwareInit -> Jn516TransmitP;
  MainC.SoftwareInit -> Alarm;
  
  components AlarmMultiplexC as Alarm;
  Jn516TransmitP.BackoffTimer -> Alarm;

  components HplJn516PinsC as Pins;
  Jn516TransmitP.CCA -> Pins.CCA;
  Jn516TransmitP.CSN -> Pins.CSN;
  Jn516TransmitP.SFD -> Pins.SFD;

  components HplJn516InterruptsC as Interrupts;
  Jn516TransmitP.CaptureSFD -> Interrupts.CaptureSFD;

  components new Jn516SpiC() as Spi;
  Jn516TransmitP.SpiResource -> Spi;
  Jn516TransmitP.ChipSpiResource -> Spi;
  Jn516TransmitP.SNOP        -> Spi.SNOP;
  Jn516TransmitP.STXON       -> Spi.STXON;
  Jn516TransmitP.STXONCCA    -> Spi.STXONCCA;
  Jn516TransmitP.SFLUSHTX    -> Spi.SFLUSHTX;
  Jn516TransmitP.TXCTRL      -> Spi.TXCTRL;
  Jn516TransmitP.TXFIFO      -> Spi.TXFIFO;
  Jn516TransmitP.TXFIFO_RAM  -> Spi.TXFIFO_RAM;
  Jn516TransmitP.MDMCTRL1    -> Spi.MDMCTRL1;
  Jn516TransmitP.SECCTRL0 -> Spi.SECCTRL0;
  Jn516TransmitP.SECCTRL1 -> Spi.SECCTRL1;
  Jn516TransmitP.STXENC -> Spi.STXENC;
  Jn516TransmitP.TXNONCE -> Spi.TXNONCE;
  Jn516TransmitP.KEY0 -> Spi.KEY0;
  Jn516TransmitP.KEY1 -> Spi.KEY1;
  
  components Jn516ReceiveC;
  Jn516TransmitP.Jn516Receive -> Jn516ReceiveC;
  
  components Jn516PacketC;
  Jn516TransmitP.Jn516Packet -> Jn516PacketC;
  Jn516TransmitP.Jn516PacketBody -> Jn516PacketC;
  Jn516TransmitP.PacketTimeStamp -> Jn516PacketC;
  Jn516TransmitP.PacketTimeSyncOffset -> Jn516PacketC;

  components LedsC;
  Jn516TransmitP.Leds -> LedsC;

}
