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
 *
 * @author Jonathan Hui <jhui@archrock.com>
 * @author David Moss
 * @version $Revision: 1.19 $ $Date: 2009-09-17 23:36:36 $
 */

#ifndef __Jn516_H__
#define __Jn516_H__

typedef uint8_t jn516_status_t;

#if defined(TFRAMES_ENABLED) && defined(IEEE154FRAMES_ENABLED)
#error "Both TFRAMES and IEEE154FRAMES enabled!"
#endif

/**
 * Jn516 header definition.
 * 
 * An I-frame (interoperability frame) header has an extra network 
 * byte specified by 6LowPAN
 * 
 * Length = length of the header + payload of the packet, minus the size
 *   of the length byte itself (1).  This is what allows for variable 
 *   length packets.
 * 
 * FCF = Frame Control Field, defined in the 802.15.4 specs and the
 *   Jn516 datasheet.
 *
 * DSN = Data Sequence Number, a number incremented for each packet sent
 *   by a particular node.  This is used in acknowledging that packet, 
 *   and also filtering out duplicate packets.
 *
 * DestPan = The destination PAN (personal area network) ID, so your 
 *   network can sit side by side with another TinyOS network and not
 *   interfere.
 * 
 * Dest = The destination address of this packet. 0xFFFF is the broadcast
 *   address.
 *
 * Src = The local node ID that generated the message.
 * 
 * Network = The TinyOS network ID, for interoperability with other types
 *   of 802.15.4 networks. 
 * 
 * Type = TinyOS AM type.  When you create a new AMSenderC(AM_MYMSG), 
 *   the AM_MYMSG definition is the type of packet.
 * 
 * TOSH_DATA_LENGTH defaults to 28, it represents the maximum size of 
 * the payload portion of the packet, and is specified in the 
 * tos/types/message.h file.
 *
 * All of these fields will be filled in automatically by the radio stack 
 * when you attempt to send a message.
 */
/**
 * Jn516 Security Header
 */
typedef nx_struct security_header_t {
  nx_uint8_t secLevel:3;
  nx_uint8_t keyMode:2;
  nx_uint8_t reserved:3;
  nx_uint32_t frameCounter;
  nx_uint8_t keyID[1]; // One byte for now
} security_header_t;
// 1 2 1 2 2 2 1 1 
typedef nx_struct jn516_header_t {
  nx_uint8_t length;
  nx_uint16_t fcf;
  nx_uint8_t dsn;
  nx_uint16_t destpan;
  nx_uint16_t dest;
  nx_uint16_t src;
  
#ifndef TFRAMES_ENABLED
  /** I-Frame 6LowPAN interoperability byte */
  nx_uint8_t network;
#endif

  nx_uint8_t type;
} jn516_header_t;

//typedef nx_struct jn516_header_t {
//  nxle_uint8_t length;
//  nxle_uint16_t fcf;
//  nxle_uint8_t dsn;
//  nxle_uint16_t destpan;
//  nxle_uint16_t dest;
//  nxle_uint16_t src;
//  /** Jn516 802.15.4 header ends here */
//#ifdef Jn516_HW_SECURITY
//  security_header_t secHdr;
//#endif
//  
//#ifndef TFRAMES_ENABLED
//  /** I-Frame 6LowPAN interoperability byte */
//  nxle_uint8_t network;
//#endif

//  nxle_uint8_t type;
//} jn516_header_t;


/**
 * Jn516 Packet Footer
 */
typedef nx_struct jn516_footer_t {
} jn516_footer_t;

/**
 * Jn516 Packet metadata. Contains extra information about the message
 * that will not be transmitted.
 *
 * Note that the first two bytes automatically take in the values of the
 * FCS when the payload is full. Do not modify the first two bytes of metadata.
 */
typedef nx_struct jn516_metadata_t {
  nx_uint8_t rssi;
  nx_uint8_t lqi;
  nx_uint8_t tx_power;
  nx_bool crc;
  nx_bool ack;
  nx_bool timesync;
  nx_uint32_t timestamp;
  nx_uint16_t rxInterval;

  /** Packet Link Metadata */
#ifdef PACKET_LINK
  nx_uint16_t maxRetries;
  nx_uint16_t retryDelay;
#endif
} jn516_metadata_t;


typedef nx_struct jn516_packet_t {
  jn516_header_t packet;
  nx_uint8_t data[];
} jn516_packet_t;


