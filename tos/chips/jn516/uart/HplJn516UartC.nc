
/**

 *
 * @author Sanjeet Raj Pandey
 */
configuration HplJn516UartC
{
  provides {
    interface StdControl as Uart0TxControl;
    interface StdControl as Uart0RxControl;
    interface HplJn516Uart as HplUart0;
    
    interface StdControl as Uart1TxControl;
    interface StdControl as Uart1RxControl;
    interface HplJn516Uart as HplUart1;
  }
}
implementation
{
  components HplJn516UartP, PlatformC, McuSleepC;
  
  Uart0TxControl = HplJn516UartP.Uart0TxControl;
  Uart0RxControl = HplJn516UartP.Uart0RxControl;
  HplUart0 = HplJn516UartP.HplUart0;
  
  Uart1TxControl = HplJn516UartP.Uart1TxControl;
  Uart1RxControl = HplJn516UartP.Uart1RxControl;
  HplUart1 = HplJn516UartP.HplUart1;
  
  //HplJn516UartP.Jn516Calibrate -> PlatformC;
  HplJn516UartP.McuPowerState -> McuSleepC;
  
  components MainC;
  MainC.SoftwareInit -> HplJn516UartP.Uart0Init;
  MainC.SoftwareInit -> HplJn516UartP.Uart1Init;
  
}
