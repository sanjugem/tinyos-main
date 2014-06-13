/* 
 * @author Tim Bormann
 */

configuration Jn516TimerInitC {
	provides interface Init as Jn516TimerInit;
} implementation {

	components Jn516TimerInitP;
	Jn516TimerInit = Jn516TimerInitP;

	components AlarmMilli32C;
	Jn516TimerInitP.AlarmInit -> AlarmMilli32C;

	components CounterMilli32C;
	Jn516TimerInitP.CounterInit -> CounterMilli32C;

}
