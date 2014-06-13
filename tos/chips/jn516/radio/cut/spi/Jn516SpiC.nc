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
 * Implementation of basic SPI primitives for the ChipCon Jn516 radio.
 *
 * @author Jonathan Hui <jhui@archrock.com>
 * @version $Revision: 1.4 $ $Date: 2009-08-14 20:33:43 $
 */

generic configuration Jn516SpiC() {

  provides interface Resource;
  provides interface ChipSpiResource;

  // commands
  provides interface Jn516Strobe as SNOP;
  provides interface Jn516Strobe as SXOSCON;
  provides interface Jn516Strobe as STXCAL;
  provides interface Jn516Strobe as SRXON;
  provides interface Jn516Strobe as STXON;
  provides interface Jn516Strobe as STXONCCA;
  provides interface Jn516Strobe as SRFOFF;
  provides interface Jn516Strobe as SXOSCOFF;
  provides interface Jn516Strobe as SFLUSHRX;
  provides interface Jn516Strobe as SFLUSHTX;
  provides interface Jn516Strobe as SACK;
  provides interface Jn516Strobe as SACKPEND;
  provides interface Jn516Strobe as SRXDEC;
  provides interface Jn516Strobe as STXENC;
  provides interface Jn516Strobe as SAES;

  // registers
  provides interface Jn516Register as MAIN;
  provides interface Jn516Register as MDMCTRL0;
  provides interface Jn516Register as MDMCTRL1;
  provides interface Jn516Register as RSSI;
  provides interface Jn516Register as SYNCWORD;
  provides interface Jn516Register as TXCTRL;
  provides interface Jn516Register as RXCTRL0;
  provides interface Jn516Register as RXCTRL1;
  provides interface Jn516Register as FSCTRL;
  provides interface Jn516Register as SECCTRL0;
  provides interface Jn516Register as SECCTRL1;
  provides interface Jn516Register as BATTMON;
  provides interface Jn516Register as IOCFG0;
  provides interface Jn516Register as IOCFG1;
  provides interface Jn516Register as MANFIDL;
  provides interface Jn516Register as MANFIDH;
  provides interface Jn516Register as FSMTC;
  provides interface Jn516Register as MANAND;
  provides interface Jn516Register as MANOR;
  provides interface Jn516Register as AGCCTRL;

  provides interface Jn516Register as AGCTST0;
  provides interface Jn516Register as AGCTST1;
  provides interface Jn516Register as AGCTST2;
  provides interface Jn516Register as FSTST0;
  provides interface Jn516Register as FSTST1;
  provides interface Jn516Register as FSTST2;
  provides interface Jn516Register as FSTST3;
  provides interface Jn516Register as RXBPFTST;
  provides interface Jn516Register as FSMSTATE;
  provides interface Jn516Register as ADCTST;
  provides interface Jn516Register as DACTST;
  provides interface Jn516Register as TOPTST;
  provides interface Jn516Register as TXFIFO_REGISTER;
  provides interface Jn516Register as RXFIFO_REGISTER;

  // ram
  provides interface Jn516Ram as IEEEADR;
  provides interface Jn516Ram as PANID;
  provides interface Jn516Ram as SHORTADR;
  provides interface Jn516Ram as TXFIFO_RAM;
  provides interface Jn516Ram as RXFIFO_RAM;
  provides interface Jn516Ram as KEY0;
  provides interface Jn516Ram as KEY1;
  provides interface Jn516Ram as SABUF;
  provides interface Jn516Ram as TXNONCE;
  provides interface Jn516Ram as RXNONCE;

  // fifos
  provides interface Jn516Fifo as RXFIFO;
  provides interface Jn516Fifo as TXFIFO;

}