#ifndef TOSH_DATA_LENGTH
#define TOSH_DATA_LENGTH 28
#endif

#ifndef Jn516_DEF_CHANNEL
#define Jn516_DEF_CHANNEL 26
#endif

#ifndef Jn516_DEF_RFPOWER
#define Jn516_DEF_RFPOWER 31
#endif

/**
 * Ideally, your receive history size should be equal to the number of
 * RF neighbors your node will have
 */
#ifndef RECEIVE_HISTORY_SIZE
#define RECEIVE_HISTORY_SIZE 4
#endif

/** 
 * The 6LowPAN NALP ID for a TinyOS network is 63 (TEP 125).
 */
#ifndef TINYOS_6LOWPAN_NETWORK_ID
#define TINYOS_6LOWPAN_NETWORK_ID 0x3f
#endif

enum {
  // size of the header not including the length byte
  MAC_HEADER_SIZE = sizeof( jn516_header_t ) - 1,
  // size of the footer (FCS field)
  MAC_FOOTER_SIZE = sizeof( uint16_t ),
  // MDU
  MAC_PACKET_SIZE = MAC_HEADER_SIZE + TOSH_DATA_LENGTH + MAC_FOOTER_SIZE,

  Jn516_SIZE = MAC_HEADER_SIZE + MAC_FOOTER_SIZE,
};

enum jn516_enums {
  Jn516_TIME_ACK_TURNAROUND = 7, // jiffies
  Jn516_TIME_VREN = 20,          // jiffies
  Jn516_TIME_SYMBOL = 2,         // 2 symbols / jiffy
  Jn516_BACKOFF_PERIOD = ( 20 / Jn516_TIME_SYMBOL ), // symbols
  Jn516_MIN_BACKOFF = ( 20 / Jn516_TIME_SYMBOL ),  // platform specific?
  Jn516_ACK_WAIT_DELAY = 256,    // jiffies
};

enum jn516_status_enums {
  Jn516_STATUS_RSSI_VALID = 1 << 1,
  Jn516_STATUS_LOCK = 1 << 2,
  Jn516_STATUS_TX_ACTIVE = 1 << 3,
  Jn516_STATUS_ENC_BUSY = 1 << 4,
  Jn516_STATUS_TX_UNDERFLOW = 1 << 5,
  Jn516_STATUS_XOSC16M_STABLE = 1 << 6,
};

enum jn516_config_reg_enums {
  Jn516_SNOP = 0x00,
  Jn516_SXOSCON = 0x01,
  Jn516_STXCAL = 0x02,
  Jn516_SRXON = 0x03,
  Jn516_STXON = 0x04,
  Jn516_STXONCCA = 0x05,
  Jn516_SRFOFF = 0x06,
  Jn516_SXOSCOFF = 0x07,
  Jn516_SFLUSHRX = 0x08,
  Jn516_SFLUSHTX = 0x09,
  Jn516_SACK = 0x0a,
  Jn516_SACKPEND = 0x0b,
  Jn516_SRXDEC = 0x0c,
  Jn516_STXENC = 0x0d,
  Jn516_SAES = 0x0e,
  Jn516_MAIN = 0x10,
  Jn516_MDMCTRL0 = 0x11,
  Jn516_MDMCTRL1 = 0x12,
  Jn516_RSSI = 0x13,
  Jn516_SYNCWORD = 0x14,
  Jn516_TXCTRL = 0x15,
  Jn516_RXCTRL0 = 0x16,
  Jn516_RXCTRL1 = 0x17,
  Jn516_FSCTRL = 0x18,
  Jn516_SECCTRL0 = 0x19,
  Jn516_SECCTRL1 = 0x1a,
  Jn516_BATTMON = 0x1b,
  Jn516_IOCFG0 = 0x1c,
  Jn516_IOCFG1 = 0x1d,
  Jn516_MANFIDL = 0x1e,
  Jn516_MANFIDH = 0x1f,
  Jn516_FSMTC = 0x20,
  Jn516_MANAND = 0x21,
  Jn516_MANOR = 0x22,
  Jn516_AGCCTRL = 0x23,
  Jn516_AGCTST0 = 0x24,
  Jn516_AGCTST1 = 0x25,
  Jn516_AGCTST2 = 0x26,
  Jn516_FSTST0 = 0x27,
  Jn516_FSTST1 = 0x28,
  Jn516_FSTST2 = 0x29,
  Jn516_FSTST3 = 0x2a,
  Jn516_RXBPFTST = 0x2b,
  Jn516_FSMSTATE = 0x2c,
  Jn516_ADCTST = 0x2d,
  Jn516_DACTST = 0x2e,
  Jn516_TOPTST = 0x2f,
  Jn516_TXFIFO = 0x3e,
  Jn516_RXFIFO = 0x3f,
};

