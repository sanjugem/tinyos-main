/* 
 * @author Tim Bormann
 */

configuration PlatformC
{
  provides interface Init;

}
implementation
{
	components PlatformP;
	Init = PlatformP;

	components Jn516TimerInitC;
	PlatformP.Jn516TimerInit -> Jn516TimerInitC;
}
