/* 
 * @author Tim Bormann
 */


#include "HalTimer.h"

module HalAlarm16Mhz28P
{
	provides interface Init;
	provides interface Alarm<T16Mhz,uint32_t> as Alarm;
}
implementation
{

	uint32_t target_value = 0;
	bool int_enabled = FALSE;

	void enableEvents() {
		atomic {
			int_enabled = TRUE;
			vAHI_TickTimerIntEnable(TRUE);
		}
	}

	void disableEvents() {
		atomic {
			int_enabled = FALSE;
			vAHI_TickTimerIntEnable(FALSE);
		}
	}

	bool areEventsEnabled() {
		return int_enabled;
	}

	uint32_t getEvent() {
		return target_value;
	}

	uint32_t get() {
		return u32AHI_TickTimerRead();
	}

	void setEvent(uint32_t t) {
		target_value = t;
		vAHI_TickTimerInterval(target_value);
	}

	void setEventFromNow(uint32_t t) {
		target_value = get() + t;
		vAHI_TickTimerInterval(target_value);
	}

	void clearPendingInterrupt() {
		vAHI_TickTimerIntPendClr();
	}

	void TickTimerCallback(uint32 device, uint32 bitmap) {
		disableEvents();
		signal Alarm.fired();
	}

	command error_t Init.init() {
		vAHI_TickTimerConfigure(E_AHI_TICK_TIMER_DISABLE);
		vAHI_TickTimerWrite(0);
		vAHI_TickTimerInterval(0xFFFFFFF);
		vAHI_TickTimerIntEnable(FALSE);
		vAHI_TickTimerRegisterCallback(TickTimerCallback);
		vAHI_TickTimerConfigure(E_AHI_TICK_TIMER_CONT);		
		return SUCCESS;
	}

	async command void Alarm.start( uint32_t dt )
	{
		call Alarm.startAt( call Alarm.getNow(), dt );
	}

	async command void Alarm.stop()
	{
		disableEvents();
	}

	async command bool Alarm.isRunning()
	{
		return areEventsEnabled();
	}

	async command void Alarm.startAt( uint32_t t0, uint32_t dt )
	{
		atomic
		{
			uint32_t now = get();
			uint32_t elapsed = now - t0;
			if( elapsed >= dt )
			{
				setEventFromNow(2);
			}
			else
			{
				uint32_t remaining = dt - elapsed;
				if( remaining <= 2 )
					setEventFromNow(2);
				else
					setEvent( now+remaining );
			}
			clearPendingInterrupt();
			enableEvents();
		}
	}

	async command uint32_t Alarm.getNow()
	{
		return get();
	}

	async command uint32_t Alarm.getAlarm()
	{
		return getEvent();
	}

}

