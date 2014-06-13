/* 
 * @author Tim Bormann
 */

generic module HplJn516NullIOP()
{
	provides interface HplJn516GeneralIO as IO;
}
implementation
{
	async command void IO.makeOutput(){}
	async command void IO.makeInput() {}
	async command void IO.set() {}
	async command void IO.clr() {}
	async command void IO.toggle() {}
	async command bool IO.get() { return FALSE; }
	async command bool IO.isInput() { return FALSE; }
	async command bool IO.isOutput() { return FALSE; }
}
