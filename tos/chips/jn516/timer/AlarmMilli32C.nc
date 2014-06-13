/* 
 * @author Tim Bormann
 */

configuration AlarmMilli32C
{
	provides interface Init;
	provides interface Alarm<TMilli,uint32_t>;
}
implementation
{

	components new HalAlarmMilli16P(E_AHI_TIMER_0) as AlarmFrom;
	components CounterMilli32C as Counter;
	components new Jn516TransformAlarmC(TMilli,uint32_t,TMilli,uint16_t,0) as Transform;

	Init = AlarmFrom;
	Alarm = Transform;

	Transform.AlarmFrom -> AlarmFrom;
	Transform.Counter -> Counter;

}

