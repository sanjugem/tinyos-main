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
 * Implementation of the receive path for the ChipCon Jn516 radio.
 *
 * @author Jonathan Hui <jhui@archrock.com>
 * @version $Revision: 1.4 $ $Date: 2009-08-14 20:33:43 $
 */

configuration Jn516ReceiveC {

  provides interface StdControl;
  provides interface Jn516Receive;
  provides interface Receive;
  provides interface ReceiveIndicator as PacketIndicator;

}

implementation {
  components MainC;
  components Jn516ReceiveP;
  components Jn516PacketC;
  components new Jn516SpiC() as Spi;
  components Jn516ControlC;
  
  components HplJn516PinsC as Pins;
  components HplJn516InterruptsC as InterruptsC;

  components LedsC as Leds;
  Jn516ReceiveP.Leds -> Leds;

  StdControl = Jn516ReceiveP;
  Jn516Receive = Jn516ReceiveP;
  Receive = Jn516ReceiveP;
  PacketIndicator = Jn516ReceiveP.PacketIndicator;

  MainC.SoftwareInit -> Jn516ReceiveP;
  
  Jn516ReceiveP.CSN -> Pins.CSN;
  Jn516ReceiveP.FIFO -> Pins.FIFO;
  Jn516ReceiveP.FIFOP -> Pins.FIFOP;
  Jn516ReceiveP.InterruptFIFOP -> InterruptsC.InterruptFIFOP;
  Jn516ReceiveP.SpiResource -> Spi;
  Jn516ReceiveP.RXFIFO -> Spi.RXFIFO;
  Jn516ReceiveP.SFLUSHRX -> Spi.SFLUSHRX;
  Jn516ReceiveP.SACK -> Spi.SACK;
  Jn516ReceiveP.Jn516Packet -> Jn516PacketC;
  Jn516ReceiveP.Jn516PacketBody -> Jn516PacketC;
  Jn516ReceiveP.PacketTimeStamp -> Jn516PacketC;
  Jn516ReceiveP.Jn516Config -> Jn516ControlC;

  Jn516ReceiveP.SECCTRL0 -> Spi.SECCTRL0;
  Jn516ReceiveP.SECCTRL1 -> Spi.SECCTRL1;
  Jn516ReceiveP.SRXDEC -> Spi.SRXDEC;
  Jn516ReceiveP.RXNONCE -> Spi.RXNONCE;
  Jn516ReceiveP.KEY0 -> Spi.KEY0;
  Jn516ReceiveP.KEY1 -> Spi.KEY1;
  Jn516ReceiveP.RXFIFO_RAM -> Spi.RXFIFO_RAM;
  Jn516ReceiveP.SNOP -> Spi.SNOP;

}
