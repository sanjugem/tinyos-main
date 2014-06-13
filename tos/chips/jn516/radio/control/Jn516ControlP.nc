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
 * @author Jonathan Hui <jhui@archrock.com>
 * @author David Moss
 * @author Urs Hunkeler (ReadRssi implementation)
 * @version $Revision: 1.7 $ $Date: 2008/06/24 04:07:28 $
 */

#include <Ieee154.h>
#include "Timer.h"

module Jn516ControlP @safe() {

  provides interface Init;
  provides interface Jn516Config;
  provides interface Jn516Power;
  provides interface Read<uint16_t> as ReadRssi;

  uses interface LocalIeeeEui64;
  uses interface ActiveMessageAddress;
  uses interface Leds;

}

implementation {

  uint8_t m_channel;
   
  uint16_t m_pan;
  
  uint16_t m_short_addr;

  ieee_eui64_t m_ext_addr;
  
  
  /** TRUE if acknowledgments are enabled */
  bool autoAckEnabled;
  
  /** TRUE if acknowledgments are generated in hardware only */
  bool hwAutoAckDefault;
  
  /** TRUE if software or hardware address recognition is enabled */
  bool addressRecognition;
  
  /** TRUE if address recognition should also be performed in hardware */
  bool hwAddressRecognition;
  
  /***************** Init Commands ****************/
  command error_t Init.init() {
    int i, t;
    
    m_short_addr = call ActiveMessageAddress.amAddress();
    m_ext_addr = call LocalIeeeEui64.getId();
    m_pan = call ActiveMessageAddress.amGroup();
    m_channel = Jn516_DEF_CHANNEL;
    
    m_ext_addr = call LocalIeeeEui64.getId();
    for (i = 0; i < 4; i++) {
      t = m_ext_addr.data[i];
      m_ext_addr.data[i] = m_ext_addr.data[7-i];
      m_ext_addr.data[7-i] = t;
    }


#if defined(Jn516_NO_ADDRESS_RECOGNITION)
    addressRecognition = FALSE;
#else
    addressRecognition = TRUE;
#endif
    
#if defined(Jn516_HW_ADDRESS_RECOGNITION)
    hwAddressRecognition = TRUE;
#else
    hwAddressRecognition = FALSE;
#endif
    
    
#if defined(Jn516_NO_ACKNOWLEDGEMENTS)
    autoAckEnabled = FALSE;
#else
    autoAckEnabled = TRUE;
#endif
    
#if defined(Jn516_HW_ACKNOWLEDGEMENTS)
    hwAutoAckDefault = TRUE;
    hwAddressRecognition = TRUE;
#else
    hwAutoAckDefault = FALSE;
#endif
    
    
    return SUCCESS;
  }


  async command error_t Jn516Power.rxOn() {
    atomic {

    }
    return SUCCESS;
  }

  async command error_t Jn516Power.rfOff() {
    atomic {  

    }
    return SUCCESS;
  }

  
  /***************** Jn516Config Commands ****************/
  command uint8_t Jn516Config.getChannel() {
    atomic return m_channel;
  }

  command void Jn516Config.setChannel( uint8_t channel ) {
    atomic m_channel = channel;
  }

  command ieee_eui64_t Jn516Config.getExtAddr() {
    return m_ext_addr;
  }

  async command uint16_t Jn516Config.getShortAddr() {
    atomic return m_short_addr;
  }

  command void Jn516Config.setShortAddr( uint16_t addr ) {
    atomic m_short_addr = addr;
  }

  async command uint16_t Jn516Config.getPanAddr() {
    atomic return m_pan;
  }

  command void Jn516Config.setPanAddr( uint16_t pan ) {
    atomic m_pan = pan;
  }

  /**
   * @param enableAddressRecognition TRUE to turn address recognition on
   * @param useHwAddressRecognition TRUE to perform address recognition first
   *     in hardware. This doesn't affect software address recognition. The
   *     driver must sync with the chip after changing this value.
   */
  command void Jn516Config.setAddressRecognition(bool enableAddressRecognition, bool useHwAddressRecognition) {
    atomic {
      addressRecognition = enableAddressRecognition;
      hwAddressRecognition = useHwAddressRecognition;
    }
  }
  
  /**
   * @return TRUE if address recognition is enabled
   */
  async command bool Jn516Config.isAddressRecognitionEnabled() {
    atomic return addressRecognition;
  }
  
  /**
   * @return TRUE if address recognition is performed first in hardware.
   */
  async command bool Jn516Config.isHwAddressRecognitionDefault() {
    atomic return hwAddressRecognition;
  }
  
  
  /**
   * Sync must be called for acknowledgement changes to take effect
   * @param enableAutoAck TRUE to enable auto acknowledgements
   * @param hwAutoAck TRUE to default to hardware auto acks, FALSE to
   *     default to software auto acknowledgements
   */
  command void Jn516Config.setAutoAck(bool enableAutoAck, bool hwAutoAck) {
    atomic autoAckEnabled = enableAutoAck;
    atomic hwAutoAckDefault = hwAutoAck;
  }
  
  /**
   * @return TRUE if hardware auto acks are the default, FALSE if software
   *     acks are the default
   */
  async command bool Jn516Config.isHwAutoAckDefault() {
    atomic return hwAutoAckDefault;    
  }
  
  /**
   * @return TRUE if auto acks are enabled
   */
  async command bool Jn516Config.isAutoAckEnabled() {
    atomic return autoAckEnabled;
  }
  
  /***************** ReadRssi Commands ****************/
  command error_t ReadRssi.read() { 
    return SUCCESS;
  }
   
  /***************** ActiveMessageAddress Events ****************/
  async event void ActiveMessageAddress.changed() {
    atomic {
      m_short_addr = call ActiveMessageAddress.amAddress();
      m_pan = call ActiveMessageAddress.amGroup();
    }
  }


  default event void ReadRssi.readDone(error_t error, uint16_t data) {
  }
  
}
