/* 
 * @author Tim Bormann
 */

generic module HalCounterMilli16P(uint8_t timer_id) {
	provides interface Counter<TMilli,uint16_t>;
	provides interface Init;
}
implementation
{
	#define PRESCALE 14

	bool int_pending;

	void TimerCallback(uint32 device, uint32 bitmap) {
		atomic int_pending = TRUE;
		signal Counter.overflow();
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
			vAHI_TimerStartRepeat(timer_id,0,0xFFFF);
			int_pending = FALSE;
		}
		return SUCCESS;
	}

	async command uint16_t Counter.get()
	{
		return u16AHI_TimerReadCount(timer_id);
	}

	async command bool Counter.isOverflowPending()
	{
		return int_pending;
	}

	async command void Counter.clearOverflow()
	{
		atomic {
			u8AHI_TimerFired(timer_id);
			int_pending = FALSE;
		}
	}

	default async event void Counter.overflow()
	{
	}

}