enum jn516_ram_addr_enums {
  Jn516_RAM_TXFIFO = 0x000,
  Jn516_RAM_RXFIFO = 0x080,
  Jn516_RAM_KEY0 = 0x100,
  Jn516_RAM_RXNONCE = 0x110,
  Jn516_RAM_SABUF = 0x120,
  Jn516_RAM_KEY1 = 0x130,
  Jn516_RAM_TXNONCE = 0x140,
  Jn516_RAM_CBCSTATE = 0x150,
  Jn516_RAM_IEEEADR = 0x160,
  Jn516_RAM_PANID = 0x168,
  Jn516_RAM_SHORTADR = 0x16a,
};

enum jn516_nonce_enums {
  Jn516_NONCE_BLOCK_COUNTER = 0,
  Jn516_NONCE_KEY_SEQ_COUNTER = 2,
  Jn516_NONCE_FRAME_COUNTER = 3,
  Jn516_NONCE_SOURCE_ADDRESS = 7,
  Jn516_NONCE_FLAGS = 15,
};

enum jn516_main_enums {
  Jn516_MAIN_RESETn = 15,
  Jn516_MAIN_ENC_RESETn = 14,
  Jn516_MAIN_DEMOD_RESETn = 13,
  Jn516_MAIN_MOD_RESETn = 12,
  Jn516_MAIN_FS_RESETn = 11,
  Jn516_MAIN_XOSC16M_BYPASS = 0,
};

enum jn516_mdmctrl0_enums {
  Jn516_MDMCTRL0_RESERVED_FRAME_MODE = 13,
  Jn516_MDMCTRL0_PAN_COORDINATOR = 12,
  Jn516_MDMCTRL0_ADR_DECODE = 11,
  Jn516_MDMCTRL0_CCA_HYST = 8,
  Jn516_MDMCTRL0_CCA_MOD = 6,
  Jn516_MDMCTRL0_AUTOCRC = 5,
  Jn516_MDMCTRL0_AUTOACK = 4,
  Jn516_MDMCTRL0_PREAMBLE_LENGTH = 0,
};

enum jn516_mdmctrl1_enums {
  Jn516_MDMCTRL1_CORR_THR = 6,
  Jn516_MDMCTRL1_DEMOD_AVG_MODE = 5,
  Jn516_MDMCTRL1_MODULATION_MODE = 4,
  Jn516_MDMCTRL1_TX_MODE = 2,
  Jn516_MDMCTRL1_RX_MODE = 0,
};

enum jn516_rssi_enums {
  Jn516_RSSI_CCA_THR = 8,
  Jn516_RSSI_RSSI_VAL = 0,
};

enum jn516_syncword_enums {
  Jn516_SYNCWORD_SYNCWORD = 0,
};

enum jn516_txctrl_enums {
  Jn516_TXCTRL_TXMIXBUF_CUR = 14,
  Jn516_TXCTRL_TX_TURNAROUND = 13,
  Jn516_TXCTRL_TXMIX_CAP_ARRAY = 11,
  Jn516_TXCTRL_TXMIX_CURRENT = 9,
  Jn516_TXCTRL_PA_CURRENT = 6,
  Jn516_TXCTRL_RESERVED = 5,
  Jn516_TXCTRL_PA_LEVEL = 0,
};

enum jn516_rxctrl0_enums {
  Jn516_RXCTRL0_RXMIXBUF_CUR = 12,
  Jn516_RXCTRL0_HIGH_LNA_GAIN = 10,
  Jn516_RXCTRL0_MED_LNA_GAIN = 8,
  Jn516_RXCTRL0_LOW_LNA_GAIN = 6,
  Jn516_RXCTRL0_HIGH_LNA_CURRENT = 4,
  Jn516_RXCTRL0_MED_LNA_CURRENT = 2,
  Jn516_RXCTRL0_LOW_LNA_CURRENT = 0,
};

