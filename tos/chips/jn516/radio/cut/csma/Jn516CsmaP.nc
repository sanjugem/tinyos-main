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
 * @version $Revision: 1.12 $ $Date: 2009/09/17 23:36:36 $
 */

module Jn516CsmaP @safe() {

  provides interface SplitControl;
  provides interface Send;
  provides interface RadioBackoff;

  uses interface Resource;
  uses interface Jn516Power;
  uses interface StdControl as SubControl;
  uses interface Jn516Transmit;
  uses interface RadioBackoff as SubBackoff;
  uses interface Random;
  uses interface Leds;
  uses interface Jn516Packet;
  uses interface Jn516PacketBody;
  uses interface State as SplitControlState;

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
  
  error_t sendErr = SUCCESS;
  
  /** TRUE if we are to use CCA when sending the current packet */
  norace bool ccaOn;
  
  /****************** Prototypes ****************/
  task void startDone_task();
  task void stopDone_task();
  task void sendDone_task();
  
  void shutdown();

  /***************** SplitControl Commands ****************/
  command error_t SplitControl.start() {
    if(call SplitControlState.requestState(S_STARTING) == SUCCESS) {
      call Jn516Power.startVReg();
      return SUCCESS;
    
    } else if(call SplitControlState.isState(S_STARTED)) {
      return EALREADY;
      
    } else if(call SplitControlState.isState(S_STARTING)) {
      return SUCCESS;
    }
    
    return EBUSY;
  }

  command error_t SplitControl.stop() {
    if (call SplitControlState.isState(S_STARTED)) {
      call SplitControlState.forceState(S_STOPPING);
      shutdown();
      return SUCCESS;
      
    } else if(call SplitControlState.isState(S_STOPPED)) {
      return EALREADY;
    
    } else if(call SplitControlState.isState(S_TRANSMITTING)) {
      call SplitControlState.forceState(S_STOPPING);
      // At sendDone, the radio will shut down
      return SUCCESS;
    
    } else if(call SplitControlState.isState(S_STOPPING)) {
      return SUCCESS;
    }
    
    return EBUSY;
  }

  /***************** Send Commands ****************/
  command error_t Send.cancel( message_t* p_msg ) {
    return call Jn516Transmit.cancel();
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

    // header->length = len + Jn516_SIZE;
#ifdef Jn516_HW_SECURITY
    header->fcf &= ((1 << IEEE154_FCF_ACK_REQ)|
                    (1 << IEEE154_FCF_SECURITY_ENABLED)|
                    (0x3 << IEEE154_FCF_SRC_ADDR_MODE) |
                    (0x3 << IEEE154_FCF_DEST_ADDR_MODE));
#else
    header->fcf &= ((1 << IEEE154_FCF_ACK_REQ) | 
                    (0x3 << IEEE154_FCF_SRC_ADDR_MODE) |
                    (0x3 << IEEE154_FCF_DEST_ADDR_MODE));
#endif
    header->fcf |= ( ( IEEE154_TYPE_DATA << IEEE154_FCF_FRAME_TYPE ) |
		     ( 1 << IEEE154_FCF_INTRAPAN ) ); 

    metadata->ack = FALSE;
    metadata->rssi = 0;
    metadata->lqi = 0;
    //metadata->timesync = FALSE;
    metadata->timestamp = Jn516_INVALID_TIMESTAMP;

    ccaOn = TRUE;
    signal RadioBackoff.requestCca(m_msg);

    call Jn516Transmit.send( m_msg, ccaOn );
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

  /**************** RadioBackoff Commands ****************/
  /**
   * Must be called within a requestInitialBackoff event
   * @param backoffTime the amount of time in some unspecified units to backoff
   */
  async command void RadioBackoff.setInitialBackoff(uint16_t backoffTime) {
    call SubBackoff.setInitialBackoff(backoffTime);
  }
  
  /**
   * Must be called within a requestCongestionBackoff event
   * @param backoffTime the amount of time in some unspecified units to backoff
   */
  async command void RadioBackoff.setCongestionBackoff(uint16_t backoffTime) {
    call SubBackoff.setCongestionBackoff(backoffTime);
  }
      
  /**
   * Enable CCA for the outbound packet.  Must be called within a requestCca
   * event
   * @param ccaOn TRUE to enable CCA, which is the default.
   */
  async command void RadioBackoff.setCca(bool useCca) {
    ccaOn = useCca;
  }
  

  /**************** Events ****************/
  async event void Jn516Transmit.sendDone( message_t* p_msg, error_t err ) {
    atomic sendErr = err;
    post sendDone_task();
  }

  async event void Jn516Power.startVRegDone() {
    call Resource.request();
  }
  
  event void Resource.granted() {
    call Jn516Power.startOscillator();
  }

  async event void Jn516Power.startOscillatorDone() {
    post startDone_task();
  }
  
  /***************** SubBackoff Events ****************/
  async event void SubBackoff.requestInitialBackoff(message_t *msg) {
    call SubBackoff.setInitialBackoff ( call Random.rand16() 
        % (0x1F * Jn516_BACKOFF_PERIOD) + Jn516_MIN_BACKOFF);
        
    signal RadioBackoff.requestInitialBackoff(msg);
  }

  async event void SubBackoff.requestCongestionBackoff(message_t *msg) {
    call SubBackoff.setCongestionBackoff( call Random.rand16() 
        % (0x7 * Jn516_BACKOFF_PERIOD) + Jn516_MIN_BACKOFF);

    signal RadioBackoff.requestCongestionBackoff(msg);
  }
  
  async event void SubBackoff.requestCca(message_t *msg) {
    // Lower layers than this do not configure the CCA settings
    signal RadioBackoff.requestCca(msg);
  }
  
  
  /***************** Tasks ****************/
  task void sendDone_task() {
    error_t packetErr;
    atomic packetErr = sendErr;
    if(call SplitControlState.isState(S_STOPPING)) {
      shutdown();
      
    } else {
      call SplitControlState.forceState(S_STARTED);
    }
    
    signal Send.sendDone( m_msg, packetErr );
  }

  task void startDone_task() {
    call SubControl.start();
    call Jn516Power.rxOn();
    call Resource.release();
    call SplitControlState.forceState(S_STARTED);
    signal SplitControl.startDone( SUCCESS );
  }
  
  task void stopDone_task() {
    call SplitControlState.forceState(S_STOPPED);
    signal SplitControl.stopDone( SUCCESS );
  }
  
  
  /***************** Functions ****************/
  /**
   * Shut down all sub-components and turn off the radio
   */
  void shutdown() {
    call SubControl.stop();
    call Jn516Power.stopVReg();
    post stopDone_task();
  }

  /***************** Defaults ***************/
  default event void SplitControl.startDone(error_t error) {
  }
  
  default event void SplitControl.stopDone(error_t error) {
  }
  
  default async event void RadioBackoff.requestInitialBackoff(message_t *msg) {
  }

  default async event void RadioBackoff.requestCongestionBackoff(message_t *msg) {
  }
  
  default async event void RadioBackoff.requestCca(message_t *msg) {
  }
  
  
}

