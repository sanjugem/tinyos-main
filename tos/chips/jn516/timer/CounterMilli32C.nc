/* 
 * @author Tim Bormann
 */

configuration CounterMilli32C
{
	provides interface Init;	
	provides interface Counter<TMilli,uint32_t>;
}
implementation
{
	components new HalCounterMilli16P(E_AHI_TIMER_1) as CounterFrom;
	components new TransformCounterC(TMilli,uint32_t,TMilli,uint16_t,0,uint32_t) as Transform;

	Init = CounterFrom;
	Counter = Transform;

	Transform.CounterFrom -> CounterFrom;
}

