
/** 

 * @author Sanjeet Raj Pandey
 */

#include <jendefs.h>
#include <AppHardwareApi.h>

#define BUFFER_LEN  256


module HplJn516UartP {
  
  provides interface Init as Uart0Init;
  provides interface StdControl as Uart0TxControl;
  provides interface StdControl as Uart0RxControl;
  provides interface HplJn516Uart as HplUart0;
    
  provides interface Init as Uart1Init;
  provides interface StdControl as Uart1TxControl;
  provides interface StdControl as Uart1RxControl;
  provides interface HplJn516Uart as HplUart1;
  
  //uses interface Jn516Calibrate;
  uses interface McuPowerState;


}
implementation {
  
  //=== Uart Init Commands. ====================================
  uint8_t tx_buffer[BUFFER_LEN];
  uint8_t rx_buffer[BUFFER_LEN];

  command error_t Uart0Init.init() {
   
     bool init_success = bAHI_UartEnable(E_AHI_UART_0, tx_buffer, BUFFER_LEN, tx_buffer,BUFFER_LEN);
    vAHI_UartSetBaudRate(E_AHI_UART_0, E_AHI_UART_RATE_38400);
    if(init_success)
      return SUCCESS;
    else
      return FAIL;
  }

  command error_t Uart0TxControl.start() {

    bool init_success = bAHI_UartEnable(E_AHI_UART_0, tx_buffer, BUFFER_LEN, tx_buffer,BUFFER_LEN);
    vAHI_UartSetBaudRate(E_AHI_UART_0, E_AHI_UART_RATE_38400);
    if(init_success)
      return SUCCESS;
    else
      return FAIL;
  }

  command error_t Uart0TxControl.stop() {
    vAHI_UartDisable(E_AHI_UART_0);
    call McuPowerState.update();
    return SUCCESS;
  }

  command error_t Uart0RxControl.start() {

    bool init_success = bAHI_UartEnable(E_AHI_UART_0, tx_buffer, BUFFER_LEN, tx_buffer,BUFFER_LEN);
    vAHI_UartSetBaudRate(E_AHI_UART_0, E_AHI_UART_RATE_38400);
    if(init_success)
      return SUCCESS;
    else
      return FAIL;
    return SUCCESS;
  }

  command error_t Uart0RxControl.stop() {
    vAHI_UartDisable(E_AHI_UART_0);
    call McuPowerState.update();
    return SUCCESS;
  }
  
  async command error_t HplUart0.enableTxIntr() {
    vAHI_UartSetInterrupt(E_AHI_UART_0,TRUE,FALSE,TRUE,TRUE,E_AHI_UART_FIFO_LEVEL_1);
    return SUCCESS;
  }
  
  async command error_t HplUart0.disableTxIntr(){
    vAHI_UartSetInterrupt(E_AHI_UART_0,FALSE,FALSE,TRUE,TRUE,E_AHI_UART_FIFO_LEVEL_1);
    return SUCCESS;
  }
  
  async command error_t HplUart0.enableRxIntr(){
    vAHI_UartSetInterrupt(E_AHI_UART_0,TRUE,TRUE,TRUE,TRUE,E_AHI_UART_FIFO_LEVEL_1);
    return SUCCESS;
  }

  async command error_t HplUart0.disableRxIntr(){
    vAHI_UartSetInterrupt(E_AHI_UART_0,FALSE,TRUE,TRUE,TRUE,E_AHI_UART_FIFO_LEVEL_1);
    return SUCCESS;
  }
  
  async command bool HplUart0.isTxEmpty(){
    if(u16AHI_UartReadTxFifoLevel(E_AHI_UART_0)>0){
      return FALSE;
    }else {
      return TRUE;
    }
  }

  async command bool HplUart0.isRxEmpty(){
    if(u16AHI_UartReadRxFifoLevel(E_AHI_UART_0)>0){
      return FALSE;
    }else {
      return TRUE;
    }
  }
  
  async command uint8_t HplUart0.rx(){
    return u8AHI_UartReadData (E_AHI_UART_0);
  }

  async command void HplUart0.tx(uint8_t data) {
    atomic{
      vAHI_UartWriteData(E_AHI_UART_0, data);
    }
  }
  
  // AVR_ATOMIC_HANDLER(SIG_UART0_RECV) {
  //   if (READ_BIT(UCSR0A, RXC)) {
  //     signal HplUart0.rxDone(UDR0);
  //   }
  // }
  
  // AVR_NONATOMIC_HANDLER(SIG_UART0_TRANS) {
  //   signal HplUart0.txDone();
  // }
  
  command error_t Uart1Init.init() {
   

    return SUCCESS;
  }

  command error_t Uart1TxControl.start() {
   
  }

  command error_t Uart1TxControl.stop() {
   
    return SUCCESS;
  }

  command error_t Uart1RxControl.start() {
   
    return SUCCESS;
  }

  command error_t Uart1RxControl.stop() {
    
    return SUCCESS;
  }
  
  async command error_t HplUart1.enableTxIntr() {
    
    return SUCCESS;
  }
  
  async command error_t HplUart1.disableTxIntr(){
    
    return SUCCESS;
  }
  
  async command error_t HplUart1.enableRxIntr(){
   
    return SUCCESS;
  }

  async command error_t HplUart1.disableRxIntr(){
    
    return SUCCESS;
  }
  
  async command bool HplUart1.isTxEmpty() {
   // return READ_BIT(UCSR1A, TXC);
  }

  async command bool HplUart1.isRxEmpty() {
    //return !READ_BIT(UCSR1A, RXC);
  }
  
  async command uint8_t HplUart1.rx(){
    //return UDR1;
  }

  async command void HplUart1.tx(uint8_t data) {
    
  }
  
  /*AVR_ATOMIC_HANDLER(SIG_UART1_RECV) {
    if (READ_BIT(UCSR1A, RXC))
      signal HplUart1.rxDone(UDR1);
  }
  
  AVR_NONATOMIC_HANDLER(SIG_UART1_TRANS) {
    signal HplUart1.txDone();
  }
  */
  
  default async event void HplUart0.txDone() {} 
  default async event void HplUart0.rxDone(uint8_t data) {}
  default async event void HplUart1.txDone() {}
  default async event void HplUart1.rxDone(uint8_t data) {}

}