enum jn516_rxctrl1_enums {
  Jn516_RXCTRL1_RXBPF_LOCUR = 13,
  Jn516_RXCTRL1_RXBPF_MIDCUR = 12,
  Jn516_RXCTRL1_LOW_LOWGAIN = 11,
  Jn516_RXCTRL1_MED_LOWGAIN = 10,
  Jn516_RXCTRL1_HIGH_HGM = 9,
  Jn516_RXCTRL1_MED_HGM = 8,
  Jn516_RXCTRL1_LNA_CAP_ARRAY = 6,
  Jn516_RXCTRL1_RXMIX_TAIL = 4,
  Jn516_RXCTRL1_RXMIX_VCM = 2,
  Jn516_RXCTRL1_RXMIX_CURRENT = 0,
};

enum jn516_rsctrl_enums {
  Jn516_FSCTRL_LOCK_THR = 14,
  Jn516_FSCTRL_CAL_DONE = 13,
  Jn516_FSCTRL_CAL_RUNNING = 12,
  Jn516_FSCTRL_LOCK_LENGTH = 11,
  Jn516_FSCTRL_LOCK_STATUS = 10,
  Jn516_FSCTRL_FREQ = 0,
};

enum jn516_secctrl0_enums {
  Jn516_SECCTRL0_RXFIFO_PROTECTION = 9,
  Jn516_SECCTRL0_SEC_CBC_HEAD = 8,
  Jn516_SECCTRL0_SEC_SAKEYSEL = 7,
  Jn516_SECCTRL0_SEC_TXKEYSEL = 6,
  Jn516_SECCTRL0_SEC_RXKEYSEL = 5,
  Jn516_SECCTRL0_SEC_M = 2,
  Jn516_SECCTRL0_SEC_MODE = 0,
};

enum jn516_secctrl1_enums {
  Jn516_SECCTRL1_SEC_TXL = 8,
  Jn516_SECCTRL1_SEC_RXL = 0,
};

enum jn516_battmon_enums {
  Jn516_BATTMON_BATT_OK = 6,
  Jn516_BATTMON_BATTMON_EN = 5,
  Jn516_BATTMON_BATTMON_VOLTAGE = 0,
};

enum jn516_iocfg0_enums {
  Jn516_IOCFG0_BCN_ACCEPT = 11,
  Jn516_IOCFG0_FIFO_POLARITY = 10,
  Jn516_IOCFG0_FIFOP_POLARITY = 9,
  Jn516_IOCFG0_SFD_POLARITY = 8,
  Jn516_IOCFG0_CCA_POLARITY = 7,
  Jn516_IOCFG0_FIFOP_THR = 0,
};

enum jn516_iocfg1_enums {
  Jn516_IOCFG1_HSSD_SRC = 10,
  Jn516_IOCFG1_SFDMUX = 5,
  Jn516_IOCFG1_CCAMUX = 0,
};

enum jn516_manfidl_enums {
  Jn516_MANFIDL_PARTNUM = 12,
  Jn516_MANFIDL_MANFID = 0,
};

enum jn516_manfidh_enums {
  Jn516_MANFIDH_VERSION = 12,
  Jn516_MANFIDH_PARTNUM = 0,
};

enum jn516_fsmtc_enums {
  Jn516_FSMTC_TC_RXCHAIN2RX = 13,
  Jn516_FSMTC_TC_SWITCH2TX = 10,
  Jn516_FSMTC_TC_PAON2TX = 6,
  Jn516_FSMTC_TC_TXEND2SWITCH = 3,
  Jn516_FSMTC_TC_TXEND2PAOFF = 0,
};

enum jn516_sfdmux_enums {
  Jn516_SFDMUX_SFD = 0,
  Jn516_SFDMUX_XOSC16M_STABLE = 24,
};

enum jn516_security_enums{
  Jn516_NO_SEC = 0,
  Jn516_CBC_MAC = 1,
  Jn516_CTR = 2,
  Jn516_CCM = 3,
  NO_SEC = 0,
  CBC_MAC_4 = 1,
  CBC_MAC_8 = 2,
  CBC_MAC_16 = 3,
  CTR = 4,
  CCM_4 = 5,
  CCM_8 = 6,
  CCM_16 = 7
};
norace uint8_t SECURITYLOCK = 0;

enum
{
  Jn516_INVALID_TIMESTAMP  = 0x80000000L,
};

#endif
