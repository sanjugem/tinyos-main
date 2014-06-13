/*
 * @author Sanjeet raj Pandey
 */

#include "TinyError.h"

interface HplJn516GeneralIO
{
  /**
   * Set pin to high.
   */
  async command void set();

  /**
   * Set pin to low.
   */
  async command void clr();

  /**
   * Toggle pin status.
   */
  async command void toggle();

  /**
   * Read pin value.
   *
   * @return TRUE if pin is high, FALSE otherwise.
   */
  async command bool get();

  /**
   * Set pin direction to input.
   */
  async command void makeInput();

  async command bool isInput();
  
  /**
   * Set pin direction to output.
   */
  async command void makeOutput();
  
  async command bool isOutput();

}

