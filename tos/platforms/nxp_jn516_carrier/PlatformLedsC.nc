/* 
 * @author Sanjeet Raj Pandey
 * @author Tim Bormann
 */


configuration PlatformLedsC {
  provides interface GeneralIO as Led0;
  provides interface GeneralIO as Led1;
  provides interface GeneralIO as Led2;
  uses interface Init;
}
implementation
{
	components 
	HplJn516GeneralIOC as GeneralIOC
	, new Jn516GpioC() as Led0Impl
	, new Jn516GpioC() as Led1Impl
	, new Jn516GpioC() as Led2Impl
	;
    
	components PlatformP;
	Init = PlatformP.LedsInit;

	Led0 = Led0Impl;
	Led0Impl -> GeneralIOC.Port2;

	Led1 = Led1Impl;
	Led1Impl -> GeneralIOC.Port3;

	Led2 = Led2Impl;
	Led2Impl -> GeneralIOC.PortNull;
}

