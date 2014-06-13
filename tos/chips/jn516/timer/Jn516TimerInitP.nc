/* 
 * @author Tim Bormann
 */

module Jn516TimerInitP {
	provides interface Init as Jn516TimerInit;
	uses interface Init as AlarmInit;
	uses interface Init as CounterInit;
} implementation {

	command error_t Jn516TimerInit.init() {
		call AlarmInit.init();
		call CounterInit.init();
		return SUCCESS;
	}

}
