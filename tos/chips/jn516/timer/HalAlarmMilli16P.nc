/* 
 * @author Tim Bormann
 */

generic module HalAlarmMilli16P(uint8_t timer_id) {
	provides interface Alarm<TMilli,uint16_t>;
	provides interface Init;
}
implementation
{
	#define PRESCALE 14

	uint16_t duration = 0;
	bool running;

	void TimerCallback(uint32 device, uint32 bitmap) {
		atomic running = FALSE;
		signal Alarm.fired();
	}

	command error_t Init.init()
	{
		atomic {
			vAHI_TimerEnable(timer_id,PRESCALE,FALSE,TRUE,FALSE);
			switch(timer_id) {
				case E_AHI_TIMER_0:
					vAHI_Timer0RegisterCallback(TimerCallback);
					break;
				case E_AHI_TIMER_1:
					vAHI_Timer1RegisterCallback(TimerCallback);
					break;
				case E_AHI_TIMER_2:
					vAHI_Timer2RegisterCallback(TimerCallback);
					break;
				case E_AHI_TIMER_3:
					vAHI_Timer3RegisterCallback(TimerCallback);
					break;
				case E_AHI_TIMER_4:
					vAHI_Timer4RegisterCallback(TimerCallback);
					break;
				default:
					return FAIL;
			}
			running = FALSE;
		}
		return SUCCESS;
	}

	async command void Alarm.start( uint16_t dt )
	{
		call Alarm.startAt( 0 , dt );
	}

	async command void Alarm.stop()
	{
		atomic {
			running = FALSE;
			vAHI_TimerStop(timer_id);
		}
	}

	async command bool Alarm.isRunning()
	{
		return running;
	}

	async command void Alarm.startAt( uint16_t t0, uint16_t dt )
	{
		atomic
		{
			if(t0 == 0)
			{
				duration = dt;
			} else {
				duration = 0xFFFF - t0 + dt;
			}
			running = TRUE;
			vAHI_TimerStartSingleShot(timer_id,0,duration);			
		}
	}

	async command uint16_t Alarm.getNow()
	{
		return u16AHI_TimerReadCount(timer_id);
	}

	async command uint16_t Alarm.getAlarm()
	{
		return duration;
	}

}
