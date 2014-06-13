/*
 * @author Sanjeet raj Pandey
 * @author Tim Bormann
 */

#include <AppHardwareApi.h>

generic module HplJn516GeneralIOP(uint8_t pin)
{
	provides interface HplJn516GeneralIO as IO;
}
implementation
{
	bool output;

	async command void IO.set() { 
		vAHI_DioSetOutput(1 << pin,0); 
	}

	async command void IO.clr() { 
		vAHI_DioSetOutput(0,1 << pin);
	}

	async command void IO.toggle() {
		atomic {
			if(output) {
				if(call IO.get())
					call IO.clr();
				else
					call IO.set();
			}
		}
	}

	async command bool IO.get() {
		uint32_t dio = u32AHI_DioReadInput();
		if(1 << pin & dio)
			return TRUE;
		else
			return FALSE;
	}

	async command void IO.makeInput() {
		output = FALSE;
		vAHI_DioSetDirection(1 << pin,0); 
	}

	async command bool IO.isInput() { return !output; }

	async command void IO.makeOutput(){
		output = TRUE;
		vAHI_DioSetDirection(0,1 << pin); 
	}

	async command bool IO.isOutput() { return output; }
}