implementation {

  enum {
    CLIENT_ID = unique( "Jn516Spi.Resource" ),
  };
  
  components HplJn516PinsC as Pins;
  components Jn516SpiWireC as Spi;
  
  ChipSpiResource = Spi.ChipSpiResource;
  Resource = Spi.Resource[ CLIENT_ID ];
  
  // commands
  SNOP = Spi.Strobe[ Jn516_SNOP ];
  SXOSCON = Spi.Strobe[ Jn516_SXOSCON ];
  STXCAL = Spi.Strobe[ Jn516_STXCAL ];
  SRXON = Spi.Strobe[ Jn516_SRXON ];
  STXON = Spi.Strobe[ Jn516_STXON ];
  STXONCCA = Spi.Strobe[ Jn516_STXONCCA ];
  SRFOFF = Spi.Strobe[ Jn516_SRFOFF ];
  SXOSCOFF = Spi.Strobe[ Jn516_SXOSCOFF ];
  SFLUSHRX = Spi.Strobe[ Jn516_SFLUSHRX ];
  SFLUSHTX = Spi.Strobe[ Jn516_SFLUSHTX ];
  SACK = Spi.Strobe[ Jn516_SACK ];
  SACKPEND = Spi.Strobe[ Jn516_SACKPEND ];
  SRXDEC = Spi.Strobe[ Jn516_SRXDEC ];
  STXENC = Spi.Strobe[ Jn516_STXENC ];
  SAES = Spi.Strobe[ Jn516_SAES ];
  
  // registers
  MAIN = Spi.Reg[ Jn516_MAIN ];
  MDMCTRL0 = Spi.Reg[ Jn516_MDMCTRL0 ];
  MDMCTRL1 = Spi.Reg[ Jn516_MDMCTRL1 ];
  RSSI = Spi.Reg[ Jn516_RSSI ];
  SYNCWORD = Spi.Reg[ Jn516_SYNCWORD ];
  TXCTRL = Spi.Reg[ Jn516_TXCTRL ];
  RXCTRL0 = Spi.Reg[ Jn516_RXCTRL0 ];
  RXCTRL1 = Spi.Reg[ Jn516_RXCTRL1 ];
  FSCTRL = Spi.Reg[ Jn516_FSCTRL ];
  SECCTRL0 = Spi.Reg[ Jn516_SECCTRL0 ];
  SECCTRL1 = Spi.Reg[ Jn516_SECCTRL1 ];
  BATTMON = Spi.Reg[ Jn516_BATTMON ];
  IOCFG0 = Spi.Reg[ Jn516_IOCFG0 ];
  IOCFG1 = Spi.Reg[ Jn516_IOCFG1 ];
  MANFIDL = Spi.Reg[ Jn516_MANFIDL ];
  MANFIDH = Spi.Reg[ Jn516_MANFIDH ];
  FSMTC = Spi.Reg[ Jn516_FSMTC ];
  MANAND = Spi.Reg[ Jn516_MANAND ];
  MANOR = Spi.Reg[ Jn516_MANOR ];
  AGCCTRL = Spi.Reg[ Jn516_AGCCTRL ];

  AGCTST0	  = Spi.Reg[ Jn516_AGCTST0 ];
  AGCTST1	  = Spi.Reg[ Jn516_AGCTST1 ];
  AGCTST2	  = Spi.Reg[ Jn516_AGCTST2 ];
  FSTST0	  = Spi.Reg[ Jn516_FSTST0 ];
  FSTST1	  = Spi.Reg[ Jn516_FSTST1 ];
  FSTST2	  = Spi.Reg[ Jn516_FSTST2 ];
  FSTST3	  = Spi.Reg[ Jn516_FSTST3 ];
  RXBPFTST	  = Spi.Reg[ Jn516_RXBPFTST ];
  FSMSTATE	  = Spi.Reg[ Jn516_FSMSTATE ];
  ADCTST	  = Spi.Reg[ Jn516_ADCTST ];
  DACTST	  = Spi.Reg[ Jn516_DACTST ];
  TOPTST	  = Spi.Reg[ Jn516_TOPTST ];
  TXFIFO_REGISTER = Spi.Reg[ Jn516_TXFIFO ];
  RXFIFO_REGISTER = Spi.Reg[ Jn516_RXFIFO ];
  
  // ram
  IEEEADR = Spi.Ram[ Jn516_RAM_IEEEADR ];
  PANID = Spi.Ram[ Jn516_RAM_PANID ];
  SHORTADR = Spi.Ram[ Jn516_RAM_SHORTADR ];
  TXFIFO_RAM = Spi.Ram[ Jn516_RAM_TXFIFO ];
  RXFIFO_RAM = Spi.Ram[ Jn516_RAM_RXFIFO ];
  KEY0 = Spi.Ram[ Jn516_RAM_KEY0 ];
  KEY1 = Spi.Ram[ Jn516_RAM_KEY1 ];
  SABUF = Spi.Ram[ Jn516_RAM_SABUF ];
  TXNONCE = Spi.Ram[ Jn516_RAM_TXNONCE ];
  RXNONCE = Spi.Ram[ Jn516_RAM_RXNONCE ];

  // fifos
  RXFIFO = Spi.Fifo[ Jn516_RXFIFO ];
  TXFIFO = Spi.Fifo[ Jn516_TXFIFO ];

}

