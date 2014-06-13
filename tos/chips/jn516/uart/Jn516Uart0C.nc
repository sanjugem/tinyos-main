
/**
 * @author Sanjeet Raj Pandey
 */

configuration Jn516Uart0C {
  
  provides interface StdControl;
  provides interface UartByte;
  provides interface UartStream;
  uses interface Counter<TMicro, uint32_t>;
  
}

implementation{
  
  components new Jn516UartP() as UartP;
  StdControl = UartP;
  UartByte = UartP;
  UartStream = UartP;
  UartP.Counter = Counter;
  
  components HplJn516UartC as HplUartC;
  UartP.HplUartTxControl -> HplUartC.Uart0TxControl;
  UartP.HplUartRxControl -> HplUartC.Uart0RxControl;
  UartP.HplUart -> HplUartC.HplUart0;
  
  components MainC;
  MainC.SoftwareInit -> UartP;

  

  
}
