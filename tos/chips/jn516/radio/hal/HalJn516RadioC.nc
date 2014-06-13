configuration HalJn516RadioC {
	provides {
		interface HalJn516Radio;
	}
}
implementation {
	components HalJn516RadioP;
	HalJn516Radio = HalJn516RadioP;

	components HplJn516RadioC;
	HalJn516RadioP.HplJn516Radio -> HplJn516RadioC;

	components Jn516PacketTransformC;
	Jn516NoMacP.Jn516PacketTransform -> Jn516PacketTransformC;
}
