configuration Jn516NoMacC {
	provides {
		interface SplitControl;
		interface Send;
		interface Receive;
	}
}
implementation {
	components Jn516NoMacP;
	SplitControl = Jn516NoMacP;
	Send = Jn516NoMacP;
	Receive = Jn516NoMacP;

	components HalJn516RadioC;
	Jn516NoMacP.HalJn516Radio = HalJn516RadioC;

	components new StateC();
	Jn516NoMacP.SplitControlState -> StateC;

	components Jn516PacketC;
	Jn516NoMacP.Jn516Packet -> Jn516PacketC;
	Jn516NoMacP.Jn516PacketBody -> Jn516PacketC;
}
