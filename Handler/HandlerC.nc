#include <Msp430Adc12.h>
configuration HandlerC{
    provides 
    {
        interface Button;
        interface Read<uint16_t> as ReadX;
		interface Read<uint16_t> as ReadY;
    }
}
implementation{
    components HandlerP;
    components HplMsp430GeneralIOC;
    components new AdcReadClientC() as AdcX;
	components new AdcReadClientC() as AdcY;
    ReadX = AdcX;
	ReadY = AdcY;
    Button = HandlerP.Button;

    AdcX.AdcConfigure -> HandlerP.AdcConfigX;
	AdcY.AdcConfigure -> HandlerP.AdcConfigY;
    HandlerP.A_button -> HplMsp430GeneralIOC.Port60;
    HandlerP.B_button -> HplMsp430GeneralIOC.Port21;
    HandlerP.C_button -> HplMsp430GeneralIOC.Port61;
    HandlerP.D_button -> HplMsp430GeneralIOC.Port23;
    HandlerP.E_button -> HplMsp430GeneralIOC.Port62;
    HandlerP.F_button -> HplMsp430GeneralIOC.Port26;
}