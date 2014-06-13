configuration HplJn516RadioC {
	provides {
		interface HplJn516Radio;
	}
}
implementation {
	components HplJn516RadioP;
	HplJn516Radio = HplJn516RadioP;
}
